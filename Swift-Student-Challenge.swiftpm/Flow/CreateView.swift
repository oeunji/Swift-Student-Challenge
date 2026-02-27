import SwiftUI
import PencilKit

struct CreateView: View {
    @State private var canvasView = PKCanvasView()
    @State private var activeTool: ToolType = .pen
    @State private var activeColor: Color = .black
    @State private var pencilWidth: Double = 4
    @State private var penWidth: Double = 5
    @State private var brushWidth: Double = 7
    @State private var eraserMode: PKEraserTool.EraserType = .vector
    @Environment(\.dismiss) private var dismiss
    
    enum ToolType {
        case pencil, pen, brush, eraser, lasso
    }
    
    private let palette: [Color] = [.black, .red, .yellow, .green, .blue, .purple]

    var body: some View {
        ZStack(alignment: .top) {
            DrawingView(canvasView: $canvasView)
                .ignoresSafeArea(edges: .bottom)
        }
        .safeAreaInset(edge: .bottom) {
            Text("Feel free to draw, and tap the Next button when you’re done.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.thinMaterial)
        }
        .navigationTitle("Bio_DNA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    VisionSimView(canvasView: $canvasView, onFinish: { dismiss() })
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                }
                .buttonStyle(.bordered)
                .tint(.clear)
                .padding(.horizontal, 12)
            }
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
                            .tint(.black)
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
}
