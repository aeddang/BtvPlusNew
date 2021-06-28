//
//  ImageViewButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/14.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

struct ImageViewButton: PageView{
    var isSelected: Bool
    let defaultImage:String
    let activeImage:String
    var size:CGSize = CGSize(width: Dimen.icon.light, height: Dimen.icon.light)
    var text:String? = nil
    var textSize:CGFloat = Font.size.tinyExtra
    var defaultTextColor:Color = Color.app.whiteDeep
    var activeTextColor:Color = Color.app.white
    var noImg:String = Asset.noImg1_1
    var noImgAc:String = Asset.noImg1_1
    var axis: Axis = .vertical
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            if self.axis == .vertical {
                VStack(spacing:Dimen.margin.tiny){
                    if self.isSelected {
                        KFImage(URL(string: self.activeImage))
                            .renderingMode(.original)
                            .resizable()
                            .placeholder {
                                Image(self.noImgAc)
                                    .resizable()
                            }
                            .loadImmediately()
                            .frame(width: size.width, height: size.height)
                    }else{
                        KFImage(URL(string: self.defaultImage))
                            .renderingMode(.original)
                            .resizable()
                            .placeholder {
                                Image(self.noImg)
                                    .resizable()
                            }
                            .loadImmediately()
                            .frame(width: size.width, height: size.height)
                    }
                    
                    if self.text != nil {
                        Text(self.text!)
                            .modifier(BoldTextStyle(
                                size: self.textSize,
                                color: self.isSelected ?
                                    self.activeTextColor : self.defaultTextColor
                            ))
                    }
                }
            } else {
                HStack(spacing:Dimen.margin.tiny){
                    if self.isSelected {
                        KFImage(URL(string: self.activeImage))
                            .renderingMode(.original)
                            .resizable()
                            .placeholder {
                                Image(self.noImgAc)
                                    .resizable()
                            }
                            .loadImmediately()
                            .frame(width: size.width, height: size.height)
                    }else{
                        KFImage(URL(string: self.defaultImage))
                            .renderingMode(.original)
                            .resizable()
                            .placeholder {
                                Image(self.noImg)
                                    .resizable()
                            }
                            .loadImmediately()
                            .frame(width: size.width, height: size.height)
                    }
                    
                    if self.text != nil {
                        Text(self.text!)
                            .modifier(BoldTextStyle(
                                size: self.textSize,
                                color: self.isSelected ?
                                    self.activeTextColor : self.defaultTextColor
                            ))
                    }
                }
            }
        }
    }
}


