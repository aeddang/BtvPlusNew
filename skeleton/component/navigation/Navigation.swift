//
//  Navigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

open class NavigationModel: ObservableObject {
    @Published var selected:String? = nil
    @Published var index = 0
}

struct NavigationButton: Identifiable {
    var id:String = UUID().uuidString
    var body:AnyView? = nil
    var idx = -1
    var frame:CGSize = CGSize(width:100, height: 100)
}

struct NavigationBuilder{
    var index: Int
    var textModifier:TextModifier = TextModifier(
        family:Font.family.medium,
        size: Font.size.regular,
        color: Color.app.grey,
        activeColor: Color.brand.primary
    )
    var marginH:CGFloat = 0
    var marginV:CGFloat = Dimen.margin.thin
   
    
    func getNavigationButtons(texts:[String]) -> [NavigationButton] {
        let range = 0 ..< texts.count
        return zip(range, texts).map {index, text in
            self.createButton(txt:text, idx:index)
        }
    }
    func getNavigationButtons(images:[String], size:CGSize) -> [NavigationButton] {
        let range = 0 ..< images.count
        return zip(range, images).map {index, image in
            self.createButton(img:image, idx:index, size: size)
        }
    }
    func getNavigationButtons(images:[(String,String)], size:CGSize) -> [NavigationButton] {
        let range = 0 ..< images.count
        return zip(range, images).map {index, image in
            self.createButton(img:image, idx:index, size: size)
        }
    }
    
    private func createButton(txt:String, idx:Int) -> NavigationButton {
        let size = txt.textSizeFrom( fontSize: textModifier.size )
        return NavigationButton(
            id: UUID.init().uuidString,
            body: AnyView(
                Text(txt)
                    .font(.custom(Font.family.black, size: textModifier.size))
                    .foregroundColor(self.index != idx ? textModifier.color : textModifier.activeColor)
                    .modifier(MatchParent())
            ),
            idx:idx,
            frame: CGSize (
                width: size.width * textModifier.sizeScale + (marginH*2.0),
                height: size.height * textModifier.sizeScale + (marginV*2.0)
            )
            
        )
    }
    private func createButton(img:String, idx:Int, size:CGSize) -> NavigationButton {
        return NavigationButton(
            id: UUID.init().uuidString,
            body: AnyView(
                Image(img)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width:size.width, height: size.height)
            ),
            idx:idx,
            frame: CGSize (
                width: size.width + (marginH*2.0),
                height: size.height + (marginV*2.0)
            )
        )
    }
    private func createButton(img:(String,String), idx:Int, size:CGSize) -> NavigationButton {
        return NavigationButton(
            id: UUID.init().uuidString,
            body: AnyView(
                Image(self.index != idx ? img.0 : img.1)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width:size.width, height: size.height)
            ),
            idx:idx,
            frame: CGSize (
                width: size.width + (marginH*2.0),
                height: size.height + (marginV*2.0)
            )
        )
    }
    
}
