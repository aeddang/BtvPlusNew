//
//  LocationObserver.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/07.
//

import Foundation
import CoreLocation

enum LocationObserverEvent {
    case updateAuthorization(CLAuthorizationStatus)
}
class LocationObserver: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let  locationManager = CLLocationManager()
    @Published var event: LocationObserverEvent? = nil
    {
        didSet{
            if self.event == nil { return }
            self.event = nil
        }
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    var status:CLAuthorizationStatus {
        get{ return CLLocationManager.authorizationStatus() }
    }
    
    func requestWhenInUseAuthorization(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.event = .updateAuthorization(status)
    }
    
}
