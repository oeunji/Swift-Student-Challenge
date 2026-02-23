//
//  ContrastMeterView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct ContrastMeterView: View {
    @Binding var colorA: Color
    @Binding var colorB: Color
    
    var body: some View {
        let ratio = contrastRatio(colorA, colorB)
        let verdict = verdictText(ratio)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Contrast")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f : 1", ratio))
                    .font(.subheadline)
                    .monospacedDigit()
            }
            
            HStack(spacing: 12) {
                ColorSwatch(color: colorA, label: "A")
                ColorSwatch(color: colorB, label: "B")
                Spacer()
                Text(verdict)
                    .font(.subheadline)
                    .foregroundStyle(verdictColor(ratio))
            }
            
            Text("Tip: For text/UI, aim for 4.5:1 or higher.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func verdictText(_ ratio: Double) -> String {
        if ratio >= 7.0 { return "Great (AAA)" }
        if ratio >= 4.5 { return "Good (AA)" }
        if ratio >= 3.0 { return "Okay (Large text)" }
        return "Low"
    }
    
    private func verdictColor(_ ratio: Double) -> Color {
        if ratio >= 4.5 { return .green }
        if ratio >= 3.0 { return .orange }
        return .red
    }
}

/// 간단 스와치
private struct ColorSwatch: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 18, height: 18)
            Text(label).font(.subheadline).foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemBackground).opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Contrast math (WCAG)
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
