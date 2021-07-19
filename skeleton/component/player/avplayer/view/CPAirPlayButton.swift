//
//  CPAirPlayButton.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/28.
//

import Foundation
import SwiftUI
import AVKit

struct CPAirPlayButton: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let routePickerView = AVRoutePickerView()
        routePickerView.backgroundColor = UIColor.clear
        routePickerView.activeTintColor = UIColor.red
        routePickerView.tintColor = UIColor.white
        return routePickerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    
    }
}
