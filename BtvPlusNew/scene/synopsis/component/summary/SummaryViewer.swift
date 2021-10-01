//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


class SummaryViewerData {
    private(set) var title: String = ""
    private(set) var count: String? = nil
    private(set) var seasonTitle: String = ""
    private(set) var summry: String? = nil
    private(set) var peoples:[PeopleData]? = nil
    var episodeTitle:String {
        guard let count = self.count else { return self.title }
        if count.isEmpty { return self.title }
        return count + String.app.broCount + ") " + self.title 
    }
    
    func setData(data:SynopsisContentsItem) -> SummaryViewerData {
        self.title = data.title ?? ""
        self.summry = data.epsd_snss_cts?.replace("\r", with:"").replace("\n", with:"")
        if data.sris_typ_cd == SrisTypCd.season.rawValue {
            self.seasonTitle = data.sson_choic_nm ?? ""
            self.count = data.brcast_tseq_nm
        }
        
        self.peoples = data.peoples?.map {
            PeopleData().setData(data: $0, epsdId: data.epsd_id)
        }
        return self
    }
}

struct SummaryViewer: PageComponent{
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var peopleScrollModel: InfinityScrollModel = InfinityScrollModel()
    var data:SummaryViewerData
    var useTracking:Bool = false
    var isSimple:Bool = false
    var viewLineNum:Int = 4
    @State var isExpand = false
    @State var needExpand = false
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            Spacer().frame( height: Dimen.margin.regularExtra)
            
            if self.data.peoples != nil && self.data.peoples?.isEmpty == false {
                if !self.isSimple {
                    Text(String.pageText.synopsisSummry)
                        .modifier(BoldTextStyle( size: Font.size.regular ))
                        .padding(.bottom, Dimen.margin.regularExtra )
                        .modifier(ContentHorizontalEdges())
                }
                
                PeopleList(
                    viewModel:self.peopleScrollModel,
                    datas: self.data.peoples!,
                    useTracking:self.useTracking)
                    .frame(height:PeopleList.height)
                    .padding(.bottom, Dimen.margin.medium )
            }
            if self.data.summry != nil {
                if self.isSimple {
                    Text(self.data.summry!)
                        .lineSpacing(Font.spacing.large)
                        .modifier(MediumTextStyle( size: Font.size.light ))
                        .fixedSize(horizontal: false, vertical: true)
                        .modifier(ContentHorizontalEdges())
                     
                } else {
                    VStack(alignment:.leading , spacing:Dimen.margin.thin) {
                        Text(self.data.summry!)
                            .lineSpacing(Font.spacing.large)
                            .modifier(MediumTextStyle( size: Font.size.light ))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(self.isExpand ? 999 : self.viewLineNum)
                            
                        if self.needExpand {
                            HStack{
                                Spacer()
                                Image(Asset.icon.down)
                                    .renderingMode(.original).resizable()
                                    .scaledToFit()
                                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                                    .rotationEffect(.degrees(self.isExpand ? 180 : 0))
                                Spacer()
                            }
                        }
                        
                    }
                    .modifier(ContentHorizontalEdges())
                    .onTapGesture {
                        if self.needExpand {
                            if !self.isExpand {
                                self.naviLogManager.contentsLog(action: .clickViewMore)
                            }
                            withAnimation{ self.isExpand.toggle() }
                        }
                    }
                }
            }
        }
        //.fixedSize(horizontal: false, vertical: true)
        .onAppear{
            self.checkExpand()
        }
    }//body
    
    
    func checkExpand() {
        if self.isSimple {return}
        guard let summry = self.data.summry else { return }
        let h = summry.textHeightFrom(
            width: self.sceneObserver.screenSize.width - (Dimen.margin.thin * 2),
            fontSize: Font.size.light )
        if h > ((Font.size.light + Dimen.margin.micro) * CGFloat(self.viewLineNum)) {
            self.needExpand = true
        }
    }
}



#if DEBUG
struct SummaryViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SummaryViewer(
                data:SummaryViewerData()
            )
         
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            
        }.background(Color.blue)
    }
}
#endif

