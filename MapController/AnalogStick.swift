//
//  AnalogStick.swift
//  MapController
//
//  Created by Gelbhaubenkakadu on 2016/8/10.
//  Copyright © 2016年 Apacer. All rights reserved.
//

import UIKit

@IBDesignable
class AnalogStick: UIButton {
    @IBInspectable var fillColor: UIColor = UIColor.lightGray
    @IBInspectable var isAddButton: Bool = true
    
    override func draw(_ rect: CGRect) {
        // 畫圈
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
        
        // 畫橫
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        let plusPath = UIBezierPath()
        
        plusPath.lineWidth = plusHeight
        
        plusPath.move(to: CGPoint(x: bounds.width / 2 - plusWidth / 2 + 0.5, y: bounds.height / 2 + 0.5))
        plusPath.addLine(to: CGPoint(x: bounds.width / 2 + plusWidth / 2 + 0.5, y: bounds.height / 2 + 0.5))
        
        // 畫直
        if isAddButton {
            plusPath.lineWidth = plusHeight
            
            plusPath.move(to: CGPoint(x: bounds.width / 2 + 0.5, y: bounds.height / 2 - plusWidth / 2 + 0.5))
            plusPath.addLine(to: CGPoint(x: bounds.width / 2 + 0.5, y: bounds.height / 2 + plusWidth / 2 + 0.5))
        }
        
        UIColor.white.setStroke()
        
        plusPath.stroke()
    }
}
