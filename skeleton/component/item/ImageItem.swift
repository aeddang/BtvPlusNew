//
//  ImageItem.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageItem: PageComponent, Identifiable {
    let id = UUID().uuidString
    let imagePath: String
    var body: some View {
        ImageView(url:imagePath, contentMode: .fill)
    }
}

struct ResourceItem: PageComponent, Identifiable {
    let id = UUID().uuidString
    let asset: String
    var body: some View {
        Image(asset)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
