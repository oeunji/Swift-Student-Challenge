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
    @State private var isDrawing = false
    @State private var isRevealActive = false
    @State private var revealSelection: RevealSelection = .simulated
    @State private var showRevealAlert = false
    @State private var activeTool: ToolType = .pen
    @State private var activeColor: Color = .black
    @State private var pencilWidth: Double = 4
    @State private var penWidth: Double = 5
    @State private var brushWidth: Double = 7
    @State private var eraserMode: PKEraserTool.EraserType = .vector
    @State private var missionText: String = Self.missions.randomElement() ?? "Draw a ripe red apple."

    private let simulationService = VisionSimulationService()
    private let throttler = RenderThrottler(minInterval: 1.0 / 12.0)
    @State private var idleWorkItem: DispatchWorkItem?

    enum ToolType {
        case pencil, pen, brush, eraser, lasso
    }

    enum RevealSelection: String, CaseIterable {
        case simulated = "Simulated"
        case normal = "Normal"
    }

    private let palette: [Color] = [.black, .red, .yellow, .green, .blue, .purple]
    private static let missions: [String] = [
        "Draw a ripe red apple.",
        "Draw a traffic light with red, yellow, and green.",
        "Draw a rainbow."
    ]

    var body: some View {
        VStack(spacing: 12) {
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

            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    if let imageToShow = displayedImage {
                        Image(uiImage: imageToShow)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(isDrawing ? 0.35 : 1.0)
                            .allowsHitTesting(false)
                    }

                    DrawingView(canvasView: $canvasView)
                        .opacity(isDrawing ? 1.0 : 0.02)
                        .ignoresSafeArea(edges: .bottom)

                    missionCard
                        .padding(14)
                        .allowsHitTesting(false)

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

            Button {
                showRevealAlert = true
            } label: {
                Text("Reveal Reality")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.bottom, 16)
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
        .alert("Reveal Reality?", isPresented: $showRevealAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reveal") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRevealActive = true
                    revealSelection = .normal
                }
            }
        } message: {
            Text("This will show the normal view so you can compare it with the simulated vision.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                HStack(spacing: 15) {
                    Button(action: { canvasView.undoManager?.undo() }) { Image(systemName: "arrow.uturn.backward") }
                    Button(action: { canvasView.undoManager?.redo() }) { Image(systemName: "arrow.uturn.forward") }

                    Divider().frame(height: 20)

                    Button(action: {
                        setTool(.pencil)
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(activeTool == .pencil ? .blue : .primary)
                    }

                    Button(action: {
                        setTool(.pen)
                    }) {
                        Image(systemName: "pencil.tip")
                            .foregroundColor(activeTool == .pen ? .blue : .primary)
                    }

                    Button(action: {
                        setTool(.brush)
                    }) {
                        Image(systemName: "paintbrush")
                            .foregroundColor(activeTool == .brush ? .blue : .primary)
                    }

                    Button(action: {
                        setTool(.eraser)
                    }) {
                        Image(systemName: "eraser")
                            .foregroundColor(activeTool == .eraser ? .blue : .primary)
                    }

                    Button(action: {
                        setTool(.lasso)
                    }) {
                        Image(systemName: "lasso")
                            .foregroundColor(activeTool == .lasso ? .blue : .primary)
                    }

                    Divider().frame(height: 20)

                    ForEach(palette.indices, id: \.self) { index in
                        let color = palette[index]
                        Button {
                            activeColor = color
                            if isInkingTool(activeTool) {
                                setTool(activeTool)
                            } else {
                                setTool(.pen)
                            }
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: activeColor == color ? 24 : 20, height: activeColor == color ? 24 : 20)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(activeColor == color ? 0.95 : 0.0), lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(activeColor == color ? 0.35 : 0.0), radius: 6, x: 0, y: 2)
                                .animation(.easeInOut(duration: 0.12), value: activeColor == color)
                        }
                        .buttonStyle(.plain)
                    }

                    if let widthBinding = widthBinding(for: activeTool),
                       let widthRange = widthRange(for: activeTool) {
                        Divider().frame(height: 20)
                        Slider(
                            value: widthBinding,
                            in: widthRange,
                            step: 1
                        )
                        .frame(width: 110)
                        .onChange(of: widthBinding.wrappedValue) { _ in
                            setTool(activeTool)
                        }
                    }

                    if activeTool == .eraser {
                        Divider().frame(height: 20)
                        Button {
                            eraserMode = .vector
                            setTool(.eraser)
                        } label: {
                            Image(systemName: "eraser.line.dashed")
                                .foregroundColor(eraserMode == .vector ? .blue : .primary)
                        }
                        Button {
                            eraserMode = .bitmap
                            setTool(.eraser)
                        } label: {
                            Image(systemName: "eraser")
                                .foregroundColor(eraserMode == .bitmap ? .blue : .primary)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }

    private func isInkingTool(_ tool: ToolType) -> Bool {
        switch tool {
        case .pencil, .pen, .brush: return true
        case .eraser, .lasso: return false
        }
    }

    private var missionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mission")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(missionText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
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

    private func setTool(_ tool: ToolType) {
        switch tool {
        case .pencil:
            activeTool = .pencil
            canvasView.tool = PKInkingTool(.pencil, color: UIColor(activeColor), width: pencilWidth)
        case .pen:
            activeTool = .pen
            canvasView.tool = PKInkingTool(.pen, color: UIColor(activeColor), width: penWidth)
        case .brush:
            activeTool = .brush
            canvasView.tool = PKInkingTool(.marker, color: UIColor(activeColor), width: brushWidth)
        case .eraser:
            activeTool = .eraser
            canvasView.tool = PKEraserTool(eraserMode)
        case .lasso:
            activeTool = .lasso
            canvasView.tool = PKLassoTool()
        }
    }

    private func widthBinding(for tool: ToolType) -> Binding<Double>? {
        switch tool {
        case .pencil: return $pencilWidth
        case .pen: return $penWidth
        case .brush: return $brushWidth
        case .eraser, .lasso: return nil
        }
    }

    private func widthRange(for tool: ToolType) -> ClosedRange<Double>? {
        switch tool {
        case .pencil: return 2...10
        case .pen: return 2...12
        case .brush: return 4...18
        case .eraser, .lasso: return nil
        }
    }

    private func setupCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        setTool(activeTool)
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
