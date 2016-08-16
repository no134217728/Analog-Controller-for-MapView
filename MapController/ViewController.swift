//
//  ViewController.swift
//  MapController
//
//  Created by Gelbhaubenkakadu on 2016/8/10.
//  Copyright © 2016年 Apacer. All rights reserved.
// https://github.com/hehonghui/iOS-tech-frontier/blob/master/issue-5/Swift-Core-Graphics%E6%95%99%E7%A8%8B%E7%AC%AC%E4%B8%80%E9%83%A8%E5%88%86.md
// http://stackoverflow.com/questions/26530546/track-mkmapview-rotation

// http://stackoverflow.com/questions/23122173/mapview-detect-scrolling http://stackoverflow.com/questions/24103691/how-to-set-up-game-loop-in-swift

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var btnAnalog: AnalogStick!
    @IBOutlet var viewCircle: CircleView!
    @IBOutlet var mainMap: MKMapView!
    
    var buttonCenter = CGPointZero
    var location:CGPoint = CGPointZero
    var maxDistance:CGFloat = 0
    var mapHeading: CLLocationDirection = 0.0
    let currentLocationMgr: CLLocationManager = CLLocationManager()
    var annotation: MKPointAnnotation = MKPointAnnotation()
    var isMove: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(_:)))
        btnAnalog.addGestureRecognizer(pan)

        maxDistance = max(viewCircle.frame.size.width / 2, viewCircle.frame.size.height / 2)
        
        mainMap.delegate = self;
        currentLocationMgr.delegate = self
        currentLocationMgr.requestWhenInUseAuthorization()
        currentLocationMgr.startUpdatingLocation()
        currentLocationMgr.distanceFilter = CLLocationDistanceMax
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let c = locations[0] as CLLocation
        let nowLoc = CLLocationCoordinate2D(latitude: c.coordinate.latitude, longitude: c.coordinate.longitude)
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        mainMap.setRegion(MKCoordinateRegion(center: nowLoc, span: span), animated: true)
        
        annotation.coordinate = nowLoc
        annotation.title = "Lat: \(NSString(format: "%.5f", nowLoc.latitude)), Lon: \(NSString(format: "%.5f", nowLoc.longitude))"
        mainMap.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapHeading = mainMap.camera.heading
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func panButton(pan: UIPanGestureRecognizer) {
        location = pan.locationInView(view)
        maxDistance = max(viewCircle.frame.size.width / 2, viewCircle.frame.size.height / 2)

        switch pan.state {
        case .Began:
            isMove = true
            move()
            buttonCenter = btnAnalog.center
        case .Ended, .Failed, .Cancelled:
            isMove = false
            btnAnalog.center = buttonCenter
        default:
            isMove = true
            
            // 讓香菇頭卡在邊緣
            let realDistantion = sqrt(pow(location.x - viewCircle.center.x, 2) + pow(location.y - viewCircle.center.y, 2))
            
            let needPosition: CGPoint
            if realDistantion <= maxDistance {
                needPosition = CGPoint(x: location.x, y: location.y)
            } else {
                needPosition = CGPoint(x: (location.x - buttonCenter.x) / realDistantion * maxDistance + buttonCenter.x, y: (location.y - buttonCenter.y) / realDistantion * maxDistance + buttonCenter.y)
            }
            
            btnAnalog.center = needPosition
        }
    }
    
    func move() {
        if isMove {
            var accelerateLonX: CGFloat = 1 // 經度加速度比例
            var accelerateLatY: CGFloat = 1 // 緯度加速度比例
            
            // 實際移動點
            // 計算加速度與方向（修正角度版）
            let toRadian:Double = M_PI / 180 // 轉弧度
            let toDegree:Double = 180 / M_PI // 轉角度
            let distance:CGFloat = sqrt(pow(location.x - viewCircle.center.x, 2) + pow(location.y - viewCircle.center.y, 2))
            
            let deltaLonX: CGFloat = location.x - viewCircle.center.x
            let deltaLatY: CGFloat = viewCircle.center.y - location.y
            let radianOri:Double = atan2(Double(deltaLonX), Double(deltaLatY))
            let degreeOri:Double = radianOri * toDegree
            
            let newDegree:Double = degreeOri + mapHeading
            let newDeltaLonX:CGFloat = distance * CGFloat(sin(newDegree * toRadian))
            let newDeltaLatY:CGFloat = distance * CGFloat(cos(newDegree * toRadian))
            accelerateLonX = max(min(newDeltaLonX, maxDistance), maxDistance * -1)
            accelerateLatY = max(min(newDeltaLatY, maxDistance), maxDistance * -1)
            
            // 計算加速度與方向（不修正角度版）
            //        let deltaLonX: CGFloat = location.x - viewCircle.center.x
            //        let deltaLatY: CGFloat = viewCircle.center.y - location.y
            //        accelerateLonX = max(min(deltaLonX, maxDistance), maxDistance * -1)
            //        accelerateLatY = max(min(deltaLatY, maxDistance), maxDistance * -1)
            
            annotation.coordinate.longitude = annotation.coordinate.longitude + (0.000005 * Double(accelerateLonX))
            annotation.coordinate.latitude = annotation.coordinate.latitude + (0.000005 * Double(accelerateLatY))
            // MARK: 多此行後，香菇頭就會一直跳回原位，無法理解
//            annotation.title = "Lat: \(NSString(format: "%.5f", annotation.coordinate.latitude)), Lon: \(NSString(format: "%.5f", annotation.coordinate.longitude))"
            self.performSelector(#selector(move), withObject: nil, afterDelay: 0.01)
        }
    }
}
