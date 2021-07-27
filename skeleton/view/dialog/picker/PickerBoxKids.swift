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
    let action: () -> Void
    
    var body: some View {
        VStack{
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
                        .modifier(PickMask(size: set.size, eage: .leading))
                        
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
                        .modifier(
                            PickMask(
                                size: set.size,
                                eage: self.sets.count-1 == set.idx ? .trailing : nil
                            )
                        )
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
                        .modifier(
                            PickMask(
                                size: set.size,
                                eage: self.sets.count-1 == set.idx ? .trailing : nil
                            )
                        )
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
                        .modifier(
                            PickMask(
                                size: set.size,
                                eage: self.sets.count-1 == set.idx ? .trailing : nil
                            )
                        )
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
                            RoundedRectangle(cornerRadius:DimenKids.radius.heavy)
                                .modifier(MatchHorizontal(height:DimenKids.tab.light))
                            Rectangle()
                                .modifier(MatchVertical(width:size - DimenKids.radius.regular))
                                .padding(eage, DimenKids.radius.regular)
                        } else {
                            Rectangle()
                                .modifier(MatchVertical(width:size))
                        }
                    }
                )
        }
    }
    
}

