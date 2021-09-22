//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI

class LvGraphBoxData{
    private(set) var lvs:[String] = []
    private(set) var avgLv:Int = 0
    private(set) var meLv:Int = 0
    private(set) var avgPct:Float = 0
    private(set) var mePct:Float = 0
    
    private(set) var avgTitle:String? = nil
    private(set) var meTitle:String? = nil
    
    private(set) var date:String? = nil
    
    
    func setDataLv(_ data:KidsReport) -> LvGraphBoxData{
        guard let content = data.contents else { return self}
        if let labels = content.level_labels {
            self.lvs = labels.map{ lb in
                var ldStr = lb.description
                ldStr = ldStr.isNumric() ? "Lv." + ldStr : ldStr
                return ldStr
            }
        }
        self.avgLv = content.peer_avgs?.firstIndex(of: 1) ?? 0
        self.meLv = content.my_levels?.firstIndex(of: 1) ?? 0
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        let count = lvs.count
        if count > self.avgLv {
            self.avgTitle = self.lvs[ self.avgLv ]
        }
        if count > self.meLv {
            self.meTitle = self.lvs[ self.meLv ]
        }
        if !lvs.isEmpty {
            let max = Float(count)
            self.avgPct = Float(self.avgLv)/max
            self.mePct = Float(self.meLv)/max
            //self.avgPct = 1
            //self.mePct = 1
        }
        return self
    }
    
    func setDataGraph(_ data:KidsReport) -> LvGraphBoxData{
        guard let content = data.contents else { return self}
        self.setDataGraph(content: content)
        
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        let count = lvs.count
        if count > self.avgLv {
            self.avgTitle = self.lvs[ self.avgLv ]
        }
        if count > self.meLv {
            self.meTitle = self.lvs[ self.meLv ]
        }
        return self
    }
    
    @discardableResult
    func setDataGraph(content:KidsReportContents) -> LvGraphBoxData{
        let max = 5
        self.lvs = (1...max).map{"Lv." + $0.description}
        if let graph = content.graphs {
            if graph.count >= 2 {
                self.avgLv = graph[0]
                self.meLv = graph[1]
            }
        }
       
        self.avgPct = Float(self.avgLv)/Float(max)
        self.mePct = Float(self.meLv)/Float(max)
        
        //self.avgPct = 1
        //self.mePct = 1
        return self
    }
}


struct LvGraphBox: PageComponent{
    var thumb:String
    var data:LvGraphBoxData
    var width:CGFloat = SystemEnvironment.isTablet ? 188 : 100
    var size:CGSize = DimenKids.item.graphVertical
    var colorAvg:Color = Color.app.sky
    var colorMe:Color = Color.app.red
    @State var mePct:Float = 0
    @State var avgPct:Float = 0
    @State var meTitle:String = ""
    @State var avgTitle:String = ""
    var body: some View {
        VStack(spacing:0){
            ZStack(alignment: .bottom){
                VStack(spacing:0){
                    ForEach(0..<self.data.lvs.count) { index in
                        Spacer()
                        Spacer().modifier(LineHorizontal(height: 1.0,  color: Color.app.ivory, opacity: 0.4))
                    }
                }
                .modifier(MatchHorizontal(height: size.height))
                HStack(spacing:0){
                    VerticalGraph(
                        value: self.avgPct,
                        viewText: self.avgTitle,
                        thumbText: String.app.peerAverage,
                        size: self.size,
                        color: self.colorAvg)
                        .modifier(MatchParent())
                    VerticalGraph(
                        value: self.mePct,
                        viewText: self.meTitle,
                        thumbImg: self.thumb,
                        size: self.size,
                        color: self.colorMe)
                        .modifier(MatchParent())
                }
                .modifier(MatchVertical(width: self.width))
            }
            if let date = self.data.date {
                Text(String.kidsText.kidsMyDiagnosticReportDate + " " + date)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.microUltra,
                                color:  Color.app.sepia))
                    .padding(.top, DimenKids.margin.thinExtra)
            }
        }
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
                withAnimation{
                    self.avgPct = self.data.avgPct
                    self.avgTitle = self.data.avgTitle ?? ""
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 ) {
                withAnimation{
                    self.mePct = self.data.mePct
                    self.meTitle = self.data.meTitle ?? ""
                }
            }
        }
    }
}
