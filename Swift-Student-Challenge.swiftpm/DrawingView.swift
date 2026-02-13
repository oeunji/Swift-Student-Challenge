//
//  File.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/13/26.
//

import SwiftUI
import PencilKit

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
