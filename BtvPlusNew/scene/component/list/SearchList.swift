//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct SearchPhrase:Identifiable{
    let id = UUID().uuidString
    let word:String
    var isStrong:Bool = false
}

class SearchData:InfinityData{
    
    
    private(set) var keyword: String = ""
    private(set) var phrases: [SearchPhrase] = []
    private(set) var isDeleteAble: Bool = false
    private(set) var isSection: Bool = false
    private(set) var isSectionChange = false
    func setData(keyword:String, isDeleteAble: Bool = false, isSection: Bool = false) -> SearchData {
        self.keyword = keyword
        if keyword == String.pageText.searchPopularity && isSection {
            isSectionChange = true
        }
        self.isDeleteAble = isDeleteAble
        self.isSection = isSection
        return self
    }
    
    func setData(keyword:String, search:String) -> SearchData {
        self.keyword = keyword
        if keyword == search {
            phrases = [SearchPhrase(word: keyword, isStrong:true)]
            return self
        }
        let boundary = "%08X%08X"
        let edit = keyword.replace(search, with: boundary + search + boundary)
        phrases = edit.components(separatedBy: boundary).filter{!$0.isEmpty}.map{ c in
            SearchPhrase(word: c, isStrong:c == search)
        }
        if phrases.isEmpty {
            phrases = [SearchPhrase(word: keyword)]
        }
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
                        .modifier(ListRowInset(
                            firstIndex: data.isSectionChange ? -1 : 1,
                            spacing: 0,
                            marginTop: data.isSectionChange ? Dimen.margin.heavyExtra : 0
                        ))
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


struct SearchItemKids: PageView {
    var data:SearchData
    var delete: ((_ data:SearchData) -> Void)? = nil
    var body: some View {
        HStack(spacing:0){
            ForEach(self.data.phrases) { phrase in
                Text(phrase.word)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regular,
                                color: phrase.isStrong ? Color.kids.primary : Color.app.brownDeep))
                    .lineLimit(1)
            }
        }
        .frame(height: ListItem.search.height)
    }
    
}
