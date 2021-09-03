//
//  SearchBar.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
import AVFoundation

struct SearchTabKids: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var searchScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    var isFocus:Bool = false
    var isVoiceSearch:Bool = false
    @Binding var keyword:String
    var datas:[SearchData] = []
    var inputChanged: ((_ text:String) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    var inputVoice: (() -> Void)? = nil
    var search: ((String) -> Void)? = nil
    var goBack: (() -> Void)? = nil
    
    var body: some View {
        
        HStack(alignment: .top, spacing:0){
            Button(action: {
                AppUtil.hideKeyboard()
                self.goBack?()
            }) {
                Image(AssetKids.icon.back)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.regularExtra,
                           height: DimenKids.icon.regularExtra)
            }
            .padding(.top, DimenKids.margin.tinyExtra)
            if !self.isVoiceSearch {
                VStack(spacing:0){
                    HStack(spacing:DimenKids.margin.tiny){
                        FocusableTextField(
                            text: self.$keyword,
                            returnVal: .done,
                            placeholder: String.kidsText.kidsSearchInput,
                            placeholderColor: Color.app.sepia.opacity(0.3),
                            textAlignment: .left,
                            textModifier: TextModifier(
                                family: Font.familyKids.bold,
                                size: Font.sizeKids.regular,
                                color: Color.app.brownDeep
                            ),
                            isfocus: self.isFocus,
                            inputChanged: {text in
                                self.inputChanged?(text)
                            },
                            inputCopmpleted: {text in
                                self.inputCopmpleted?(text)
                            })
                            .modifier(MatchHorizontal(height: DimenKids.tab.regular))
                            .clipped()
                            .padding(.top, 1)
                        /*
                        FocusableTextView(
                            text: self.$keyword,
                            isfocus: self.isFocus,
                            textModifier: TextModifier(
                                family: Font.familyKids.bold,
                                size: Font.sizeKids.regular,
                                color: Color.app.brownDeep
                            ),
                            inputChanged: {text, _ in
                                self.inputChanged?(text)
                            },
                            inputCopmpleted : { text in
                                self.inputCopmpleted?(text)
                            }
                        )
                        */
                        
                        
                        
                        Button(action: {
                            self.keyword = ""
                            self.inputChanged?("")
                        }) {
                            Image(AssetKids.icon.searchDelete)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: DimenKids.icon.light,
                                       height: DimenKids.icon.light)
                        }
                        
                        Button(action: {

                            self.inputCopmpleted?(self.keyword)
                        }) {
                            Image(AssetKids.icon.search)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: DimenKids.icon.light,
                                       height: DimenKids.icon.light)
                        }
                    }
                    .padding(.leading, DimenKids.margin.regular)
                    .padding(.trailing, DimenKids.margin.tiny)
                    if !self.datas.isEmpty {
                        if datas.count > 6 {
                            ScrollView(.vertical, showsIndicators: false){
                                VStack(alignment: .leading, spacing: 1){
                                    Spacer().modifier(MatchHorizontal(height: 0))
                                    ForEach(self.datas) { data in
                                        SearchItemKids(data: data)
                                        .onTapGesture {
                                            self.search?(data.keyword)
                                        }
                                    }
                                }
                                .padding(.all, DimenKids.margin.lightExtra)
                            }
                            .frame( height: ListItem.search.height * 6)
                        } else {
                            VStack(alignment: .leading, spacing: 0){
                                Spacer().modifier(MatchHorizontal(height: 1)).background(Color.app.sepia.opacity(0.3))
                                ForEach(self.datas) { data in
                                    SearchItemKids(data: data)
                                    .onTapGesture {
                                        self.search?(data.keyword)
                                    }
                                }
                            }
                            .padding(.all, DimenKids.margin.lightExtra)
                        }
                    }
                    
                }
                .background(Color.app.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: DimenKids.radius.medium)
                )
                .modifier(Grow())
               
                .padding(.leading, DimenKids.margin.mediumExtra)
                
                Button(action: {
                    AppUtil.hideKeyboard()
                    self.inputVoice?()
                }) {
                    Image(AssetKids.icon.micOn)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.medium,
                               height: DimenKids.icon.medium)
                }
                .padding(.leading, DimenKids.margin.thin)
            } else {
                Spacer()
                    .modifier(MatchHorizontal(height: DimenKids.icon.medium))
            }
        }
    }
    
}
