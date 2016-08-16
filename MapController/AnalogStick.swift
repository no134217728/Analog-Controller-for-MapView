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
    @IBInspectable var fillColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var isAddButton: Bool = true
    
    override func drawRect(rect: CGRect) {
        // 畫圈
        let path = UIBezierPath(ovalInRect: rect)
        fillColor.setFill()
        path.fill()
        
        // 畫橫
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        let plusPath = UIBezierPath()
        
        plusPath.lineWidth = plusHeight
        
        plusPath.moveToPoint(CGPoint(x: bounds.width / 2 - plusWidth / 2 + 0.5, y: bounds.height / 2 + 0.5))
        plusPath.addLineToPoint(CGPoint(x: bounds.width / 2 + plusWidth / 2 + 0.5, y: bounds.height / 2 + 0.5))
        
        // 畫直
        if isAddButton {
            plusPath.lineWidth = plusHeight
            
            plusPath.moveToPoint(CGPoint(x: bounds.width / 2 + 0.5, y: bounds.height / 2 - plusWidth / 2 + 0.5))
            plusPath.addLineToPoint(CGPoint(x: bounds.width / 2 + 0.5, y: bounds.height / 2 + plusWidth / 2 + 0.5))
        }
        
        UIColor.whiteColor().setStroke()
        
        plusPath.stroke()
    }
}
