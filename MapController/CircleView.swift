//
//  CircleView.swift
//  MapController
//
//  Created by Gelbhaubenkakadu on 2016/8/10.
//  Copyright © 2016年 Apacer. All rights reserved.
//

import UIKit

let π: CGFloat = CGFloat(M_PI)

@IBDesignable
class CircleView: UIView {
    @IBInspectable var fillColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var counter: Int = 5
    @IBInspectable var outlineColor: UIColor = UIColor.blueColor()
    @IBInspectable var counterColor: UIColor = UIColor.orangeColor()
 
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width, bounds.height)
        let arcWidth: CGFloat = 3
        let startAngle: CGFloat = π
        let endAngle: CGFloat = π - 0.00000001
        
        let path = UIBezierPath(arcCenter: center, radius: radius / 2 - arcWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        fillColor.setFill()
        path.fill()
        
        path.lineWidth = arcWidth
        path.stroke()
    }
    
}
