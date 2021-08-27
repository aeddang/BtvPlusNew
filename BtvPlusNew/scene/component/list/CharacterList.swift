//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct CharacterRowData:Identifiable{
    private(set) var id = UUID().uuidString
    var datas:[CharacterData] = zip(
        0 ..<  Asset.characterList.count, Asset.characterList)
        .map {index, character in
            CharacterData(idx:index, image:character)
        }

    func getRow(lineNum:Int) -> [CharacterRows] {
        var rows:[CharacterRows] = []
        var cells:[CharacterData] = []
        self.datas.forEach{ d in
            if cells.count < lineNum {
                cells.append(d)
            }else{
                rows.append(CharacterRows(cells: cells))
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(CharacterRows(cells: cells))
        }
        return rows
    }
}

struct CharacterRows:Identifiable{
    let id = UUID().uuidString
    var cells:[CharacterData]
}

struct CharacterData:Identifiable{
    let id:String = UUID().uuidString
    let idx:Int
    let image: String
}


struct CharacterList: PageComponent{
    @Binding var selectIdx:Int
    var datas:[CharacterRows]
    var cellSpace:CGFloat
    var body: some View {
        VStack (alignment: .leading, spacing: Dimen.margin.medium){
            ForEach(self.datas) { data in
                HStack(alignment: .center, spacing: self.cellSpace) {
                    ForEach(data.cells) { cell in
                        CharacterItem(
                            selected: .constant(self.selectIdx == cell.idx),
                            data: cell)
                        .onTapGesture {
                            self.selectIdx = cell.idx
                            AppUtil.hideKeyboard()
                        }
                            
                    }
                }
                .frame(height: ListItem.character.size.height)
            }
        }
        
    }//body
}

struct CharacterItem: PageView {
    @Binding var selected: Bool
    var data:CharacterData
    var body: some View {
        Image(data.image)
        .renderingMode(.original)
        .resizable()
        .frame(
            width: ListItem.character.size.width,
            height: ListItem.character.size.height)
        .overlay(
           Circle()
            .stroke(
                self.selected ? Color.app.white : Color.transparent.clear,
                lineWidth: Dimen.stroke.medium)
        )
        
    }
}

#if DEBUG
struct CharacterList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            CharacterList(
                selectIdx: .constant(0) ,
                datas: CharacterRowData().getRow(lineNum: 4),
                cellSpace: 20)
                .frame(width:320,height:600)
        }
        .background(Color.brand.bg)
    }
}
#endif
