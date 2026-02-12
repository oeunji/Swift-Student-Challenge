import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput // 애플 펜슬 + 손가락
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack {
            DrawingView(canvasView: $canvasView)
            
            HStack {
                Button("펜") { canvasView.tool = PKInkingTool(.pen, color: .black, width: 5) }
                Button("지우개") { canvasView.tool = PKEraserTool(.vector) }
            }
        }
    }
}
