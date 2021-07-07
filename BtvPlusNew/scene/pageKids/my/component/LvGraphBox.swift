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
    
    private(set) var date:String = ""
    
    
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
            
        }
        return self
    }
    
    func setDataGraph(_ data:KidsReport) -> LvGraphBoxData{
        guard let content = data.contents else { return self}
        let max = 5
        self.lvs = (0...max).map{"Lv." + $0.description}
        if let graph = content.graphs {
            if graph.count >= 2 {
                self.avgLv = graph[0]
                self.meLv = graph[1]
            }
        }
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        let count = lvs.count
        if count > self.avgLv {
            self.avgTitle = self.lvs[ self.avgLv ]
        }
        if count > self.meLv {
            self.meTitle = self.lvs[ self.meLv ]
        }
        self.avgPct = Float(self.avgLv)/Float(max)
        self.mePct = Float(self.meLv)/Float(max)
        
        return self
    }
}


struct LvGraphBox: PageComponent{
    var thumb:String
    var data:LvGraphBoxData
    var width:CGFloat = SystemEnvironment.isTablet ? 188 : 100
    
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
                .modifier(MatchHorizontal(height: DimenKids.item.graphVertical.height))
                HStack(spacing:0){
                    VerticalGraph(
                        value: self.avgPct,
                        viewText: self.avgTitle,
                        thumbText: String.app.peerAverage,
                        size: DimenKids.item.graphVertical,
                        color: Color.app.sky)
                        .modifier(MatchParent())
                    VerticalGraph(
                        value: self.mePct,
                        viewText: self.meTitle,
                        thumbImg: self.thumb,
                        size: DimenKids.item.graphVertical,
                        color: Color.app.red)
                        .modifier(MatchParent())
                }
                .modifier(MatchVertical(width: self.width))
            }
            
            Text(String.kidsText.kidsMyDiagnosticReportDate + " " + self.data.date)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.microUltra,
                            color:  Color.app.sepia))
                .padding(.top, DimenKids.margin.thinExtra)
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
