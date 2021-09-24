//
//  Picker.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/31.
//

import Foundation
import SwiftUI
import Combine



struct PickerBox: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let margin:CGFloat = Dimen.margin.heavy
    var title: String?
    var sets: [SelectBtnDataSet]
    var isShowing: Bool
    @Binding var selectedA:Int
    @Binding var selectedB:Int
    @Binding var selectedC:Int
    @Binding var selectedD:Int
    var infinityScrollModelA: InfinityScrollModel = InfinityScrollModel()
    var infinityScrollModelB: InfinityScrollModel = InfinityScrollModel()
    var infinityScrollModelC: InfinityScrollModel = InfinityScrollModel()
    var infinityScrollModelD: InfinityScrollModel = InfinityScrollModel()
    var textModifier:TextModifier = MediumTextStyle(size: Font.size.light).textModifier
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                Spacer().modifier(MatchParent())
                VStack{
                    HStack(spacing: 0){
                        if self.sets.count > 0,  let set = self.sets[0] {
                            if #available(iOS 15.0, *) {
                                CustomPicker(
                                    infinityScrollModel: self.infinityScrollModelA,
                                    set: set,
                                    selected: self.selectedA,
                                    textModifier: self.textModifier
                                ){ select in
                                        self.selectedA = select
                                    }
                                
                            } else {
                                Picker(selection: self.$selectedA.onChange(self.onSelectedA),label: Text("")) {
                                    ForEach(set.datas) { btn in
                                        Text(btn.title)
                                            .font(.custom(textModifier.family, size: textModifier.size))
                                            .foregroundColor(textModifier.color)
                                            .tag(btn.index)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                                .clipped()
                            }
                           
                        }
                        if self.sets.count > 1,let set = self.sets[1] {
                            if #available(iOS 15.0, *) {
                                CustomPicker(
                                    infinityScrollModel: self.infinityScrollModelB,
                                    set: set,
                                    selected: self.selectedB,
                                    textModifier: self.textModifier){ select in
                                        self.selectedB = select
                                    }
                            } else {
                                Picker(selection: self.$selectedB.onChange(self.onSelectedB),label: Text("")) {
                                    ForEach(set.datas) { btn in
                                        Text(btn.title)
                                            .font(.custom(textModifier.family, size: textModifier.size))
                                            .foregroundColor(textModifier.color)
                                            .tag(btn.index)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                                .clipped()
                            }
                        }
                        if self.sets.count > 2,let set = self.sets[2]  {
                            if #available(iOS 15.0, *) {
                                CustomPicker(
                                    infinityScrollModel: self.infinityScrollModelC,
                                    set: set,
                                    selected: self.selectedC,
                                    textModifier: self.textModifier){ select in
                                        self.selectedC = select
                                    }
                            } else {
                                Picker(selection: self.$selectedC.onChange(self.onSelectedC),label: Text("")) {
                                    ForEach(set.datas) { btn in
                                        Text(btn.title)
                                            .font(.custom(textModifier.family, size: textModifier.size))
                                            .foregroundColor(textModifier.color)
                                            .tag(btn.index)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                                .clipped()
                            }
                        }
                        if self.sets.count > 3,let set = self.sets[3]  {
                            if #available(iOS 15.0, *) {
                                CustomPicker(
                                    infinityScrollModel: self.infinityScrollModelD,
                                    set: set,
                                    selected: self.selectedD,
                                    textModifier: self.textModifier){ select in
                                        self.selectedD = select
                                    }
                            } else {
                                Picker(selection: self.$selectedD.onChange(self.onSelectedD),label: Text("")) {
                                    ForEach(set.datas) { btn in
                                        Text(btn.title)
                                            .font(.custom(textModifier.family, size: textModifier.size))
                                            .foregroundColor(textModifier.color)
                                            .tag(btn.index)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: (geometry.size.width - (self.margin*2)) / CGFloat(self.sets.count))
                                .clipped()
                            }
                        }
                        
                    }
                    FillButton(
                        text: String.button.complete,
                        isSelected: true
                    ){idx in
                        self.action()
                    }
                    .padding(.bottom, self.sceneObserver.safeAreaIgnoreKeyboardBottom)
                }
                .background(Color.app.blue)
                
            }
            .offset(y:self.isShowing ? 0 : 200)
        }//geo
    }
    
    func onSelectedA(_ tag: Int) {}
    func onSelectedB(_ tag: Int) {}
    func onSelectedC(_ tag: Int) {}
    func onSelectedD(_ tag: Int) {}
}




