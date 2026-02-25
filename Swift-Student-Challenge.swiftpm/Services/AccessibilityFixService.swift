//
//  AccessibilityFixService.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import UIKit

enum PatternStyle: String, CaseIterable, Identifiable {
    case none = "None"
    case diagonalStripes = "Stripes"
    case dots = "Dots"
    
    var id: String { rawValue }
}

final class AccessibilityFixService {
    
    func applyFixes(
        to image: UIImage,
        pattern: PatternStyle,
        patternIntensity: CGFloat,
        addLegend: Bool
    ) -> UIImage {
        let size = image.size
        let scale = image.scale
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        
        if pattern != .none, patternIntensity > 0.01 {
            drawPattern(
                in: CGRect(origin: .zero, size: size),
                style: pattern,
                intensity: patternIntensity
            )
        }
        
        if addLegend {
            drawLegend(in: CGRect(origin: .zero, size: size))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func drawPattern(in rect: CGRect, style: PatternStyle, intensity: CGFloat) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.saveGState()
        defer { ctx.restoreGState() }
        
        let alpha = min(max(intensity, 0), 1) * 0.22
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(alpha).cgColor)
        ctx.setFillColor(UIColor.white.withAlphaComponent(alpha).cgColor)
        ctx.setLineWidth(max(1.0, rect.width / 420))
        
        switch style {
        case .diagonalStripes:
            let spacing = max(14, rect.width / 22)
            ctx.translateBy(x: rect.midX, y: rect.midY)
            ctx.rotate(by: .pi / 4)
            ctx.translateBy(x: -rect.midX, y: -rect.midY)
            
            var x: CGFloat = -rect.height
            while x < rect.width + rect.height {
                ctx.move(to: CGPoint(x: x, y: -rect.height))
                ctx.addLine(to: CGPoint(x: x, y: rect.height * 2))
                ctx.strokePath()
                x += spacing
            }
            
        case .dots:
            let spacing = max(18, rect.width / 18)
            let radius = max(1.6, rect.width / 260)
            var y: CGFloat = 0
            while y <= rect.height {
                var x: CGFloat = (Int(y / spacing) % 2 == 0) ? 0 : spacing / 2
                while x <= rect.width {
                    let dotRect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    ctx.fillEllipse(in: dotRect)
                    x += spacing
                }
                y += spacing
            }
            
        case .none:
            break
        }
    }
    
    private func drawLegend(in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        defer { ctx.restoreGState() }
        
        let padding: CGFloat = 14
        let boxW: CGFloat = min(360, rect.width * 0.46)
        let boxH: CGFloat = 92
        let boxRect = CGRect(
            x: padding,
            y: rect.height - boxH - padding,
            width: boxW,
            height: boxH
        )
        
        let bg = UIBezierPath(roundedRect: boxRect, cornerRadius: 16)
        UIColor.black.withAlphaComponent(0.35).setFill()
        bg.fill()
        
        let title = "Non-color cues applied"
        let body = "Patterns & labels help when colors look similar."
        
        drawText(title,
                 in: CGRect(x: boxRect.minX + 14, y: boxRect.minY + 12, width: boxRect.width - 28, height: 22),
                 font: .systemFont(ofSize: 16, weight: .semibold),
                 color: .white)
        
        drawText(body,
                 in: CGRect(x: boxRect.minX + 14, y: boxRect.minY + 36, width: boxRect.width - 28, height: 44),
                 font: .systemFont(ofSize: 13, weight: .regular),
                 color: UIColor.white.withAlphaComponent(0.92))
    }
    
    private func drawText(_ text: String, in rect: CGRect, font: UIFont, color: UIColor) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        (text as NSString).draw(in: rect, withAttributes: attrs)
    }
}
