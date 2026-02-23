//
//  AccessibilityFixView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct AccessibilityFixView: View {
    
    let originalImage: UIImage
    let visionMode: VisionMode  // 사용자가 선택했던 모드(See/Draw 단계에서 이어받기)
    
    @State private var pattern: PatternStyle = .diagonalStripes
    @State private var intensity: CGFloat = 0.7
    @State private var addLegend: Bool = true
    
    // 대비 체커: 사용자가 대표 색 2개를 선택하도록(“해결책 제시” 느낌)
    @State private var colorA: Color = .red
    @State private var colorB: Color = .green
    
    @State private var showSimulatedPreview: Bool = true
    
    private let fixService = AccessibilityFixService()
    private let simService = VisionSimulationService()
    
    @State private var goShare = false

    @State private var normalAfterImage: UIImage?
    @State private var simulatedBeforeImage: UIImage?
    @State private var simulatedAfterImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                header
                
                // 미리보기: Normal vs Selected Mode, Original vs Fixed 토글
                previewCard
                
                // 대비 측정기
                ContrastMeterView(colorA: $colorA, colorB: $colorB)
                
                // 개선 옵션
                optionsCard
                
                Button {
                    generateExportImages()
                } label: {
                    Text("Next: Share / Commit")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 54)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .navigationTitle("Accessibility Fix")
        .navigationBarTitleDisplayMode(.inline)
        
        NavigationLink(
            destination: destinationView,
            isActive: $goShare
        ) {
            EmptyView()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fix it for everyone")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("Colors can fail. Add contrast and non-color cues like patterns & labels.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Preview")
                    .font(.headline)
                Spacer()
                Toggle("Simulate \(visionMode.rawValue)", isOn: $showSimulatedPreview)
                    .labelsHidden()
            }
            
            let fixed = fixService.applyFixes(
                to: originalImage,
                pattern: pattern,
                patternIntensity: intensity,
                addLegend: addLegend
            )
            
            let left = showSimulatedPreview ? simService.simulate(image: originalImage, mode: visionMode) : originalImage
            let right = showSimulatedPreview ? simService.simulate(image: fixed, mode: visionMode) : fixed
            
            HStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text("Before")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(uiImage: left)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                VStack(spacing: 6) {
                    Text("After")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(uiImage: right)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var optionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Non-color cues")
                .font(.headline)
            
            Picker("Pattern", selection: $pattern) {
                ForEach(PatternStyle.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Text("Intensity")
                    .font(.subheadline)
                Slider(value: $intensity, in: 0...1)
            }
            
            Toggle("Add legend label", isOn: $addLegend)
                .font(.subheadline)
            
            Divider()
            
            Text("Check two colors you rely on")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                ColorPicker("Color A", selection: $colorA)
                ColorPicker("Color B", selection: $colorB)
            }
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let normalAfterImage,
           let simulatedBeforeImage,
           let simulatedAfterImage {
            
            ShareCommitView(
                normalBefore: originalImage,
                normalAfter: normalAfterImage,
                simulatedBefore: simulatedBeforeImage,
                simulatedAfter: simulatedAfterImage,
                visionModeName: visionMode.rawValue,
                patternName: pattern.rawValue,
                intensity: intensity,
                contrastRatio: contrastRatio(colorA, colorB)
            )
        } else {
            EmptyView()
        }
    }
    
    private func generateExportImages() {
        let fixed = fixService.applyFixes(
            to: originalImage,
            pattern: pattern,
            patternIntensity: intensity,
            addLegend: addLegend
        )
        
        normalAfterImage = fixed
        simulatedBeforeImage = simService.simulate(image: originalImage, mode: visionMode)
        simulatedAfterImage = simService.simulate(image: fixed, mode: visionMode)
        
        goShare = true
    }
    
    private func contrastRatio(_ a: Color, _ b: Color) -> Double {
        let la = relativeLuminance(a)
        let lb = relativeLuminance(b)
        let lighter = max(la, lb)
        let darker  = min(la, lb)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func relativeLuminance(_ color: Color) -> Double {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, bl: CGFloat = 0, al: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &bl, alpha: &al)
        
        func f(_ c: CGFloat) -> Double {
            let c = Double(c)
            return (c <= 0.03928) ? (c / 12.92) : pow((c + 0.055) / 1.055, 2.4)
        }
        
        let R = f(r), G = f(g), B = f(bl)
        return 0.2126 * R + 0.7152 * G + 0.0722 * B
    }
}
