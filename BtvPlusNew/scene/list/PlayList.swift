//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class PlayData:InfinityData{
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var date: String? = nil
    private(set) var description: String? = nil
    fileprivate(set) var isLike:LikeStatus? = nil
    fileprivate(set) var isAlram:Bool = false
    private(set) var isPlayAble:Bool = false
    private(set) var restrictAgeIcon:String? = nil
    private(set) var provider: String? = nil
    
    func setDummy(_ idx:Int = -1) -> PlayData {
        title = "조커"
        date = "4월 10일 월정액 업데이트"
        description = "‘내 인생이 비극인줄 알았는데, 코미디였어고담시의 광대 아서 플렉은 코미디언을 꿈꾸는 남자 하지만 모두가 미쳐가는 코미디 같은 세상에서 맨 정신으로는 그가 설 자리가 없음을 깨닫게 되는데 …"
        index = idx
        self.restrictAgeIcon = Asset.age.getIcon(age: "")
        return self
    }
    
}

struct PlayList: PageComponent{
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PlayData]
    var useTracking:Bool = false
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical: 0,
            marginHorizontal: Dimen.margin.thin,
            spacing: Dimen.margin.medium,
            isRecycle: true,
            useTracking: self.useTracking
        ){
            ForEach(self.datas) { data in
                PlayItem(data: data)
            }
        }
        
    }//body
}

struct PlayItem: PageView {
    @EnvironmentObject var sceneObserver:SceneObserver
    var data:PlayData
    var isSelected:Bool = false
    
    @State var isLike:LikeStatus? = nil
    @State var isAlram:Bool? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            ZStack{
                if self.data.image == nil {
                    Image(Asset.noImg16_9)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else {
                    ImageView(url: self.data.image!, contentMode: .fill, noImg: Asset.noImg16_9)
                        .modifier(MatchParent())
                }
                
                if self.data.isPlayAble {
                    Image(Asset.icon.thumbPlay)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                }
            }
            .modifier(Ratio16_9(width: self.sceneObserver.screenSize.width, horizontalEdges: Dimen.margin.thin))
            .clipped()
            HStack(spacing:Dimen.margin.thin){
                if self.data.title != nil {
                    VStack(alignment: .leading, spacing:0){
                        Text(self.data.title!)
                            .modifier(BoldTextStyle(
                                    size: Font.size.large,
                                    color: Color.app.white)
                            )
                            .lineLimit(1)
                        Spacer().modifier(MatchHorizontal(height: 0))
                    }
                    .modifier(MatchHorizontal(height: Font.size.large))
                } else{
                    Spacer().modifier(MatchHorizontal(height: 1))
                }
                LikeButton(srisId: "", isLike: self.$isLike, useText:false){ value in
                    self.data.isLike = value
                }
                AlramButton(srisId: "", isAlram: self.$isAlram){ value in
                    self.data.isAlram = value
                }
            }
            .padding(.top, Dimen.margin.light)
            
            HStack(spacing:Dimen.margin.thin){
                if self.data.date != nil {
                    Text(self.data.date!)
                        .modifier(MediumTextStyle(
                                size: Font.size.lightExtra,
                                color: Color.brand.primary)
                        )
                        .lineLimit(1)
                }
                
                if self.data.provider != nil {
                    Text(self.data.provider!)
                        .modifier(BoldTextStyle(
                                size: Font.size.lightExtra,
                                    color: Color.app.white)
                        )
                        .lineLimit(1)
                }
                if self.data.restrictAgeIcon != nil {
                    Image( self.data.restrictAgeIcon! )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    }
                
            }
            .padding(.top, Dimen.margin.light)
            
            if self.data.description != nil  {
                Text(self.data.description!)
                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyDeep))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top, Dimen.margin.thin)
            }
            
        }
        
        
        
    }
    
}

#if DEBUG
struct PlayList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayList( datas: [
                PlayData().setDummy(0),
                PlayData().setDummy(),
                PlayData().setDummy(),
                PlayData().setDummy()
            ])
            .environmentObject(PagePresenter())
            .environmentObject(SceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(Pairing())
            .environmentObject(PageSceneObserver())
            .frame(width:320,height:600)
            
        }
    }
}
#endif

