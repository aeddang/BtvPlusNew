//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


class SimpleSummaryViewerData:ObservableObject{
    private(set) var summry: String? = nil
    @Published private(set) var casts:[CastSummary]? = nil
    func setData(data:SynopsisContentsItem) -> SimpleSummaryViewerData {
        self.summry = data.epsd_snss_cts
        if let peoples = data.peoples {
            var peopleSet:[String:[PeopleData]] = [:]
            peoples.filter{$0.prs_nm != nil}.forEach { person in
                let peo = PeopleData().setData(data: person, epsdId: data.epsd_id)
                if peo.role == .director ||  peo.role == .step || peo.role == .author {
                    if let job = person.prs_role_nm {
                        if peopleSet[job] == nil {
                            peopleSet[job] = []
                        }
                        peopleSet[job]?.append(peo)
                    }
                } else {
                    if peopleSet[String.app.cast] == nil {
                        peopleSet[String.app.cast] = []
                    }
                    peopleSet[String.app.cast]?.append(peo)
                }
            }
            self.casts = peopleSet.map{ set in
                CastSummary(title: set.key, people: set.value)
            }
            self.casts?.sort{$0.title.localizedStandardCompare($1.title) == .orderedAscending}
        }
        return self
    }
    
    struct CastSummary :Identifiable {
        let id:String = UUID().uuidString
        let title:String
        let people:[PeopleData]
    }
    
    struct CastSummarySet :Identifiable {
        let id:String = UUID().uuidString
        let title:String
        let peopleSets:[PeopleSet]
    }
    
    struct PeopleSet :Identifiable {
        let id:String = UUID().uuidString
        var datas:[PeopleData] = []
    }
    
    func getCastSummarySet(screenWidth:CGFloat, textModifier:TextModifier)->[CastSummarySet]?{
        guard let casts = self.casts else { return nil }
        var sets:[CastSummarySet] = []
        casts.forEach{ cast in
            let limit:CGFloat = screenWidth - textModifier.getTextWidth(cast.title)
            var peopleSets:[PeopleSet] = []
            var lineWidth:CGFloat = 0
            var people:PeopleSet? = PeopleSet()
            cast.people.forEach{ person in
                let cellW = textModifier.getTextWidth((person.name ?? "") + " | ")
                lineWidth += cellW
                if lineWidth < limit || people?.datas.count == 0 {
                    people?.datas.append(person)
                } else {
                    if let peo = people {
                        peopleSets.append(peo)
                    }
                    people = PeopleSet(datas: [person])
                    lineWidth = cellW
                }
            }
            if let peo = people {
                peopleSets.append(peo)
            }
            peopleSets.forEach{ set in
                zip(0...set.datas.count, set.datas).forEach{$0.1.index = $0.0}
            }
            
            sets.append(CastSummarySet(title: cast.title, peopleSets: peopleSets))
        }
        return sets
    }
}

struct SimpleSummaryViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var data:SimpleSummaryViewerData
    var currentPoster:PosterData? = nil
    
    let textStyle = MediumTextStyle( size: Font.size.thin, color: Color.app.greyDeep)
    @State var castSet:[SimpleSummaryViewerData.CastSummarySet]? = nil
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            if self.data.summry != nil {
                Text(self.data.summry!)
                    .modifier(textStyle)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let casts = self.castSet  {
                ForEach( casts ) { cast in
                    HStack(alignment: .top, spacing: Dimen.margin.micro){
                        Text(cast.title + ":")
                            .modifier(textStyle)
                            .fixedSize(horizontal: false, vertical: true)
                        VStack(alignment: .leading, spacing: Dimen.margin.tinyExtra){
                            ForEach( cast.peopleSets ) { set in
                                HStack(alignment: .top, spacing: Dimen.margin.tiny){
                                    ForEach( set.datas ) { person in
                                        if person.index != 0 {
                                            Text("|")
                                                .modifier(textStyle)
                                        }
                                        TextButton(
                                            defaultText: person.name ?? "",
                                            textModifier: textStyle.textModifier,
                                            isUnderLine: true){ _ in
                                            
                                            if person.epsdId == nil {return}
                                            self.pagePresenter.openPopup(
                                                PageProvider.getPageObject(.person)
                                                    .addParam(key: .data, value: person)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, Dimen.margin.thin)
                }
            }
            TextButton(
                defaultText: String.button.detail,
                textModifier: BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white).textModifier,
                isUnderLine: false, image: Asset.icon.directRight){ _ in
                guard let poster = self.currentPoster else {return}
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject( poster.synopsisType == .package ? .synopsisPackage : .synopsis)
                        .addParam(key: .data, value: poster.synopsisData)
                        .addParam(key: .watchLv, value: poster.watchLv)
                )
            }
            .padding(.top, Dimen.margin.regular)
        }
        .modifier(ContentHorizontalEdges())
        .onReceive(self.data.$casts){ cast in
            if cast == nil {return}
            self.castSet = self.data.getCastSummarySet(
                screenWidth: sceneObserver.screenSize.width - (Dimen.margin.thin * 2),
                textModifier: textStyle.textModifier)
        }
        .onAppear{
            
        }
    }//body
}
    




#if DEBUG
struct SimpleSummaryViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SimpleSummaryViewer(
                data:SimpleSummaryViewerData()
            )
            .environmentObject(PagePresenter())
            
        }.background(Color.blue)
    }
}
#endif

