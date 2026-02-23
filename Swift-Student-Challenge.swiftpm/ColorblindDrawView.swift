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
    
    // Navigation용 상태
    @State private var navigateToFix = false
    @State private var snapshotImage: UIImage?
    
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
                
                // 실제 캔버스 (터치 입력용)
                DrawingView(canvasView: $canvasView)
                    .opacity(0.01) // 사용자에게는 안 보임
                
                // 시뮬레이션된 이미지 표시
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
                .padding(.bottom, 8)
            
            // 👉 다음 단계 버튼
            Button {
                createSnapshotAndNavigate()
            } label: {
                Text("Next: Fix Accessibility")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // Navigation 연결
            NavigationLink(
                destination: Group {
                    if let snapshotImage {
                        AccessibilityFixView(
                            originalImage: snapshotImage,
                            visionMode: selectedMode
                        )
                    } else {
                        EmptyView()
                    }
                },
                isActive: $navigateToFix
            ) {
                EmptyView()
            }
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
        let original = simulationService.render(
            drawing: canvasView.drawing,
            size: size
        )
        simulatedImage = simulationService.simulate(
            image: original,
            mode: selectedMode
        )
    }
    
    private func createSnapshotAndNavigate() {
        let size = CGSize(width: 1024, height: 1024)
        
        // 실제 원본 드로잉을 렌더링
        let original = simulationService.render(
            drawing: canvasView.drawing,
            size: size
        )
        
        snapshotImage = original
        navigateToFix = true
    }
}
