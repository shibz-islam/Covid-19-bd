//
//  Color+Helper.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/26/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var themeMintCreme: UIColor {
        return UIColor(red: CGFloat(245/255.0), green: CGFloat(255/255.0), blue: CGFloat(250/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeLightGreen: UIColor {
        return UIColor(red: CGFloat(240/255.0), green: CGFloat(255/255.0), blue: CGFloat(240/255.0), alpha: CGFloat(1.0))
    }
    
    static var themePaleGreen: UIColor {
        return UIColor(red: CGFloat(144/255.0), green: CGFloat(238/255.0), blue: CGFloat(144/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeLightSkyBlue: UIColor {
        return UIColor(red: CGFloat(240/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeLightOrange: UIColor {
        return UIColor(red: CGFloat(255/255.0), green: CGFloat(245/255.0), blue: CGFloat(238/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeDarkOrange: UIColor {
        return UIColor(red: CGFloat(230/255.0), green: CGFloat(126/255.0), blue: CGFloat(34/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeDarkRed: UIColor {
        return UIColor(red: CGFloat(178/255.0), green: CGFloat(34/255.0), blue: CGFloat(34/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeSlateGray: UIColor {
        return UIColor(red: CGFloat(112/255.0), green: CGFloat(128/255.0), blue: CGFloat(144/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeLightSlateGray: UIColor {
        return UIColor(red: CGFloat(119/255.0), green: CGFloat(136/255.0), blue: CGFloat(153/255.0), alpha: CGFloat(1.0))
    }
    
    static var themeWhiteSmoke: UIColor {
        return UIColor(red: CGFloat(245/255.0), green: CGFloat(245/255.0), blue: CGFloat(245/255.0), alpha: CGFloat(1.0))
    }
    
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}
