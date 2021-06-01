//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
class TipBlockData {
    var leading: String? = nil
    var icon: String? = nil
    var trailing: String? = nil
    var isMore: Bool = true
    var textColor:Color =  Color.app.greyLight
    var bgColor:Color =  Color.app.blueLight
    var data:MonthlyData? = nil
    func setupTip(leading:String?=nil, icon:String?=nil , trailing:String?=nil) ->TipBlockData {
        self.leading = leading
        self.icon = icon
        self.trailing = trailing
        textColor = Color.app.white
        bgColor = Color.brand.primary
        isMore = false
        return self
    }
    func setupPurchase(leading:String?=nil, icon:String?=nil , trailing:String?=nil, data:MonthlyData?) ->TipBlockData {
        self.leading = leading
        self.icon = icon
        self.trailing = trailing
        self.data = data
        textColor = Color.app.white
        bgColor = Color.app.blueExtra
        isMore = true
        
        return self
    }
}

struct TipBlock:PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var data: TipBlockData
    var body :some View {
        TipTab(
            leading: data.leading,
            icon: data.icon,
            trailing: data.trailing,
            isMore: data.isMore,
            textColor: data.textColor,
            bgColor: data.bgColor)
        .modifier( ContentHorizontalEdges() )
        .onTapGesture {
            if !self.data.isMore {return}
            
            let status = self.pairing.status
            if status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.purchase)
                    .addParam(key: .data, value: self.data.data)
            )
        }
    }

}
