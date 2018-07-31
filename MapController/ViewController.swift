//
//  ViewController.swift
//  MapController
//
//  Created by Gelbhaubenkakadu on 2016/8/10.
//  Copyright © 2016年 Apacer. All rights reserved.
// 
// https://github.com/hehonghui/iOS-tech-frontier/blob/master/issue-5/Swift-Core-Graphics%E6%95%99%E7%A8%8B%E7%AC%AC%E4%B8%80%E9%83%A8%E5%88%86.md
// http://stackoverflow.com/questions/26530546/track-mkmapview-rotation
// http://stackoverflow.com/questions/23122173/mapview-detect-scrolling http://stackoverflow.com/questions/24103691/how-to-set-up-game-loop-in-swift
// https://developers.google.com/maps/documentation/ios-sdk/intro
// http://stackoverflow.com/questions/4189621/setting-the-zoom-level-for-a-mkmapview

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var leftCircleView: CircleView!
    @IBOutlet var leftAnalogBtn: AnalogStick!
    @IBOutlet var rightCircleView: CircleView!
    @IBOutlet var rightAnalogBtn: AnalogStick!
    @IBOutlet var mainMap: MKMapView!
    @IBOutlet var segMethodWahlen: UISegmentedControl!
    
    var locationLeft:CGPoint = CGPoint.zero
    var locationRight:CGPoint = CGPoint.zero
    var maxDistance:CGFloat = 0
    var calculateMethod: NSInteger = 0
    
    var mapHeading: CLLocationDirection = 0.0
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var currentSpan: MKCoordinateSpan = MKCoordinateSpan()
    var currentViewDistance: Double = 1;
    var currentZoomLevel: Double = 1
    let currentLocationMgr: CLLocationManager = CLLocationManager()
    
    var annotation: MKPointAnnotation = MKPointAnnotation()
    
    var isMove: Bool = false
    var isChangeView: Bool = false
    
    var leftButtonCenter = CGPoint.zero
    var rightButtonCenter = CGPoint.zero
    
    @IBAction func selectMethod(_ sender: AnyObject) {
        calculateMethod = segMethodWahlen.selectedSegmentIndex
        renewCurrentValue(mainMap)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let panLeft = UIPanGestureRecognizer(target: self, action: #selector(panLeftButton(_:)))
        leftAnalogBtn.addGestureRecognizer(panLeft)
        let panRight = UIPanGestureRecognizer(target: self, action: #selector(panRightButton(_:)))
        rightAnalogBtn.addGestureRecognizer(panRight)

        maxDistance = max(leftCircleView.frame.size.width / 2, leftCircleView.frame.size.height / 2)
        
        mainMap.delegate = self;
        
        currentLocationMgr.delegate = self
        currentLocationMgr.requestWhenInUseAuthorization()
        currentLocationMgr.startUpdatingLocation()
        currentLocationMgr.distanceFilter = CLLocationDistanceMax
        
        calculateMethod = segMethodWahlen.selectedSegmentIndex
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let c = locations[0] as CLLocation
        let nowLoc = CLLocationCoordinate2D(latitude: c.coordinate.latitude, longitude: c.coordinate.longitude)
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        mainMap.setRegion(MKCoordinateRegion(center: nowLoc, span: span), animated: true)
        
        annotation.coordinate = nowLoc
        annotation.title = "Lat: \(NSString(format: "%.5f", nowLoc.latitude)), Lon: \(NSString(format: "%.5f", nowLoc.longitude))"
        mainMap.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !isChangeView { // 由程式改變視角時，有些值會跑掉，所以用此法來避掉轉右香菇頭時重新寫入一些參數
            renewCurrentValue(mapView)
        }
    }
    
    func renewCurrentValue(_ mapView: MKMapView) -> Void {
        let mRect: MKMapRect = mapView.visibleMapRect
        let eastMapPoint: MKMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
        let westMapPoint: MKMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
        currentViewDistance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
        
        mapHeading = mapView.camera.heading
        currentLocation = mapView.centerCoordinate
        currentSpan = mapView.region.span
        currentZoomLevel = self.zoomLevel()
    }

    func panLeftButton(_ pan: UIPanGestureRecognizer) {
        locationLeft = pan.location(in: view)
        maxDistance = max(leftCircleView.frame.size.width / 2, leftCircleView.frame.size.height / 2)

        switch pan.state {
        case .began:
            isMove = true
            move()
            leftButtonCenter = leftAnalogBtn.center
        case .ended, .failed, .cancelled:
            isMove = false
            leftAnalogBtn.center = leftButtonCenter
            
            annotation.title = "Lat: \(NSString(format: "%.5f", annotation.coordinate.latitude)), Lon: \(NSString(format: "%.5f", annotation.coordinate.longitude))"
        default:
            isMove = true
            
            // 讓香菇頭卡在邊緣
            let realDistantion = sqrt(pow(locationLeft.x - leftCircleView.center.x, 2) + pow(locationLeft.y - leftCircleView.center.y, 2))
            
            let needPosition: CGPoint
            if realDistantion <= maxDistance {
                needPosition = CGPoint(x: locationLeft.x, y: locationLeft.y)
            } else {
                needPosition = CGPoint(x: (locationLeft.x - leftButtonCenter.x) / realDistantion * maxDistance + leftButtonCenter.x, y: (locationLeft.y - leftButtonCenter.y) / realDistantion * maxDistance + leftButtonCenter.y)
            }
            
            leftAnalogBtn.center = needPosition
        }
    }
    
    func panRightButton(_ pan: UIPanGestureRecognizer) {
        locationRight = pan.location(in: view)
        maxDistance = max(rightCircleView.frame.size.width / 2, rightCircleView.frame.size.height / 2)
        
        switch pan.state {
        case .began:
            isChangeView = true
            changeView()
            rightButtonCenter = rightAnalogBtn.center
        case .ended, .failed, .cancelled:
            isChangeView = false
            rightAnalogBtn.center = rightButtonCenter
        default:
            isChangeView = true
            
            // 讓香菇頭卡在邊緣
            let realDistantion = sqrt(pow(locationRight.x - rightCircleView.center.x, 2) + pow(locationRight.y - rightCircleView.center.y, 2))
            
            let needPosition: CGPoint
            if realDistantion <= maxDistance {
                needPosition = CGPoint(x: locationRight.x, y: locationRight.y)
            } else {
                needPosition = CGPoint(x: (locationRight.x - rightButtonCenter.x) / realDistantion * maxDistance + rightButtonCenter.x, y: (locationRight.y - rightButtonCenter.y) / realDistantion * maxDistance + rightButtonCenter.y)
            }
            
            rightAnalogBtn.center = needPosition
        }
    }
    
    func move() {
        if isMove {
            var accelerateLonX: CGFloat = 1 // 經度加速度比例
            var accelerateLatY: CGFloat = 1 // 緯度加速度比例
            
            // 實際移動點
            // 計算加速度與方向（修正角度版）
            let toRadian: Double = M_PI / 180 // 轉弧度
            let toDegree: Double = 180 / M_PI // 轉角度
            let distance: CGFloat = sqrt(pow(locationLeft.x - leftCircleView.center.x, 2) + pow(locationLeft.y - leftCircleView.center.y, 2))
            
            let deltaLonX: CGFloat = locationLeft.x - leftCircleView.center.x
            let deltaLatY: CGFloat = leftCircleView.center.y - locationLeft.y
            let radianOri: Double = atan2(Double(deltaLonX), Double(deltaLatY))
            let degreeOri: Double = radianOri * toDegree
            
            let newDegree: Double = degreeOri + mapHeading
            let newDeltaLonX: CGFloat = distance * CGFloat(sin(newDegree * toRadian))
            let newDeltaLatY: CGFloat = distance * CGFloat(cos(newDegree * toRadian))
            accelerateLonX = max(min(newDeltaLonX, maxDistance), maxDistance * -1) * CGFloat(currentZoomLevel)
            accelerateLatY = max(min(newDeltaLatY, maxDistance), maxDistance * -1) * CGFloat(currentZoomLevel)
            
            // 計算加速度與方向（不修正角度版）
//            let deltaLonX: CGFloat = location.x - viewCircle.center.x
//            let deltaLatY: CGFloat = viewCircle.center.y - location.y
//            accelerateLonX = max(min(deltaLonX, maxDistance), maxDistance * -1)
//            accelerateLatY = max(min(deltaLatY, maxDistance), maxDistance * -1)
            
            annotation.coordinate.longitude = annotation.coordinate.longitude + (0.000005 * Double(accelerateLonX))
            if annotation.coordinate.longitude > 180 {
                annotation.coordinate.longitude = -180
            }
            if annotation.coordinate.longitude < -180 {
                annotation.coordinate.longitude = 180
            }
            
            annotation.coordinate.latitude = max(-90, min(annotation.coordinate.latitude + (0.000005 * Double(accelerateLatY)), 90))
            // MARK: 多此行後，香菇頭就會一直跳回原位，無法理解
//            annotation.title = "Lat: \(NSString(format: "%.5f", annotation.coordinate.latitude)), Lon: \(NSString(format: "%.5f", annotation.coordinate.longitude))"
            self.perform(#selector(move), with: nil, afterDelay: 0.01)
        }
    }
    
    func changeView() {
        if isChangeView {
            // 視線高度
            var accelerateSpan: CGFloat = 1 // 高度變化加速度比例
            let deltaLatY: CGFloat = rightCircleView.center.y - locationRight.y
            accelerateSpan = max(min(deltaLatY, maxDistance), maxDistance * -1) / maxDistance
            
            switch calculateMethod {
            case 0: // 直接 Span 算法，難以掌握易錯亂
                currentSpan.latitudeDelta = max(0.0001, min(currentSpan.latitudeDelta + (0.1 * Double(accelerateSpan) + 0), 180))
                currentSpan.longitudeDelta = max(0.0001, min(currentSpan.longitudeDelta + (0.1 * Double(accelerateSpan) + 0), 180))
                
                let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta, longitudeDelta: currentSpan.longitudeDelta)
                mainMap.setRegion(MKCoordinateRegion(center: currentLocation, span: span), animated: false)
                
                print("currentSpan: \(currentSpan)")
            case 1: // zoomLevel 算法，本質還是基於 Span 算法
                currentZoomLevel = max(0.6, min(currentZoomLevel - (0.1 * Double(accelerateSpan)), 20))
                
                self.setCenterCoordinate(currentLocation, setZoomLevel: currentZoomLevel)
                
                print("currentZoomLevel: \(currentZoomLevel)")
            case 2: // 寬度算法
                currentViewDistance = max(90, min(currentViewDistance * (1 + 0.1 * Double(accelerateSpan)), 18000000))
                
                let viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation, currentViewDistance, currentViewDistance)
                mainMap.setRegion(viewRegion, animated: false)
                
                print("currentViewDistance: \(currentViewDistance)")
            default:
                break
            }
            
//            print("currentSpan: \(currentSpan), currentZoomLevel: \(currentZoomLevel), currentViewDistance: \(currentViewDistance)")
            
            // 地圖角度
            var accelerateHeading: CGFloat = 1 // 轉向變化加速度比例
            let deltaLatX: CGFloat = locationRight.x - rightCircleView.center.x
            accelerateHeading = max(min(deltaLatX, maxDistance), maxDistance * -1) / maxDistance
            mapHeading = mapHeading + (9 * Double(accelerateHeading))
            if mapHeading > 360 {
                mapHeading = 0
            }
            if mapHeading < 0 {
                mapHeading = 359.99
            }
            mainMap.camera.heading = mapHeading
            
            self.perform(#selector(changeView), with: nil, afterDelay: 0.01)
        }
    }
    
    // ZoomLevel 轉換
    func setCenterCoordinate(_ centerCoordinate: CLLocationCoordinate2D, setZoomLevel zoomLevel:Double) -> Void {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0, 360 / pow(2, Double(zoomLevel)) * Double(mainMap.frame.size.width) / 256) // zoomLevel 轉 Span
        mainMap.setRegion(MKCoordinateRegionMake(centerCoordinate, span), animated: false)
    }
    
    func zoomLevel() -> Double { // Span 轉 zoomLevel
        return log2(360 * ((Double(mainMap.frame.size.width) / 256) / mainMap.region.span.longitudeDelta)) + 1
    }
    
    func setZoomLevel(_ zoomLevel: Double) -> Void { // 設定位置與 zoomLevel
        self.setCenterCoordinate(currentLocation, setZoomLevel: zoomLevel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
