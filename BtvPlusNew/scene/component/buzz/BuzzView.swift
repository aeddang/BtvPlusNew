//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI

struct BuzzView {
    @ObservedObject var viewModel:BuzzViewModel
}
 
extension BuzzView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<BuzzView>) -> BuzzvilCustomFeedVC {
        
        let feedVc = BuzzvilCustomFeedVC(nibName: String(describing: BuzzvilCustomFeedVC.self), bundle: nil)
        feedVc.viewModel = viewModel 
        return feedVc
    }
    func updateUIViewController(_ uiViewController: BuzzvilCustomFeedVC, context: UIViewControllerRepresentableContext<BuzzView>) {
    }
}
