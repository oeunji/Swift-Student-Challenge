//
//  ColorblindDrawView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit
import CoreImage
import UIKit

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
    @State private var renderTimer: Timer?

    private let simulationService = VisionSimulationService()

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
        content
        .navigationTitle("Draw As Them")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupCanvas()
            startRenderTimer()
        }
        .onDisappear {
            stopRenderTimer()
        }
        .alert("Reveal Reality?", isPresented: $showRevealAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reveal") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRevealActive = true
                    revealSelection = .normal
                }
                setTool(activeTool)
                renderAndSimulate()
            }
        } message: {
            Text("This will show the normal view so you can compare it with the simulated vision.")
        }
    }

    private var content: some View {
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
                setTool(activeTool)
                renderAndSimulate()
            }

            toolBarRow
                .padding(.horizontal)

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
                        .opacity(drawingOpacity)
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
                    renderAndSimulate()
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
                    .foregroundColor(isRevealActive ? .white : .black)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .disabled(isRevealActive)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private func isInkingTool(_ tool: ToolType) -> Bool {
        switch tool {
        case .pencil, .pen, .brush: return true
        case .eraser, .lasso: return false
        }
    }

    private var sliderBinding: Binding<Double> {
        widthBinding(for: activeTool) ?? $penWidth
    }

    private var sliderRange: ClosedRange<Double> {
        widthRange(for: activeTool) ?? 2...12
    }

    private var toolBarRow: some View {
        HStack(spacing: 15) {
            Button(action: { canvasView.undoManager?.undo() }) {
                Image(systemName: "arrow.uturn.backward")
                    .foregroundColor(.black)
            }
            Button(action: { canvasView.undoManager?.redo() }) {
                Image(systemName: "arrow.uturn.forward")
                    .foregroundColor(.black)
            }

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
                let displayColor = simulatedColor(color, mode: effectiveMode)
                Button {
                    activeColor = color
                    if isInkingTool(activeTool) {
                        setTool(activeTool)
                    } else {
                        setTool(.pen)
                    }
                } label: {
                    Circle()
                        .fill(displayColor)
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

            Divider().frame(height: 20)
            Slider(
                value: sliderBinding,
                in: sliderRange,
                step: 1
            )
            .tint(.black)
            .frame(width: 110)
            .opacity(isInkingTool(activeTool) ? 1 : 0.2)
            .allowsHitTesting(isInkingTool(activeTool))
            .onChange(of: sliderBinding.wrappedValue) { _ in
                setTool(activeTool)
            }

        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
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
            renderAndSimulate()
        }
    }

    private var effectiveMode: VisionMode {
        if isRevealActive, revealSelection == .normal {
            return .normal
        }
        return selectedMode
    }

    private var displayedImage: UIImage? {
        if isRevealActive, revealSelection == .normal {
            return normalImage
        }
        return simulatedImage
    }

    private var drawingOpacity: Double {
        if isDrawing { return 1.0 }
        if activeTool == .eraser || activeTool == .lasso { return 1.0 }
        return 0.02
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
    }

    private func renderAndSimulate() {
        let size = renderSize == .zero ? CGSize(width: 1024, height: 1024) : renderSize
        let original = simulationService.render(drawing: canvasView.drawing, size: size)
        normalImage = original
        simulatedImage = simulationService.simulate(image: original, mode: selectedMode)
    }

    private func startRenderTimer() {
        if renderTimer != nil { return }
        renderTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            renderAndSimulate()
        }
    }

    private func stopRenderTimer() {
        renderTimer?.invalidate()
        renderTimer = nil
    }

    private func simulatedColor(_ color: Color, mode: VisionMode) -> Color {
        guard mode != .normal else { return color }
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let (rr, gg, bb) = applyMatrix(r: r, g: g, b: b, mode: mode)
        return Color(red: rr, green: gg, blue: bb, opacity: Double(a))
    }

    private func applyMatrix(r: CGFloat, g: CGFloat, b: CGFloat, mode: VisionMode) -> (Double, Double, Double) {
        let (rv, gv, bv) = matrix(for: mode)
        let nr = rv.0 * Double(r) + rv.1 * Double(g) + rv.2 * Double(b)
        let ng = gv.0 * Double(r) + gv.1 * Double(g) + gv.2 * Double(b)
        let nb = bv.0 * Double(r) + bv.1 * Double(g) + bv.2 * Double(b)
        return (clamp(nr), clamp(ng), clamp(nb))
    }

    private func matrix(for mode: VisionMode) -> ((Double, Double, Double), (Double, Double, Double), (Double, Double, Double)) {
        switch mode {
        case .protanopia:
            return ((0.567, 0.433, 0.0), (0.558, 0.442, 0.0), (0.0, 0.242, 0.758))
        case .deuteranopia:
            return ((0.625, 0.375, 0.0), (0.7, 0.3, 0.0), (0.0, 0.3, 0.7))
        case .tritanopia:
            return ((0.95, 0.05, 0.0), (0.0, 0.433, 0.567), (0.0, 0.475, 0.525))
        case .achromatopsia:
            return ((0.299, 0.587, 0.114), (0.299, 0.587, 0.114), (0.299, 0.587, 0.114))
        case .normal:
            return ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0))
        }
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }
}
