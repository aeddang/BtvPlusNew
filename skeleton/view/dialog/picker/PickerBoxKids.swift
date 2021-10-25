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
    static let maxWidth:CGFloat = SystemEnvironment.isTablet ? 820 : 428
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
    var infinityScrollModelA: InfinityScrollModel = InfinityScrollModel()
    var infinityScrollModelB: InfinityScrollModel = InfinityScrollModel()
    var infinityScrollModelC: InfinityScrollModel = InfinityScrollModel()
    var infinityScrollModelD: InfinityScrollModel = InfinityScrollModel()
    var textModifier:TextModifier = BoldTextStyle(
        size: Font.sizeKids.regular,
        color: Color.app.brownLight).textModifier 
    
    
    let action: () -> Void
    
    var body: some View {
        VStack{
            VStack{
                HStack(spacing: 0){
                    if self.sets.count > 0,  let set = self.sets[0] {
                        if #available(iOS 15.0, *) {
                            CustomPicker(
                                infinityScrollModel: self.infinityScrollModelA,
                                set: set,
                                selected: self.selectedA,
                                textModifier: self.textModifier,
                                bgColor: Color.kids.bg,
                                selectBgColor: Color.app.ivoryDeep,
                                tabHeight: DimenKids.tab.light){ select in
                                    self.selectedA = select
                                }
                                .frame(width: set.size)
                                .modifier(PickMask(size: set.size, eage: .leading))
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        let select = set.datas[self.selectedA]
                                        self.infinityScrollModelA.uiEvent = .scrollMove(select.hashId, .center)
                                    }
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
                            .frame(width: set.size)
                            .modifier(PickMask(size: set.size, eage: .leading))
                        }
                        
                    }
                    if self.sets.count > 1,let set = self.sets[1] {
                        if #available(iOS 15.0, *) {
                            CustomPicker(
                                infinityScrollModel: self.infinityScrollModelB,
                                set: set,
                                selected: self.selectedB,
                                textModifier: self.textModifier,
                                bgColor: Color.kids.bg,
                                selectBgColor: Color.app.ivoryDeep,
                                tabHeight: DimenKids.tab.light){ select in
                                    self.selectedB = select
                                }
                                .frame(width: set.size)
                                .modifier(
                                    PickMask(
                                        size: set.size,
                                        eage: self.sets.count-1 == set.idx ? .trailing : nil
                                    )
                                )
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        let select = set.datas[self.selectedB]
                                        self.infinityScrollModelB.uiEvent = .scrollMove(select.hashId, .center)
                                    }
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
                            .frame(width: set.size)
                            .modifier(
                                PickMask(
                                    size: set.size,
                                    eage: self.sets.count-1 == set.idx ? .trailing : nil
                                )
                            )
                        }
                    }
                    if self.sets.count > 2,let set = self.sets[2]  {
                        if #available(iOS 15.0, *) {
                            CustomPicker(
                                infinityScrollModel: self.infinityScrollModelC,
                                set: set,
                                selected: self.selectedC,
                                textModifier: self.textModifier,
                                bgColor: Color.kids.bg,
                                selectBgColor: Color.app.ivoryDeep,
                                tabHeight: DimenKids.tab.light){ select in
                                    self.selectedC = select
                                }
                                .frame(width: set.size)
                                .modifier(
                                    PickMask(
                                        size: set.size,
                                        eage: self.sets.count-1 == set.idx ? .trailing : nil
                                    )
                                )
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        let select = set.datas[self.selectedC]
                                        self.infinityScrollModelC.uiEvent = .scrollMove(select.hashId, .center)
                                    }
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
                            .frame(width: set.size)
                            .modifier(
                                PickMask(
                                    size: set.size,
                                    eage: self.sets.count-1 == set.idx ? .trailing : nil
                                )
                            )
                        }
                    }
                    if self.sets.count > 3,let set = self.sets[3]  {
                        if #available(iOS 15.0, *) {
                            CustomPicker(
                                infinityScrollModel: self.infinityScrollModelD,
                                set: set,
                                selected: self.selectedD,
                                textModifier: self.textModifier,
                                bgColor: Color.kids.bg,
                                selectBgColor: Color.app.ivoryDeep,
                                tabHeight: DimenKids.tab.light){ select in
                                    self.selectedD = select
                                }
                                .frame(width: set.size)
                                .modifier(
                                    PickMask(
                                        size: set.size,
                                        eage: self.sets.count-1 == set.idx ? .trailing : nil
                                    )
                                )
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        let select = set.datas[self.selectedD]
                                        self.infinityScrollModelD.uiEvent = .scrollMove(select.hashId, .center)
                                    }
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
                            .frame(width: set.size)
                            .modifier(
                                PickMask(
                                    size: set.size,
                                    eage: self.sets.count-1 == set.idx ? .trailing : nil
                                )
                            )
                        }
                    }
                    
                }
                RectButtonKids(
                    text: String.app.confirm,
                    isSelected: true
                ){idx in
                    self.action()
                }
            }
            .modifier(ContentBox())
        }
        .frame(
            minWidth: 0,
            idealWidth: Self.idealWidth,
            maxWidth: Self.maxWidth,
            minHeight: 0,
            maxHeight: .infinity
        )
        .padding(.all, Dimen.margin.heavy)
    }
    
    func onSelectedA(_ tag: Int) {}
    func onSelectedB(_ tag: Int) {}
    func onSelectedC(_ tag: Int) {}
    func onSelectedD(_ tag: Int) {}
    
    struct PickMask: ViewModifier {
        var size:CGFloat = 0
        var eage:Edge.Set? = .leading
        func body(content: Content) -> some View {
            return content
                .mask(
                    ZStack(alignment: .center){
                        if let eage = self.eage {
                            RoundedRectangle(cornerRadius:  DimenKids.radius.heavy)
                                .modifier(MatchHorizontal( height:DimenKids.tab.light))
                            Rectangle()
                                .modifier(MatchVertical(width:size - DimenKids.radius.heavy))
                                .padding(eage, DimenKids.radius.heavy)
                        } else {
                            Rectangle()
                                .modifier(MatchVertical(width:size))
                        }
                    }
                )
        }
    }
    
}

