//
//  Extensions.swift
//  StickerCreator
//
//  Created by g.lofrumento on 16/10/21.
//

import SwiftUI

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension CGPoint {
    static let middleScreen = CGPoint(x: UIScreen.screenWidth/2, y: UIScreen.screenHeight/2)
}
