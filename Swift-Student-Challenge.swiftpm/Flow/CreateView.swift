import SwiftUI
import PencilKit

struct CreateView: View {
    @State private var canvasView = PKCanvasView()
    @State private var activeTool: ToolType = .pen
    @State private var activeColor: Color = .black
    
    enum ToolType {
        case pen, eraser, lasso
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
                        
                        // 펜 버튼
                        Button(action: {
                            activeTool = .pen
                            canvasView.tool = PKInkingTool(.pen, color: UIColor(activeColor), width: 5)
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
                        
                        Divider().frame(height: 20)
                        
                        ForEach(palette.indices, id: \.self) { index in
                            let color = palette[index]
                            Button {
                                activeColor = color
                                activeTool = .pen
                                canvasView.tool = PKInkingTool(.pen, color: UIColor(color), width: 5)
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
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }
}
