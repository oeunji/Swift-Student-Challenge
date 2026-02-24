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
    @State private var renderRect: CGRect = .zero
    
    private let simulationService = VisionSimulationService()
    
    var body: some View {
        VStack {
            
            // 모드 선택
            Picker("Mode", selection: $selectedMode) {
                ForEach(VisionMode.allCases.filter { $0 != .normal }, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedMode) { _ in
                updateSimulation(rect: renderRect)
            }
            
            Divider()
            
            GeometryReader { geo in
                let availableWidth = geo.size.width - 32 - 16
                let imageSide = max(0, availableWidth / 2)
                HStack(spacing: 16) {
                    VStack {
                        Text("Normal")
                            .font(.caption)
                        Image(uiImage: renderOriginal(rect: renderRect))
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSide, height: imageSide)
                            .border(Color.gray.opacity(0.3))
                    }
                    
                    VStack {
                        Text(selectedMode.rawValue)
                            .font(.caption)
                        if let simulatedImage {
                            Image(uiImage: simulatedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSide, height: imageSide)
                                .border(Color.gray.opacity(0.3))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .navigationTitle("See Through Their Eyes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateRenderRect()
            updateSimulation(rect: renderRect)
        }
        .onChange(of: canvasView.drawing) { _ in
            updateRenderRect()
            updateSimulation(rect: renderRect)
        }
        
        NavigationLink("Draw As Them") {
            ColorblindDrawView()
        }
        .padding()
    }
    
    private func renderOriginal(rect: CGRect) -> UIImage {
        simulationService.render(drawing: canvasView.drawing, rect: rect)
    }
    
    private func updateSimulation(rect: CGRect) {
        let original = simulationService.render(drawing: canvasView.drawing, rect: rect)
        simulatedImage = simulationService.simulate(image: original, mode: selectedMode)
    }

    private func updateRenderRect() {
        let bounds = canvasView.drawing.bounds
        if bounds.isEmpty {
            renderRect = CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))
            return
        }

        let padding: CGFloat = 24
        renderRect = bounds.insetBy(dx: -padding, dy: -padding)
    }
}
