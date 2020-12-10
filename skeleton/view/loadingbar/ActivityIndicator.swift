//
//  ActivityIndicator.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    var style:UIActivityIndicatorView.Style = .medium
    var color:Color = .white
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let v = UIActivityIndicatorView(style : style)
        v.color = Color.app.grey.uiColor()
        return v
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
