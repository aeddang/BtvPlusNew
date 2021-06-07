//
//  Picker.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/31.
//

import Foundation
import SwiftUI

extension PickerBoxKids{
    static let idealWidth:CGFloat = SystemEnvironment.isTablet ? 627 : 326
    static let maxWidth:CGFloat = SystemEnvironment.isTablet ? 627 : 326
}

struct PickerBoxKids: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let margin:CGFloat = Dimen.margin.heavy
    var title: String?
    var sets: [SelectBtnDataSet]
    @Binding var selectedA:Int
    @Binding var selectedB:Int
    @Binding var selectedC:Int
    @Binding var selectedD:Int
    let action: () -> Void
    
    var body: some View {
        VStack{
            HStack(spacing: 0){
                if self.sets.count > 0,  let set = self.sets[0] {
                    Picker(selection: self.$selectedA.onChange(self.onSelectedA),label: Text("")) {
                        ForEach(set.datas) { btn in
                            Text(btn.title).modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regular,
                                color: Color.app.brownLight)
                            ).tag(btn.index)
                        }
                    }
                    .labelsHidden()
                    .frame(width: set.size)
                    .clipped()
                }
                if self.sets.count > 1,let set = self.sets[1] {
                    Picker(selection: self.$selectedB.onChange(self.onSelectedB),label: Text("")) {
                        ForEach(set.datas) { btn in
                            Text(btn.title).modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regular,
                                color: Color.app.brownLight)
                            ).tag(btn.index)
                        }
                    }
                    .labelsHidden()
                    .frame(width: set.size)
                    .clipped()
                }
                if self.sets.count > 2,let set = self.sets[2]  {
                    Picker(selection: self.$selectedC.onChange(self.onSelectedC),label: Text("")) {
                        ForEach(set.datas) { btn in
                            Text(btn.title).modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regular,
                                color: Color.app.brownLight)
                            ).tag(btn.index)
                        }
                    }
                    .labelsHidden()
                    .frame(width: set.size)
                    .clipped()
                }
                if self.sets.count > 3,let set = self.sets[3]  {
                    Picker(selection: self.$selectedD.onChange(self.onSelectedD),label: Text("")) {
                        ForEach(set.datas) { btn in
                            Text(btn.title).modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regular,
                                color: Color.app.brownLight)
                            ).tag(btn.index)
                        }
                    }
                    .labelsHidden()
                    .frame(width: set.size)
                    .clipped()
                }
                
            }
            RectButtonKids(
                text: String.app.corfirm,
                isSelected: true
            ){idx in
                self.action()
            }
        }
        .background(Color.kids.bg)
        .frame(
            minWidth: 0,
            idealWidth: Self.idealWidth,
            maxWidth: Self.maxWidth,
            minHeight: 0,
            maxHeight: .infinity
        )
        .modifier(ContentBox())
        .padding(.all, Dimen.margin.heavy)
    }
    
    func onSelectedA(_ tag: Int) {}
    func onSelectedB(_ tag: Int) {}
    func onSelectedC(_ tag: Int) {}
    func onSelectedD(_ tag: Int) {}
}

