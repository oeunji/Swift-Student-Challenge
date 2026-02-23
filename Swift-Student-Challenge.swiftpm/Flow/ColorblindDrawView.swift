//
//  ColorblindDrawView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit
import QuartzCore

struct ColorblindDrawView: View {

    @State private var canvasView = PKCanvasView()
    @State private var selectedMode: VisionMode = .protanopia

    @State private var normalImage: UIImage?
    @State private var simulatedImage: UIImage?

    @State private var renderSize: CGSize = .zero

    // Tool state
    @State private var activeTool: ToolType = .pen
    @State private var penColor: Color = .red
    @State private var penWidth: Double = 6
    @State private var isDrawing = false

    // Mission / Reveal
    @State private var isRevealActive = false
    @State private var revealSelection: RevealSelection = .simulated

    // Navigation
    @State private var navigateToFix = false
    @State private var snapshotImage: UIImage?

    // Alerts
    @State private var showClearAlert = false

    private let simulationService = VisionSimulationService()
    private let throttler = RenderThrottler(minInterval: 1.0 / 12.0) // ~12 fps
    @State private var idleWorkItem: DispatchWorkItem?

    enum ToolType {
        case pen
        case eraser
    }

    enum RevealSelection: String, CaseIterable {
        case simulated = "Simulated"
        case normal = "Normal"
    }

