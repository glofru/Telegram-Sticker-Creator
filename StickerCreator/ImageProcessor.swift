//
//  ImageProcessor.swift
//  StickerCreator
//
//  Created by g.lofrumento on 23/10/21.
//

import Foundation
import SwiftUI

class ImageProcessor {
    
    static func process(uiImage: UIImage, window: CGRect) -> URL? {
        let side = 512.0
        let maxWeight = 500_000
        
        guard let cgImage = uiImage.cgImage else {
            print("Failed converting to CGImage")
            return nil
        }
        guard let cropped = cgImage.cropping(to: window.applying(CGAffineTransform(translationX: -window.width/2, y: -window.height/2))) else {
            print("Failed cropping")
            return nil
        }
        let croppedUI = UIImage(cgImage: cropped)
        
        let maxSide = max(cropped.width, cropped.height)
        let ratio = side / Double(maxSide)
        let newSize = CGSize(width: CGFloat(cropped.width)*ratio, height: CGFloat(cropped.height)*ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        croppedUI.draw(in: CGRect(origin: .zero, size: newSize))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Failed resizing")
            return nil
        }
        UIGraphicsEndImageContext()
        
        var compressed: Data?
        for i in stride(from: CGFloat(1.0), to: 0, by: -0.1) {
            if let jpg = image.jpegData(compressionQuality: i), Int64(jpg.count) < maxWeight {
                compressed = jpg
                break
            }
        }
        
        compressed = UIImage(data: compressed!)?.pngData()
        
        guard compressed != nil else {
            print("Failed converting to PNG")
            return nil
        }
        
        let fileName = "sticker.png"
        let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try compressed!.write(to: temporaryFileURL)
        } catch {
            return nil
        }
        
        return temporaryFileURL
    }
}
