//
//  FirstViewController.swift
//  LunchMap
//
//  Created by popota on 2016/11/01.
//  Copyright © 2016年 popota. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 現在地情報が使用できるかチェックする
        startUpUserLocation()
        
        // 地図設定
        setUpMapSettings()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Private Method
    /**
     ## 地図の設定を行う
     * coordinate   : UserLocation
     * span         : 0.01 0.01
     */
    private func setUpMapSettings() {
        
        let coodinate = mapView.userLocation.coordinate
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        let region = MKCoordinateRegionMake(coodinate, span)
        
        mapView.setRegion(region, animated: true)
        
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        // 長押しのUIGestureRecognizerを生成
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FirstViewController.recognizeLongPress(sender:)))
        
        mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    /**
     ## 現在地の情報を使用開始
     */
    private func startUpUserLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - GestureRecognizer Method
    func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        
        // 長押しの最中に何度もピンを生成しないようにする
        if sender.state != .began {
            return
        }
        
        // 長押しした地点の座標を取得
        let location:CGPoint = sender.location(in: mapView)
        
        // ピンを作成
        let newPin = MKPointAnnotation()
        
        newPin.coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        newPin.title = "新しい地点"
        
        // 地図にピンをぶっ刺す
        mapView.addAnnotation(newPin)
    }
    
    // MARK: - CLLocationManagerDelegate Method
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // LocationServiceの使用許可を得る
            manager.requestWhenInUseAuthorization()
        default: break
        }
    }
    
    // MARK: - MKMapViewDelegate Method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let _ = annotation as? MKUserLocation {
            // 現在地を表示する場合は何もしない
            return nil
        }
        
        let newPinIdentifier = "NewPinAnnotationIdentfier"
        
        let newPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: newPinIdentifier)
        
        newPinView.animatesDrop = true
        newPinView.canShowCallout = true
        newPinView.annotation = annotation
        
        return newPinView
        
    }
}

