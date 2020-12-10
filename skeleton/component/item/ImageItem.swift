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
    let imageNamed: String
    var body: some View {
        ImageView(url:imageNamed, contentMode: .fill)
            .clipped()
    }
}
