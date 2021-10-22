//
//  ImageProcessor.swift
//  StickerCreator
//
//  Created by g.lofrumento on 23/10/21.
//

import Foundation
import SwiftUI

class ImageProcessor {
    
    static func process(uiImage: UIImage, window: CGRect) -> Data? {
        let side = 512.0
        let maxWeight = 500_000
        
        let cgImage = uiImage.cgImage!
        let cropped = cgImage.cropping(to: window.applying(CGAffineTransform(translationX: -window.width/2, y: -window.height/2)))!
        let croppedUI = UIImage(cgImage: cropped)
        
        let maxSide = max(cropped.width, cropped.height)
        let ratio = side / Double(maxSide)
        let newSize = CGSize(width: CGFloat(cropped.width)*ratio, height: CGFloat(cropped.height)*ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        croppedUI.draw(in: CGRect(origin: .zero, size: newSize))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        
        var compressed: Data?
        for i in stride(from: CGFloat(1.0), to: 0, by: -0.1) {
            print(i)
            if let jpg = image.jpegData(compressionQuality: i) {
                if Int64(jpg.count) < maxWeight {
                    compressed = jpg
                    break
                }
            }
        }
        
        guard compressed != nil, let result = UIImage(data: compressed!)?.pngData() else {
            return nil
        }
        
        return result
    }
}
