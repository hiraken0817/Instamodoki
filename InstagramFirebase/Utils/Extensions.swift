//
//  Extensions.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/01/15.
//

import UIKit

//MARK:色に関するExtension
extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainPurple() -> UIColor{
        return UIColor.rgb(red: 101, green: 50, blue: 255)
    }
    
    static func subPurple() -> UIColor{
        return UIColor.rgb(red: 178, green: 153, blue: 255)
    }
}

//MARK:レイアウトに関するExtension
extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?,
                left: NSLayoutXAxisAnchor?,
                bottom:NSLayoutYAxisAnchor?,
                right:NSLayoutXAxisAnchor?,
                paddingTop: CGFloat,
                paddingLeft:CGFloat,
                paddingBottom:CGFloat,
                paddingRight:CGFloat,
                width:CGFloat,
                height:CGFloat){
        
        self.translatesAutoresizingMaskIntoConstraints = false//AutoresizingMaskの設定値をAuto Layoutの制約に変換しない
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left{
            self.leftAnchor.constraint(equalTo: left,constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right{
            self.rightAnchor.constraint(equalTo: right,constant: -paddingRight).isActive = true
        }
        
        if width != 0{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "秒"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "分"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "時間"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "日"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "週間"
        } else {
            quotient = secondsAgo / month
            unit = "月"
        }
        
        return "\(quotient)\(unit)前"
        
    }
}




