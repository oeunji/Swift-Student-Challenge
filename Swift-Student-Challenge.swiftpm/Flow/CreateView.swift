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
    
    enum ToolType {
        case pencil, pen, brush, eraser, lasso
    }
    
    private let palette: [Color] = [.black, .red, .yellow, .green, .blue, .purple]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DrawingView(canvasView: $canvasView)
                    .ignoresSafeArea(edges: .bottom)
            }
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    VisionSimView(canvasView: $canvasView)
                } label: {
                    Text("See Through Their Eyes")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.thinMaterial)
            }
            .navigationTitle("Bio_DNA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    HStack(spacing: 15) {
                        // 실행 취소 / 다시 실행
                        Button(action: { canvasView.undoManager?.undo() }) { Image(systemName: "arrow.uturn.backward") }
                        Button(action: { canvasView.undoManager?.redo() }) { Image(systemName: "arrow.uturn.forward") }
                        
                        Divider().frame(height: 20)
                        
                        // 연필 버튼
                        Button(action: {
                            setInkingTool(.pencil)
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(activeTool == .pencil ? .blue : .primary)
                        }

                        // 펜 버튼
                        Button(action: {
                            setInkingTool(.pen)
                        }) {
                            Image(systemName: "pencil.tip")
                                .foregroundColor(activeTool == .pen ? .blue : .primary)
                        }

                        // 붓 버튼
                        Button(action: {
                            setInkingTool(.marker)
                        }) {
                            Image(systemName: "paintbrush")
                                .foregroundColor(activeTool == .brush ? .blue : .primary)
                        }

                        // 지우개 버튼 (핵심!)
                        Button(action: {
                            activeTool = .eraser
                            // .vector는 선 하나를 통째로 지우고, .bitmap은 문지르는 곳만 지웁니다.
                            canvasView.tool = PKEraserTool(eraserMode)
                        }) {
                            Image(systemName: "eraser")
                                .foregroundColor(activeTool == .eraser ? .blue : .primary)
                        }

                        // 올가미 도구
                        Button(action: {
                            activeTool = .lasso
                            canvasView.tool = PKLassoTool()
                        }) {
                            Image(systemName: "lasso")
                                .foregroundColor(activeTool == .lasso ? .blue : .primary)
                        }
                        
                        Divider().frame(height: 20)
                        
                        ForEach(palette.indices, id: \.self) { index in
                            let color = palette[index]
                            Button {
                                activeColor = color
                                if let inking = currentInkingType {
                                    setInkingTool(inking)
                                } else {
                                    setInkingTool(.pen)
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

                        if let inking = currentInkingType {
                            Divider().frame(height: 20)
                            Slider(
                                value: widthBinding(for: inking),
                                in: widthRange(for: inking),
                                step: 1
                            )
                            .frame(width: 110)
                            .onChange(of: widthBinding(for: inking).wrappedValue) { _ in
                                setInkingTool(inking)
                            }
                        }

                        if activeTool == .eraser {
                            Divider().frame(height: 20)
                            Button {
                                eraserMode = .vector
                                canvasView.tool = PKEraserTool(eraserMode)
                            } label: {
                                Image(systemName: "eraser.line.dashed")
                                    .foregroundColor(eraserMode == .vector ? .blue : .primary)
                            }
                            Button {
                                eraserMode = .bitmap
                                canvasView.tool = PKEraserTool(eraserMode)
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
    }

    private var currentInkingType: PKInkingTool.InkType? {
        switch activeTool {
        case .pencil: return .pencil
        case .pen: return .pen
        case .brush: return .marker
        case .eraser, .lasso: return nil
        }
    }

    private func setInkingTool(_ ink: PKInkingTool.InkType) {
        switch ink {
        case .pencil:
            activeTool = .pencil
            canvasView.tool = PKInkingTool(.pencil, color: UIColor(activeColor), width: pencilWidth)
        case .pen:
            activeTool = .pen
            canvasView.tool = PKInkingTool(.pen, color: UIColor(activeColor), width: penWidth)
        case .marker:
            activeTool = .brush
            canvasView.tool = PKInkingTool(.marker, color: UIColor(activeColor), width: brushWidth)
        @unknown default:
            activeTool = .pen
            canvasView.tool = PKInkingTool(.pen, color: UIColor(activeColor), width: penWidth)
        }
    }

    private func widthBinding(for ink: PKInkingTool.InkType) -> Binding<Double> {
        switch ink {
        case .pencil: return $pencilWidth
        case .pen: return $penWidth
        case .marker: return $brushWidth
        @unknown default: return $penWidth
        }
    }

    private func widthRange(for ink: PKInkingTool.InkType) -> ClosedRange<Double> {
        switch ink {
        case .pencil: return 2...10
        case .pen: return 2...12
        case .marker: return 4...18
        @unknown default: return 2...12
        }
    }
}
