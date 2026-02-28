//
//  VisionSimulationService.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum VisionMode: String, CaseIterable {
    case normal = "Normal"  // 일반
    case protanopia = "Protanopia"  // 적색맹
    case deuteranopia = "Deuteranopia"  // 녹색맹
    case tritanopia = "Tritanopia"  // 청색맹
    case achromatopsia = "Achromatopsia"    // 전색맹
}

final class VisionSimulationService {
    
    private let context = CIContext()
    
    func simulate(image: UIImage, mode: VisionMode) -> UIImage {
        guard mode != .normal else { return image }
        guard let ciImage = CIImage(image: image) else { return image }
        
        let filter = CIFilter.colorMatrix()
        filter.inputImage = ciImage
        
        switch mode {
        case .protanopia:
            filter.rVector = CIVector(x: 0.567, y: 0.433, z: 0, w: 0)
            filter.gVector = CIVector(x: 0.558, y: 0.442, z: 0, w: 0)
            filter.bVector = CIVector(x: 0, y: 0.242, z: 0.758, w: 0)
            
        case .deuteranopia:
            filter.rVector = CIVector(x: 0.625, y: 0.375, z: 0, w: 0)
            filter.gVector = CIVector(x: 0.7, y: 0.3, z: 0, w: 0)
            filter.bVector = CIVector(x: 0, y: 0.3, z: 0.7, w: 0)
            
        case .tritanopia:
            filter.rVector = CIVector(x: 0.95, y: 0.05, z: 0, w: 0)
            filter.gVector = CIVector(x: 0, y: 0.433, z: 0.567, w: 0)
            filter.bVector = CIVector(x: 0, y: 0.475, z: 0.525, w: 0)
            
        case .achromatopsia:
            filter.rVector = CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0)
            filter.gVector = CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0)
            filter.bVector = CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0)
            
        case .normal:
            break
        }
        
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func render(drawing: PKDrawing, size: CGSize) -> UIImage {
        return drawing.image(from: CGRect(origin: .zero, size: size), scale: 1.0)
    }

    func render(drawing: PKDrawing, rect: CGRect) -> UIImage {
        return drawing.image(from: rect, scale: 1.0)
    }
}
