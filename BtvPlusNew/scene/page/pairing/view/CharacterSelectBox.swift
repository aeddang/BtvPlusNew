//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct CharacterSelectBox: PageComponent{
    @EnvironmentObject var sceneObserver:SceneObserver
    var data:CharacterRowData
    @Binding var selectIdx:Int
    
    @State var datas:[CharacterRows] = []
    @State var cellSpace:CGFloat = 0
    var body: some View {
        VStack (alignment: .leading, spacing: Dimen.margin.regular){
            Text(String.pageText.pairingSetupCharacterSelect)
                .modifier(MediumTextStyle(size: Font.size.light))
            CharacterList(
                selectIdx: self.$selectIdx,
                datas:self.datas,
                cellSpace: self.cellSpace
            )
        }
        .padding(.horizontal, Dimen.margin.regular)
        .onReceive(self.sceneObserver.$screenSize){ size in
            let screenWidth = size.width - (2*Dimen.margin.regular)
            let lineNum = floor(screenWidth /
                                    (ListItem.character.size.width + Dimen.margin.thin))
            self.cellSpace = floor((screenWidth - (ListItem.character.size.width * lineNum)) / (lineNum-1))
            self.datas = self.data.getRow(lineNum: Int(lineNum))
        }
        
    }//body
}


#if DEBUG
struct CharacterSelectBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            CharacterSelectBox( data:CharacterRowData(), selectIdx: .constant(0) )
                .environmentObject(SceneObserver())
                .frame(width:320,height:600)
        }
        .background(Color.brand.bg)
    }
}
#endif
