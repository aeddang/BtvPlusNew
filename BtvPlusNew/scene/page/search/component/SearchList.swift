//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class SearchData:InfinityData{
    private(set) var keyword: String = ""
    private(set) var isDeleteAble: Bool = false
    private(set) var isSection: Bool = false
   
    func setData(keyword:String, isDeleteAble: Bool = false, isSection: Bool = false) -> SearchData {
        self.keyword = keyword
        self.isDeleteAble = isDeleteAble
        self.isSection = isSection
        return self
    }
    
    
}

struct SearchList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[SearchData]
    var delete: ((_ data:SearchData) -> Void)? = nil
    var action: ((_ data:SearchData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginTop: Dimen.margin.regular,
            marginBottom: Dimen.app.bottom,
            marginHorizontal: 0,
            spacing: 0,
            isRecycle:true,
            useTracking: true
        ){
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    SearchItem( data:data , delete:delete)
                        .modifier(ListRowInset(spacing: 0))
                        .onTapGesture {
                            if data.isSection {return}
                            action?(data)
                        }
                }
            } else {
                Spacer().modifier(MatchParent())
                    .modifier(ListRowInset(spacing: 0))
            }
        }
        .modifier(ContentHorizontalEdges())
        .background(Color.brand.bg)
        .padding(.top, Dimen.margin.thin)
    }//body
}

struct SearchItem: PageView {
    var data:SearchData
    var delete: ((_ data:SearchData) -> Void)? = nil
    var body: some View {
        VStack(spacing:0){
            HStack(spacing:0){
                VStack(alignment: .leading){
                    if self.data.isSection {
                        Text(self.data.keyword)
                            .modifier(BoldTextStyle(size: Font.size.light))
                            .lineLimit(1)
                    } else {
                        Text(self.data.keyword)
                            .modifier(LightTextStyle(size: Font.size.lightExtra, color: Color.app.whiteDeep))
                            .lineLimit(1)
                    }
                    Spacer().modifier(MatchHorizontal(height: 0))
                }
                if data.isDeleteAble {
                    Button(action: {
                        self.delete?(self.data)
                    }) {
                        HStack(spacing:Dimen.margin.tiny){
                            if self.data.isSection {
                                Text( String.button.deleteAll)
                                    .modifier(LightTextStyle(size: Font.size.tiny, color:Color.app.grey) )
                            }
                            Image(Asset.icon.close)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimen.icon.light,
                                       height: Dimen.icon.light)
                                
                                .colorMultiply(Color.app.grey)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .modifier(MatchParent())
            if !self.data.isSection {
                Spacer().modifier(LineHorizontal())
            }
        }
        .frame(height: ListItem.search.height)
    }
    
}


