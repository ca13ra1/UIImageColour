//
//  UIColor.swift
//
//
//  Created by colecabral on 2024-08-31.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
    
    func isContrasting(with color: UIColor) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let bLum = 0.2126 * r1 + 0.7152 * g1 + 0.0722 * b1
        let fLum = 0.2126 * r2 + 0.7152 * g2 + 0.0722 * b2
        let contrast = bLum > fLum ? (bLum + 0.05) / (fLum + 0.05) : (fLum + 0.05) / (bLum + 0.05)
        return contrast > 1.6
    }
}

#endif