    var body: some View {
        VStack(spacing: 12) {

            // Mode selector
            Picker("Vision Mode", selection: $selectedMode) {
                ForEach(VisionMode.allCases.filter { $0 != .normal }, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            .onChange(of: selectedMode) { _ in
                updateSimulationForMode()
            }

            // Lightweight toolbar
            toolbar
                .padding(.horizontal)

            // Drawing area
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .allowsHitTesting(false)

                    // Simulated (or normal) render
                    if let imageToShow = displayedImage {
                        Image(uiImage: imageToShow)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .allowsHitTesting(false)
                    }

                    // Input layer (shows real ink while drawing)
                    DrawingView(canvasView: $canvasView)
                        .opacity(isDrawing ? 0.35 : 0.02)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Mission card
                    missionCard
                        .padding(14)
                        .allowsHitTesting(true)

                    // Reveal toggle (appears after reveal)
                    if isRevealActive {
                        revealPicker
                            .padding(14)
                            .transition(.opacity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .allowsHitTesting(true)
                    }
                }
                .onAppear {
                    updateRenderSizeIfNeeded(geo.size)
                }
                .onChange(of: geo.size) { _ in
                    updateRenderSizeIfNeeded(geo.size)
                }
            }
            .padding(.horizontal)

            // Reveal button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRevealActive = true
                    revealSelection = .normal
                }
            } label: {
                Text("Reveal Reality")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)

            // CTA
            Button {
                createSnapshotAndNavigate()
            } label: {
                Text("Next: Fix Accessibility")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 16)

            // Navigation link
            NavigationLink(
                destination: Group {
                    if let snapshotImage {
                        AccessibilityFixView(
                            originalImage: snapshotImage,
                            visionMode: selectedMode
                        )
                    } else {
                        EmptyView()
                    }
                },
                isActive: $navigateToFix
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Draw As Them")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupCanvas()
            updateSimulationForMode()
        }
        .onChange(of: canvasView.drawing) { _ in
            isDrawing = true
            scheduleThrottledRender()
            scheduleFinalRender()
        }
        .onDisappear {
            idleWorkItem?.cancel()
        }
        .alert("Clear canvas?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                canvasView.drawing = PKDrawing()
                scheduleImmediateRender()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            // Undo / Redo
            Button(action: { canvasView.undoManager?.undo() }) {
                Image(systemName: "arrow.uturn.backward")
            }
            Button(action: { canvasView.undoManager?.redo() }) {
                Image(systemName: "arrow.uturn.forward")
            }

            Divider().frame(height: 18)

            // Pen / Eraser
            Button {
                activeTool = .pen
                applyTool()
            } label: {
                Image(systemName: "pencil.tip")
                    .foregroundColor(activeTool == .pen ? .blue : .primary)
            }

            Button {
                activeTool = .eraser
                applyTool()
            } label: {
                Image(systemName: "eraser")
                    .foregroundColor(activeTool == .eraser ? .blue : .primary)
            }

            Divider().frame(height: 18)

            // Colors
            HStack(spacing: 8) {
                colorButton(.red)
                colorButton(.green)
                colorButton(.blue)
                colorButton(.black)
            }

            Divider().frame(height: 18)

            // Width
            HStack(spacing: 8) {
                Image(systemName: "lineweight")
                    .font(.system(size: 12))
                Slider(value: $penWidth, in: 2...12, step: 1) {
                    Text("Width")
                }
                .frame(width: 120)
                .onChange(of: penWidth) { _ in
                    if activeTool == .pen {
                        applyTool()
                    }
                }
            }

            Spacer(minLength: 0)

            // Clear
            Button {
                showClearAlert = true
            } label: {
                Image(systemName: "trash")
            }
        }
        .font(.system(size: 15))
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

    private var missionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mission")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Draw two squares: one red, one green. Then label them R and G.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRevealActive = true
                    revealSelection = .normal
                }
            } label: {
                Text("Done")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
    }

    private var revealPicker: some View {
        Picker("Reveal", selection: $revealSelection) {
            ForEach(RevealSelection.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 220)
        .onChange(of: revealSelection) { _ in
            updateSimulationForMode()
        }
    }

    private var displayedImage: UIImage? {
        if isRevealActive, revealSelection == .normal {
            return normalImage
        }
        return simulatedImage
    }

    private func colorButton(_ color: Color) -> some View {
        Button {
            penColor = color
            activeTool = .pen
            applyTool()
        } label: {
            Circle()
                .fill(color)
                .frame(width: 18, height: 18)
                .overlay(
                    Circle().stroke(Color.black.opacity(penColor == color ? 0.6 : 0.0), lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func setupCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        applyTool()
    }

    private func applyTool() {
        switch activeTool {
        case .pen:
            canvasView.tool = PKInkingTool(.pen, color: UIColor(penColor), width: penWidth)
        case .eraser:
            canvasView.tool = PKEraserTool(.vector)
        }
    }

    private func updateRenderSizeIfNeeded(_ size: CGSize) {
        guard size != .zero, size != renderSize else { return }
        renderSize = size
        scheduleImmediateRender()
    }

    private func updateSimulationForMode() {
        if let normalImage {
            simulatedImage = simulationService.simulate(image: normalImage, mode: selectedMode)
        } else {
            scheduleImmediateRender()
        }
    }

    private func scheduleThrottledRender() {
        throttler.request {
            renderAndSimulate()
        }
    }

    private func scheduleFinalRender() {
        idleWorkItem?.cancel()
        let item = DispatchWorkItem {
            renderAndSimulate()
            isDrawing = false
        }
        idleWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: item)
    }

    private func scheduleImmediateRender() {
        renderAndSimulate()
    }

    private func renderAndSimulate() {
        let size = renderSize == .zero ? CGSize(width: 1024, height: 1024) : renderSize
        let original = simulationService.render(drawing: canvasView.drawing, size: size)
        normalImage = original
        simulatedImage = simulationService.simulate(image: original, mode: selectedMode)
    }

    private func createSnapshotAndNavigate() {
        if normalImage == nil {
            renderAndSimulate()
        }
        snapshotImage = normalImage
        navigateToFix = snapshotImage != nil
    }
}

final class RenderThrottler {
    private let minInterval: TimeInterval
    private var lastFire: TimeInterval = 0
    private var scheduled = false
    private var workItem: DispatchWorkItem?

    init(minInterval: TimeInterval) {
        self.minInterval = minInterval
    }

    func request(_ block: @escaping () -> Void) {
        let now = CACurrentMediaTime()
        let delta = now - lastFire

        if delta >= minInterval {
            lastFire = now
            block()
            return
        }

        guard !scheduled else { return }
        scheduled = true

        let delay = minInterval - delta
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.lastFire = CACurrentMediaTime()
            self.scheduled = false
            block()
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }
}
