//
//  NetworkObserver.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import Reachability

class NetworkObserver: ObservableObject {
    enum Status {
        case wifi
        case cellular
        case none
    }
    @Published private(set) var status: Status = .none
    
    let reachability = try! Reachability()
    init() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                self.status = .wifi
            } else {
                self.status = .cellular
            }
        }
        reachability.whenUnreachable = { _ in
            self.status = .none
        }
        
        do {
            try reachability.startNotifier()
        } catch {}
    }
        
    deinit {
        reachability.stopNotifier()
    }
}

