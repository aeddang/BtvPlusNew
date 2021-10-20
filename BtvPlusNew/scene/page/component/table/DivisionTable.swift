//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct TableCell: Identifiable {
    var id:String = UUID().uuidString
    var text:String = ""
    var idx:Int = -1
    var size:CGFloat? = nil
    var isLeading:Bool = false
    var textModifier = TextModifier(
        family: Font.family.medium,
        size: Font.size.thin,
        color: Color.app.white
    )
}

struct TableCellSet: Identifiable {
    var id:String = UUID().uuidString
    var idx:Int = -1
    var cells:[TableCell] = []
    
}

struct DivisionTable : PageComponent {
    var title:String? = nil
    var header:TableCellSet? = nil
    var datas:[TableCellSet]? = nil
    var lineColor:Color = Color.app.blueLight
    
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.thin){
            if let title = self.title {
                Text(title).modifier(BlockTitle())
            }
            VStack(alignment: .leading, spacing:0){
                
                if let headerSet = self.header {
                    HStack(spacing:0){
                        ForEach(headerSet.cells) { header in
                            if let size = header.size {
                                Text(header.text)
                                    .font(.custom( header.textModifier.family, size: header.textModifier.size))
                                    .foregroundColor( header.textModifier.color)
                                    .padding(.vertical, Dimen.margin.thin)
                                    .frame(width: size)
                            } else {
                                VStack(spacing:0){
                                    Spacer().modifier(MatchHorizontal(height: 0))
                                    Text(header.text)
                                        .font(.custom( header.textModifier.family, size: header.textModifier.size))
                                        .foregroundColor( header.textModifier.color)
                                        .padding(.all, Dimen.margin.thin)
                                }
                            }
                            
                        }
                    }
                    .background(self.lineColor)
                }
                if let datas = self.datas {
                    ForEach(datas) { set in
                        HStack(spacing:0){
                            ForEach(set.cells) { cell in
                                if let size = cell.size {
                                    Text(cell.text)
                                        .font(.custom( cell.textModifier.family, size: cell.textModifier.size))
                                        .foregroundColor( cell.textModifier.color)
                                        .padding(.vertical, Dimen.margin.thin)
                                        .frame(width: size)
                                        
                                    
                                } else {
                                    VStack(alignment: cell.isLeading ? .leading : .center, spacing:0){
                                        Spacer().modifier(MatchHorizontal(height: 0))
                                        Text(cell.text)
                                            .font(.custom( cell.textModifier.family, size: cell.textModifier.size))
                                            .foregroundColor( cell.textModifier.color)
                                            .multilineTextAlignment(cell.isLeading ? .leading : .center)
                                            .padding(.all, Dimen.margin.thin)
                                    }
                                    .background(
                                        HStack{
                                            if cell.idx != 0 {
                                                Spacer().modifier(MatchVertical(width: 1))
                                                    .background(self.lineColor)
                                            }
                                            Spacer()
                                            if cell.idx != (set.cells.count - 1) {
                                                Spacer().modifier(MatchVertical(width: 1))
                                                    .background(self.lineColor)
                                            }
                                        }
                                    )
                                }
                                
                            }
                        }
                        if set.idx != (datas.count - 1) {
                            Spacer().modifier(MatchHorizontal(height: 1))
                                .background(self.lineColor)
                        }
                    }
                }
            }
            .overlay(
                Rectangle().stroke( self.lineColor ,lineWidth: 1)
            )
        }
        
    }//body
    
   
    
}


#if DEBUG
struct DivisionTable_Previews: PreviewProvider {
    static let headerStyle = TextModifier(
        family: Font.family.medium,
        size: Font.size.thinExtra,
        color: Color.app.greyLight
    )
    
    static var previews: some View {
        ZStack{
            DivisionTable(
                title: "test",
                header: .init( cells: [
                    .init( text: "test", size: 100, textModifier: headerStyle),
                    .init( text: "test", textModifier: headerStyle),
                    .init( text: "test", textModifier: headerStyle)
                ]),
                datas: [
                    .init(
                        idx:0,
                        cells: [
                            .init( text: "value",idx:0, size: 100),
                            .init( text: "value", idx:1),
                            .init( text: "value", idx:2)
                        ]
                    ),
                    .init(
                        idx:1,
                        cells: [
                            .init( text: "value", idx:0),
                            .init( text: "value", idx:1),
                            .init( text: "value", idx:2)
                        ]
                    ),
                    .init(
                        idx:2,
                        cells: [
                            .init( text: "value", idx:0),
                            .init( text: "value", idx:1),
                            .init( text: "value", idx:2)
                        ]
                    )
                ]
            )
        }
        .padding(.all, 30)
        .background(Color.brand.bg)
    }
}
#endif
