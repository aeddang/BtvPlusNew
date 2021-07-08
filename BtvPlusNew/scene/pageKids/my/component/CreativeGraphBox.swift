//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI

struct CompareData:Identifiable{
    let id:String = UUID().uuidString
    let title:String
    let valueA:Float
    let valueB:Float
}

class CreativeGraphBoxData{
    private(set) var lvCount:Int = 5
    private(set) var compares:[CompareData] = []
    private(set) var date:String? = nil
    func setData(_ data:CreativeReport) -> CreativeGraphBoxData{
        guard let content = data.contents else { return self}
        self.setData(content: content)
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        return self
    }
    
    @discardableResult
    func setData(content:KidsReportContents) -> CreativeGraphBoxData{
        if let labels = content.labels, let children = content.childs, let parents = content.parents {
            let max:Float = 100
            self.compares = zip(labels, zip(children, parents)).map{ title, data in
                CompareData(title: title, valueA: Float(data.0)/max , valueB:  Float(data.1)/max)
            }
        }
        return self
    }
}


struct CreativeGraphBox: PageComponent{
    var data:CreativeGraphBoxData
    var sortSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 33, height: 19) : CGSize(width: 15, height: 9)
    
    var colorKid:Color = Color.app.sky
    var colorParent:Color = Color.app.red
    var body: some View {
        VStack(spacing:0){
            ZStack(alignment: .top){
                HStack(spacing:DimenKids.margin.thin){
                    HStack(spacing:DimenKids.margin.micro){
                        Spacer()
                            .frame(width: sortSize.width, height: sortSize.height)
                            .background(self.colorKid)
                            .mask(RoundedRectangle(cornerRadius: DimenKids.radius.tiny))
                        Text(String.app.kid)
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.microUltra,
                                        color:  Color.app.brownDeep))
                    }
                    HStack(spacing:DimenKids.margin.micro){
                        Spacer()
                            .frame(width: sortSize.width, height: sortSize.height)
                            .background(self.colorParent)
                            .mask(RoundedRectangle(cornerRadius: DimenKids.radius.tiny))
                        Text(String.app.parent)
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.microUltra,
                                        color:  Color.app.brownDeep))
                    }
                    Spacer()
                }
                .padding(.leading, DimenKids.margin.regular)
                HStack(spacing:DimenKids.margin.regular){
                    ForEach(self.data.compares) { compare in
                        CreativeGraph(
                            title: compare.title,
                            lvCount: self.data.lvCount,
                            valueA: compare.valueA,
                            valueB: compare.valueB,
                            colorA: self.colorKid,
                            colorB: self.colorParent
                        )
                    }
                }
                .padding(.top, DimenKids.margin.tiny)
            }
            if let date = self.data.date {
                Text(String.kidsText.kidsMyDiagnosticReportDate + " " + date)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.microUltra,
                                color:  Color.app.sepia))
                    .padding(.top, DimenKids.margin.thinExtra)
            }
        }
        
    }
}

struct CreativeGraph: PageComponent{
    var title:String
    var lvCount:Int
    var valueA:Float = 0
    var valueB:Float = 0
    var width:CGFloat = SystemEnvironment.isTablet ? 200 : 101
    var colorA:Color = Color.app.sky
    var colorB:Color = Color.app.red
    
    @State var valueAPct:Float = 0
    @State var valueBPct:Float = 0
    var body: some View {
        VStack(spacing:0){
            ZStack(alignment: .bottom){
                VStack(spacing:0){
                    ForEach(0..<self.lvCount) { index in
                        Spacer()
                        Spacer().modifier(LineHorizontal(height: 1.0,  color: Color.app.ivory, opacity: 0.4))
                    }
                }
                .modifier(MatchHorizontal(height: DimenKids.item.graphVertical.height))
                HStack(spacing:DimenKids.margin.thin){
                    VerticalGraph(
                        value: self.valueAPct,
                        viewText: "",
                        size: DimenKids.item.graphVerticalExtra,
                        color: self.colorA)
                        
                    VerticalGraph(
                        value: self.valueBPct,
                        viewText: "",
                        size: DimenKids.item.graphVerticalExtra,
                        color: self.colorB)
                       
                }
                
            }
            .modifier(MatchVertical(width: self.width))
            Text( self.title )
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.tinyExtra,
                            color:  Color.app.brownDeep))
                .padding(.top, DimenKids.margin.thinExtra)
        }
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
                withAnimation{
                    self.valueAPct = self.valueA
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 ) {
                withAnimation{
                    self.valueBPct = self.valueB
                }
            }
        }
    }
}
