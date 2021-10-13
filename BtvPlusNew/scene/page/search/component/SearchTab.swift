//
//  SearchBar.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
import AVFoundation

struct SearchTab: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    @Binding var isFocus:Bool
    var scrollPos = UUID().hashValue
    var textModifier = TextModifier(
        family:Font.family.bold,
        size:Font.size.lightExtra,
        color: Color.app.white,
        sizeScale: 1.15
    )
    @Binding var keyword:String
    
    var inputChanged: ((_ text:String) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    var inputVoice: (() -> Void)? = nil
    var goBack: (() -> Void)? = nil
    
   
    
    var body: some View {
        HStack(spacing:Dimen.margin.thinExtra){
            Button(action: {
                AppUtil.hideKeyboard()
                self.goBack?()
            }) {
                Image(Asset.icon.back)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            HStack(spacing:Dimen.margin.tiny){
                /*
                ScrollViewReader{ reader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing:0){
                            FocusableTextField(
                                text:self.$keyword,
                                textAlignment:.left,
                                textModifier:self.textModifier,
                                isfocus: self.isFocus,
                                
                                inputChanged:{ text in
                                    self.inputChanged?(text)
                                    DispatchQueue.main.async {
                                        reader.scrollTo(self.scrollPos)
                                    }
                                },
                                inputCopmpleted: { text in
                                    self.inputCopmpleted?(text)
                                    
                                })
                                .frame(width: textModifier.getTextWidth(self.keyword) + Dimen.margin.thin)
                            Spacer().frame(width: 1, height: 1)
                                .id(self.scrollPos)
                        }
                        .padding(.horizontal, Dimen.margin.tiny)
                    }
                    .modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture {
                        self.isFocus = true
                    }
                    //.clipped()
                    .padding(.top, 1)
                }
                 */
                FocusableTextField(
                    text:self.$keyword,
                    textAlignment:.left,
                    textModifier:BoldTextStyle(size: Font.size.lightExtra).textModifier,
                    isfocus: self.isFocus,
                    inputChanged:{ text in
                        self.inputChanged?(text)
                    },
                    inputCopmpleted: { text in
                        self.inputCopmpleted?(text)
                    })
                    .padding(.horizontal, Dimen.margin.tiny)
                    .modifier(MatchParent())
                    .clipped()
                    .padding(.top, 1)
                 
                if self.keyword.isEmpty == false {
                    Button(action: {
                        self.keyword = ""
                        self.inputChanged?("")
                    }) {
                        Image(Asset.icon.searchDelete)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny,
                                   height: Dimen.icon.tiny)
                    }
                }
                Button(action: {
                    self.inputVoice?()
                    
                }) {
                    Image(Asset.icon.searchMic)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra,
                               height: Dimen.icon.regularExtra)
                }
            }
            .background(Color.app.blueLight)
            .overlay(
               Rectangle()
                .stroke(
                    self.isFocus ? Color.app.white : Color.app.blueLight,
                    lineWidth: Dimen.stroke.regular )
            )
            .modifier(MatchHorizontal(height: Dimen.tab.light))
        }
    }
}
