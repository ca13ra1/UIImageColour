//
//  UIImage.swift
//
//
//  Created by colecabral on 2024-08-31.
//

#if canImport(UIKit)
import UIKit

public extension UIImage {
    
    func analyzeImage() -> UIImageColour? {
        var imageToAnalyze = self
        if let resizedImage = resizeImageToAnalysisSize(image: self, size: CGSize(width: 25, height: 25)) {
            imageToAnalyze = resizedImage
        }
        guard let context = createBitmapContext(for: imageToAnalyze) else {
            print("Unable to create CGContext!")
            return nil
        }
        let analyzedInfo = analyzeBitmapContext(context)
        return analyzedInfo
    }
    
    func resizeImageToAnalysisSize(image: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func createBitmapContext(for image: UIImage) -> CGContext? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = 8
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        return context
    }
    
    private func analyzeBitmapContext(_ context: CGContext) -> UIImageColour {
        guard let averageColor = averageColor(from: context) else { return UIImageColour(dominantColor: UIColor.clear) }
        
        guard let data = context.data else { return UIImageColour(dominantColor: UIColor.clear) }
        
        let bytesPerRow = context.bytesPerRow
        let height = context.height
        var colorCounts = [UIColor: Int]()
        
        for y in 0..<height {
            for x in 0..<bytesPerRow / 4 {
                let pixelOffset = (y * bytesPerRow) + (x * 4)
                let r = CGFloat(data.load(fromByteOffset: pixelOffset, as: UInt8.self)) / 255.0
                let g = CGFloat(data.load(fromByteOffset: pixelOffset + 1, as: UInt8.self)) / 255.0
                let b = CGFloat(data.load(fromByteOffset: pixelOffset + 2, as: UInt8.self)) / 255.0
                let a = CGFloat(data.load(fromByteOffset: pixelOffset + 3, as: UInt8.self)) / 255.0
                
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                if !color.isContrasting(with: averageColor) {
                    colorCounts[color, default: 0] += 1
                }
            }
        }
        
        guard let dominantColor = colorCounts.max(by: { $0.value < $1.value })?.key else {
            return UIImageColour(dominantColor: UIColor.clear)
        }
        
        return UIImageColour(dominantColor: dominantColor)
    }
    
    
    private func averageColor(from context: CGContext) -> UIColor? {
        guard let data = context.data else { return nil }
        
        let bytesPerRow = context.bytesPerRow
        let height = context.height
        let width = bytesPerRow / 4
        
        var totalR: CGFloat = 0.0
        var totalG: CGFloat = 0.0
        var totalB: CGFloat = 0.0
        var totalA: CGFloat = 0.0
        var pixelCount: CGFloat = 0.0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelOffset = (y * bytesPerRow) + (x * 4)
                let r = CGFloat(data.load(fromByteOffset: pixelOffset, as: UInt8.self)) / 255.0
                let g = CGFloat(data.load(fromByteOffset: pixelOffset + 1, as: UInt8.self)) / 255.0
                let b = CGFloat(data.load(fromByteOffset: pixelOffset + 2, as: UInt8.self)) / 255.0
                let a = CGFloat(data.load(fromByteOffset: pixelOffset + 3, as: UInt8.self)) / 255.0
                
                totalR += r
                totalG += g
                totalB += b
                totalA += a
                pixelCount += 1
            }
        }
        
        guard pixelCount > 0 else { return nil }
        
        return UIColor(
            red: totalR / pixelCount,
            green: totalG / pixelCount,
            blue: totalB / pixelCount,
            alpha: totalA / pixelCount
        )
    }
}
#endif
