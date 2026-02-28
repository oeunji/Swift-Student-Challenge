//
//  ExportService.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import UIKit

struct ExportBundle {
    let summaryImage: UIImage
    let reportImage: UIImage
}

final class ExportService {
    
    func makeSummaryGrid(
        normalBefore: UIImage,
        normalAfter: UIImage,
        simulatedBefore: UIImage,
        simulatedAfter: UIImage,
        title: String = "Is This Red? — Summary"
    ) -> UIImage {
        let cellSize = CGSize(width: 700, height: 700)
        let nb = normalBefore.scaledToFit(in: cellSize)
        let na = normalAfter.scaledToFit(in: cellSize)
        let sb = simulatedBefore.scaledToFit(in: cellSize)
        let sa = simulatedAfter.scaledToFit(in: cellSize)

        let padding: CGFloat = 24
        let headerH: CGFloat = 90
        let labelH: CGFloat = 36

        let canvasW = padding + cellSize.width + padding + cellSize.width + padding
        let canvasH = padding + headerH + padding + (labelH + cellSize.height) + padding + (labelH + cellSize.height) + padding

        let size = CGSize(width: canvasW, height: canvasH)
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        defer { UIGraphicsEndImageContext() }

        UIColor.systemBackground.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        drawText(
            title,
            in: CGRect(x: padding, y: padding, width: canvasW - padding * 2, height: headerH),
            font: .systemFont(ofSize: 32, weight: .bold),
            color: .label
        )

        let row1Y = padding + headerH + padding
        let row2Y = row1Y + labelH + cellSize.height + padding

        let col1X = padding
        let col2X = padding + cellSize.width + padding

        drawChip("Normal — Before", at: CGPoint(x: col1X, y: row1Y), width: cellSize.width, height: labelH)
        drawChip("Normal — After",  at: CGPoint(x: col2X, y: row1Y), width: cellSize.width, height: labelH)
        drawChip("Sim — Before",    at: CGPoint(x: col1X, y: row2Y), width: cellSize.width, height: labelH)
        drawChip("Sim — After",     at: CGPoint(x: col2X, y: row2Y), width: cellSize.width, height: labelH)

        nb.draw(in: CGRect(x: col1X, y: row1Y + labelH, width: cellSize.width, height: cellSize.height))
        na.draw(in: CGRect(x: col2X, y: row1Y + labelH, width: cellSize.width, height: cellSize.height))
        sb.draw(in: CGRect(x: col1X, y: row2Y + labelH, width: cellSize.width, height: cellSize.height))
        sa.draw(in: CGRect(x: col2X, y: row2Y + labelH, width: cellSize.width, height: cellSize.height))

        strokeRoundedRect(CGRect(x: col1X, y: row1Y + labelH, width: cellSize.width, height: cellSize.height))
        strokeRoundedRect(CGRect(x: col2X, y: row1Y + labelH, width: cellSize.width, height: cellSize.height))
        strokeRoundedRect(CGRect(x: col1X, y: row2Y + labelH, width: cellSize.width, height: cellSize.height))
        strokeRoundedRect(CGRect(x: col2X, y: row2Y + labelH, width: cellSize.width, height: cellSize.height))

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func makeReportCard(
        visionModeName: String,
        patternName: String,
        intensity: CGFloat,
        contrastRatio: Double
    ) -> UIImage {

        let size = CGSize(width: 1200, height: 720)
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        defer { UIGraphicsEndImageContext() }

        UIColor.systemBackground.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        let cardRect = CGRect(x: 60, y: 60, width: size.width - 120, height: size.height - 120)
        let path = UIBezierPath(roundedRect: cardRect, cornerRadius: 40)
        UIColor.secondarySystemBackground.setFill()
        path.fill()

        drawText(
            "Accessibility Report",
            in: CGRect(x: cardRect.minX + 50, y: cardRect.minY + 44, width: cardRect.width - 100, height: 60),
            font: .systemFont(ofSize: 40, weight: .bold),
            color: .label
        )

        let startY = cardRect.minY + 130
        let rowH: CGFloat = 74

        drawKeyValue("Vision Mode", visionModeName, y: startY + rowH * 0)
        drawKeyValue("Non-color cue", patternName, y: startY + rowH * 1)
        drawKeyValue("Cue intensity", String(format: "%.0f%%", min(max(intensity, 0), 1) * 100), y: startY + rowH * 2)
        drawKeyValue("Contrast (A:B)", String(format: "%.2f : 1", contrastRatio), y: startY + rowH * 3)

        drawText(
            "Tip: Use contrast + labels + patterns — not color alone.",
            in: CGRect(x: cardRect.minX + 50, y: cardRect.maxY - 110, width: cardRect.width - 100, height: 60),
            font: .systemFont(ofSize: 26, weight: .semibold),
            color: UIColor.secondaryLabel
        )

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    // MARK: - Helpers (drawing)
    private func drawText(_ text: String, in rect: CGRect, font: UIFont, color: UIColor) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ]
        (text as NSString).draw(in: rect, withAttributes: attrs)
    }

    private func drawKeyValue(_ key: String, _ value: String, y: CGFloat) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        defer { ctx.restoreGState() }

        let leftX: CGFloat = 120
        let rightX: CGFloat = 520

        drawText(
            key,
            in: CGRect(x: leftX, y: y, width: 360, height: 60),
            font: .systemFont(ofSize: 28, weight: .semibold),
            color: .label
        )
        drawText(
            value,
            in: CGRect(x: rightX, y: y, width: 600, height: 60),
            font: .systemFont(ofSize: 28, weight: .regular),
            color: .label
        )
    }

    private func drawChip(_ text: String, at origin: CGPoint, width: CGFloat, height: CGFloat) {
        let rect = CGRect(x: origin.x, y: origin.y, width: width, height: height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 14)
        UIColor.tertiarySystemBackground.setFill()
        path.fill()

        drawText(
            text,
            in: rect.insetBy(dx: 14, dy: 6),
            font: .systemFont(ofSize: 18, weight: .semibold),
            color: .secondaryLabel
        )
    }

    private func strokeRoundedRect(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 22)
        UIColor.separator.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
}

// MARK: - UIImage util
private extension UIImage {
    func scaledToFit(in target: CGSize) -> UIImage {
        let aspect = min(target.width / size.width, target.height / size.height)
        let newSize = CGSize(width: size.width * aspect, height: size.height * aspect)

        UIGraphicsBeginImageContextWithOptions(target, true, scale)
        defer { UIGraphicsEndImageContext() }

        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: target))

        let origin = CGPoint(x: (target.width - newSize.width) / 2, y: (target.height - newSize.height) / 2)
        draw(in: CGRect(origin: origin, size: newSize))

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
