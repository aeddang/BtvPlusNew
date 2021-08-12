//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
class TipBlockData {
    let id:String = UUID().uuidString
    var leadingIcon: String? = nil
    var leading: String? = nil
    var icon: String? = nil
    var strong: String? = nil
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
    func setupPurchase(leadingIcon:String?=nil,  leading:String?=nil, icon:String?=nil , trailing:String?=nil, data:MonthlyData?) ->TipBlockData {
        self.leadingIcon = leadingIcon
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
            leadingIcon: data.leadingIcon,
            leading: data.leading,
            strong: data.strong,
            icon: data.icon,
            trailing: data.trailing,
            isMore: data.isMore,
            textColor: data.textColor,
            textStrongColor: data.textColor,
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
