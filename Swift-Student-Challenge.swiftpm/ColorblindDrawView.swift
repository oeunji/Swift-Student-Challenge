//
//  ColorblindDrawView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit

struct ColorblindDrawView: View {
    
    @State private var canvasView = PKCanvasView()
    @State private var selectedMode: VisionMode = .protanopia
    @State private var simulatedImage: UIImage?
    
    private let simulationService = VisionSimulationService()
    
    var body: some View {
        VStack {
            
            // 모드 선택
            Picker("Vision Mode", selection: $selectedMode) {
                ForEach(VisionMode.allCases.filter { $0 != .normal }, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            ZStack {
                
                // 실제 캔버스는 숨김 (투명 처리)
                DrawingView(canvasView: $canvasView)
                    .opacity(0.01)
                
                // 필터 적용된 이미지 보여주기
                if let simulatedImage {
                    Image(uiImage: simulatedImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .onChange(of: canvasView.drawing) { _ in
                updateSimulation()
            }
            .onChange(of: selectedMode) { _ in
                updateSimulation()
            }
            
            Spacer()
            
            Text("Try drawing red and green. Can you tell the difference?")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .navigationTitle("Draw As Them")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupCanvas()
            updateSimulation()
        }
    }
    
    private func setupCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 5)
        canvasView.backgroundColor = .white
    }
    
    private func updateSimulation() {
        let size = CGSize(width: 1024, height: 1024)
        let original = simulationService.render(drawing: canvasView.drawing, size: size)
        simulatedImage = simulationService.simulate(image: original, mode: selectedMode)
    }
}
