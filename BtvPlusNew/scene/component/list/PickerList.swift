//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI



class PickerData:InfinityData{
    private(set) var title: String = ""
    func setData(title: String, idx:Int) -> PickerData {
        self.title = title
        self.index = idx
        return self
    }
}

struct PickerList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PickerData]
    var selectedIdx:Int = -1
    var verticalMargin:CGFloat = Dimen.margin.heavyUltra
    var bgColor:Color = Color.app.blueDeep
    var action: ((_ data:PickerData) -> Void)? = nil
    var body: some View {
        ZStack{
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .vertical,
                scrollType: .vertical(isDragEnd: false),
                marginTop: self.verticalMargin,
                marginBottom: self.verticalMargin,
                marginHorizontal: 0,
                spacing: 0,
                isRecycle:false,
                useTracking: true,
                useTopButton:false
            ){
                if !self.datas.isEmpty {
                    ForEach(self.datas) { data in
                        PickerItem( data:data, isSelected: self.selectedIdx == data.index )
                            .id(data.hashId)
                            .frame(height: self.selectedIdx == data.index ? Font.size.bold  : Font.size.mediumExtra )
                            .modifier(ListRowInset(
                                spacing:Dimen.margin.medium
                            ))
                            .accessibility(label: Text(data.title))
                            .onTapGesture {
                                action?(data)
                            }
                    }
                } else {
                    Spacer().modifier(MatchParent())
                        .modifier(ListRowInset(spacing: 0))
                }
            }
            VStack(spacing:0){
                LinearGradient(
                    gradient:Gradient(colors: [self.bgColor, self.bgColor.opacity(0)]),
                    startPoint: .top, endPoint: .bottom)
                    .modifier(MatchHorizontal(height:  self.verticalMargin))
                Spacer()
                LinearGradient(
                    gradient:Gradient(colors: [self.bgColor.opacity(0), self.bgColor]),
                    startPoint: .top, endPoint: .bottom)
                    .modifier(MatchHorizontal(height:  self.verticalMargin))
            }
            .allowsHitTesting(false)
        }
        .modifier(MatchParent())
    }//body
}

struct PickerItem: PageView {
    var data:PickerData
    var isSelected:Bool
    var body: some View {
        ZStack(alignment: .leading) {
            Spacer().modifier(MatchHorizontal(height: 0))
            Text(self.data.title)
                .modifier(BoldTextStyle(
                            size: self.isSelected ? Font.size.bold : Font.size.mediumExtra,
                            color: self.isSelected ? Color.app.white : Color.app.white.opacity(0.4)))
                .multilineTextAlignment(.leading)
        }
    }
}


 
