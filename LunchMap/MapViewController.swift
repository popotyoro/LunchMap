//
//  MapViewController.swift
//  LunchMap
//
//  Created by popota on 2016/11/01.
//  Copyright © 2016年 popota. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var newLocationAnnotation:MKPointAnnotation? = nil

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
        
        mapView.userLocation.title = "現在位置を登録する"
        
        let coodinate = mapView.userLocation.coordinate
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        let region = MKCoordinateRegionMake(coodinate, span)
        
        mapView.setRegion(region, animated: true)
        
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        // 長押しのUIGestureRecognizerを生成
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.recognizeLongPress(sender:)))
        
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
        if let lastAnnotaion = newLocationAnnotation {
            // 既にピンがある場合は取り除く
            mapView.removeAnnotation(lastAnnotaion)
        }
        
        // 長押しした地点の座標を取得
        let location:CGPoint = sender.location(in: mapView)
        
        // ピンを作成
        let newPin = MKPointAnnotation()
        
        newPin.coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        newPin.title = "この地点を登録する"
        
        // ピンを保持
        newLocationAnnotation = newPin
        
        // 地図にピンをぶっ刺す
        mapView.addAnnotation(newPin)
        
        // ピンにフォーカスを当てる
        mapView.setCenter(newPin.coordinate, animated: true)
    
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
        
        var newAnnotaionView:MKAnnotationView
        var newAnnotaionViewIdentifier:String
        
        if let _ = annotation as? MKUserLocation {
            // 現在地を表示する場合
            newAnnotaionViewIdentifier = "UserLocationIdentifier"
            newAnnotaionView = MKAnnotationView(annotation: annotation, reuseIdentifier:newAnnotaionViewIdentifier)
            newAnnotaionView.image = UIImage(named: "ic_my_location")
            
        } else {
            
            newAnnotaionViewIdentifier = "NewPinAnnotationIdentfier"
            newAnnotaionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: newAnnotaionViewIdentifier)
            (newAnnotaionView as! MKPinAnnotationView).animatesDrop = true
        }
        
        newAnnotaionView.canShowCallout = true
        newAnnotaionView.annotation = annotation
        
        let registerButton: UIButton = UIButton(type: .contactAdd)
        registerButton.setImage(UIImage(named: "ic_local_dining"), for: .normal)
        registerButton.addTarget(self, action: #selector(MapViewController.onClickMyButton(sender:)), for: .touchUpInside)
        newAnnotaionView.rightCalloutAccessoryView = registerButton
        
        return newAnnotaionView
        
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        if let _ = newLocationAnnotation {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                mapView.selectAnnotation(self.newLocationAnnotation!, animated: true)
            }
        }
        
    }
    
    // MARK: UIButton Method
    internal func onClickMyButton(sender:UIButton) {
        // FirebaseにLocationを登録する
        // データベースへの参照
        let rootRef = FIRDatabase.database().reference()
        let coordinateRef = rootRef.child("location").child("coordinate")
        coordinateRef.child("latitude").setValue(newLocationAnnotation?.coordinate.latitude)
        coordinateRef.child("longitude").setValue(newLocationAnnotation?.coordinate.longitude)

    }
}

