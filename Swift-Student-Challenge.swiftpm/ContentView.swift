import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: Color = .blue
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 1. 실제 그림을 그리는 캔버스 영역
                DrawingView(canvasView: $canvasView)
                    .ignoresSafeArea(edges: .bottom)
                
                // 필요한 경우 여기에 추가적인 오버레이 UI를 넣을 수 있습니다.
            }
            // 2. 상단 헤더 (Toolbar) 설정
            .navigationTitle("Bio_DNA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 왼쪽 버튼들
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "sidebar.left")
                }
                
                // 중앙 도구들 (이미지의 펜, 지우개, 선택 도구 등)
                ToolbarItemGroup(placement: .principal) {
                    HStack(spacing: 15) {
                        Button(action: { /* 되돌리기 */ }) { Image(systemName: "arrow.uturn.backward") }
                        Button(action: { /* 다시실행 */ }) { Image(systemName: "arrow.uturn.forward") }
                        
                        Divider().frame(height: 20)
                        
                        // 도구 선택 아이콘들
                        Image(systemName: "pencil.tip").foregroundColor(.blue)
                        Image(systemName: "eraser")
                        Image(systemName: "lasso")
                        Image(systemName: "hand.raised")
                        
                        Divider().frame(height: 20)
                        
                        // 컬러 피커 느낌의 원형들
                        Circle().fill(.blue).frame(width: 20)
                        Circle().fill(.brown).frame(width: 20)
                        Circle().fill(.red).frame(width: 20)
                        Image(systemName: "chevron.down.circle")
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                // 오른쪽 버튼들
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 20) {
                        Image(systemName: "pencil.and.outline")
                        Image(systemName: "plus.app")
                        Image(systemName: "bookmark")
                        Image(systemName: "square.and.arrow.up")
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}

// 기존 DrawingView 코드는 유지하되, 캔버스 배경을 투명하게 하거나 설정 추가 가능
struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        // 이미지처럼 격자나 배경색을 넣고 싶다면 여기서 설정
        canvasView.backgroundColor = .white
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
