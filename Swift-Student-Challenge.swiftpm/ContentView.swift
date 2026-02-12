import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    // 현재 어떤 도구를 사용 중인지 추적하기 위한 상태
    @State private var activeTool: ToolType = .pen
    
    enum ToolType {
        case pen, eraser, lasso
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DrawingView(canvasView: $canvasView)
                    .ignoresSafeArea(edges: .bottom)
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
                        
                        // 펜 버튼
                        Button(action: {
                            activeTool = .pen
                            canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
                        }) {
                            Image(systemName: "pencil.tip")
                                .foregroundColor(activeTool == .pen ? .blue : .primary)
                        }

                        // 지우개 버튼 (핵심!)
                        Button(action: {
                            activeTool = .eraser
                            // .vector는 선 하나를 통째로 지우고, .bitmap은 문지르는 곳만 지웁니다.
                            canvasView.tool = PKEraserTool(.vector)
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
                        
                        Image(systemName: "hand.raised")
                        
                        Divider().frame(height: 20)
                        
                        Circle().fill(.blue).frame(width: 20)
                        Circle().fill(.brown).frame(width: 20)
                        Circle().fill(.red).frame(width: 20)
                        Image(systemName: "chevron.down.circle")
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = .white
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
