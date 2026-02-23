//
//  VisionSimView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit

struct VisionSimView: View {
    
    @Binding var canvasView: PKCanvasView
    
    @State private var selectedMode: VisionMode = .protanopia
    @State private var simulatedImage: UIImage?
    
    private let simulationService = VisionSimulationService()
    
    var body: some View {
        VStack {
            
            // 모드 선택
            Picker("Mode", selection: $selectedMode) {
                ForEach(VisionMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedMode) { _ in
                updateSimulation()
            }
            
            Divider()
            
            GeometryReader { geo in
                HStack {
                    VStack {
                        Text("Normal")
                            .font(.caption)
                        Image(uiImage: renderOriginal(size: geo.size))
                            .resizable()
                            .scaledToFit()
                            .border(Color.gray.opacity(0.3))
                    }
                    
                    VStack {
                        Text(selectedMode.rawValue)
                            .font(.caption)
                        if let simulatedImage {
                            Image(uiImage: simulatedImage)
                                .resizable()
                                .scaledToFit()
                                .border(Color.gray.opacity(0.3))
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("See Through Their Eyes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateSimulation()
        }
    }
    
    private func renderOriginal(size: CGSize) -> UIImage {
        simulationService.render(drawing: canvasView.drawing, size: size)
    }
    
    private func updateSimulation() {
        let size = CGSize(width: 1024, height: 1024)
        let original = simulationService.render(drawing: canvasView.drawing, size: size)
        simulatedImage = simulationService.simulate(image: original, mode: selectedMode)
    }
}
