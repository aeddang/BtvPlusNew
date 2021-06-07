//
//  Picker.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/31.
//

import Foundation
import SwiftUI



struct PickerBox: PageComponent{
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
        GeometryReader { geometry in
            VStack{
                Spacer().modifier(MatchParent())
                VStack{
                    HStack(spacing: 0){
                        if self.sets.count > 0,  let set = self.sets[0] {
                            Picker(selection: self.$selectedA.onChange(self.onSelectedA),label: Text("")) {
                                ForEach(set.datas) { btn in
                                    Text(btn.title).modifier(MediumTextStyle(
                                        size: Font.size.light)
                                    ).tag(btn.index)
                                }
                            }
                            .labelsHidden()
                            .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                            .clipped()
                        }
                        if self.sets.count > 1,let set = self.sets[1] {
                            Picker(selection: self.$selectedB.onChange(self.onSelectedB),label: Text("")) {
                                ForEach(set.datas) { btn in
                                    Text(btn.title).modifier(MediumTextStyle(
                                        size: Font.size.light)
                                    ).tag(btn.index)
                                }
                            }
                            .labelsHidden()
                            .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                            .clipped()
                        }
                        if self.sets.count > 2,let set = self.sets[2]  {
                            Picker(selection: self.$selectedC.onChange(self.onSelectedC),label: Text("")) {
                                ForEach(set.datas) { btn in
                                    Text(btn.title).modifier(MediumTextStyle(
                                        size: Font.size.light)
                                    ).tag(btn.index)
                                }
                            }
                            .labelsHidden()
                            .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                            .clipped()
                        }
                        if self.sets.count > 3,let set = self.sets[3]  {
                            Picker(selection: self.$selectedD.onChange(self.onSelectedD),label: Text("")) {
                                ForEach(set.datas) { btn in
                                    Text(btn.title).modifier(MediumTextStyle(
                                        size: Font.size.light)
                                    ).tag(btn.index)
                                }
                            }
                            .labelsHidden()
                            .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                            .clipped()
                        }
                        
                    }
                    FillButton(
                        text: String.button.complete,
                        isSelected: true
                    ){idx in
                        self.action()
                    }
                    .padding(.bottom, self.sceneObserver.safeAreaBottom)
                }
                .background(Color.app.blue)
            }
        }//geo
    }
    
    func onSelectedA(_ tag: Int) {}
    func onSelectedB(_ tag: Int) {}
    func onSelectedC(_ tag: Int) {}
    func onSelectedD(_ tag: Int) {}
}

