//
//  Paint.swift
//
//  Created by Aaron Abentheuer on 17/01/2019.
//  Copyright © 2019 Aaron Abentheuer. All rights reserved.
//

import UIKit

enum FontWeight {
    case regular
    case light
    case medium
    case bold
}

extension UIFont {
    static func ceraFont(ofSize size : CGFloat, Weight weight : FontWeight) -> UIFont {
        
        let fontName = "CeraRoundPro"
        
        var fontWeight = "Regular"
        
        switch weight {
        case .regular:
            fontWeight = "Regular"
        case .medium:
            fontWeight = "Medium"
        case .light:
            fontWeight = "Light"
        case .bold:
            fontWeight = "Bold"
        }
        
        let fontString = "\(fontName)" + "-" + "\(fontWeight)"

        return UIFont(name: fontString, size: size)!
    }
}

extension UIColor {
    static let appropriateOrange = UIColor(named: "appropriate-orange")!
}
