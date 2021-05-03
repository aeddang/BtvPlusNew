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
    var data:String = ""
}

struct NavigationBuilder{
    var index: Int = -1
    var textModifier:TextModifier = TextModifier(
        family:Font.family.medium,
        size: Font.size.regular,
        color: Color.app.grey,
        activeColor: Color.brand.primary
    )
    var marginH:CGFloat = 0
    var marginV:CGFloat = Dimen.margin.thin
    var imgSize:CGSize = CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
    
    func getNavigationButtons(texts:[String], color:Color? = nil) -> [NavigationButton] {
        let range = 0 ..< texts.count
        return zip(range, texts).map {index, text in
            self.createButton(txt:text, idx:index, color:color)
        }
    }
    func getNavigationButtons(datas:[(String,String)], size:CGSize? = nil,  color:Color? = nil) -> [NavigationButton] {
        let range = 0 ..< datas.count
        return zip(range, datas ).map {index, data in
            self.createButton(txt:data.0, img:data.1,  idx:index, color:color, size:size)
        }
    }
    func getNavigationButtons(images:[String], size:CGSize? = nil) -> [NavigationButton] {
        let range = 0 ..< images.count
        return zip(range, images).map {index, image in
            self.createButton(img:image, idx:index, size: size)
        }
    }
    func getNavigationButtons(images:[(String,String)], size:CGSize? = nil) -> [NavigationButton] {
        let range = 0 ..< images.count
        return zip(range, images).map {index, image in
            self.createButton(img:image, idx:index, size: size)
        }
    }
    
    private func createButton(txt:String, idx:Int, color:Color? = nil) -> NavigationButton {
        let size = txt.textSizeFrom( fontSize: textModifier.size )
        return NavigationButton(
            id: UUID.init().uuidString,
            body: AnyView(
                Text(txt)
                    .kerning(Font.kern.thin)
                    .font(.custom(Font.family.black, size: textModifier.size))
                    .foregroundColor(self.index != idx ? textModifier.color : (color ?? textModifier.activeColor))
                    .modifier(MatchParent())
            ),
            idx:idx,
            frame: CGSize (
                width: size.width * textModifier.sizeScale + (marginH*2.0),
                height: size.height * textModifier.sizeScale + (marginV*2.0)
            ),
            data:txt
            
        )
    }
    private func createButton(img:String, idx:Int, size:CGSize?) -> NavigationButton {
        let size = size ?? self.imgSize
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
            ),
            data:img
        )
    }
    private func createButton(txt:String, img:String, idx:Int, color:Color? = nil, size:CGSize? = nil) -> NavigationButton {
        let size = size ?? self.imgSize
        return NavigationButton(
            id: UUID.init().uuidString,
            body: AnyView(
                VStack(spacing:Dimen.margin.micro){
                    Image(img)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width:size.width, height: size.height)
                    Text(txt)
                        .font(.custom(Font.family.black, size: textModifier.size))
                        .foregroundColor(self.index != idx ? textModifier.color : (color ?? textModifier.activeColor))
                       
                }
            ),
            idx:idx,
            frame: CGSize (
                width: size.width + (marginH*2.0),
                height: size.height + (marginV*2.0)
            ),
            data:img
        )
    }
    private func createButton(img:(String,String), idx:Int, size:CGSize? = nil) -> NavigationButton {
        let size = size ?? self.imgSize
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
            ),
            data:img.0
        )
    }
    
}
