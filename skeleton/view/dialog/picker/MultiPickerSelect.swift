//
//  Picker.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/31.
//

import Foundation
import SwiftUI
extension View {
    func multiPicker(isShowing: Binding<Bool>,
               title: String?,
               sets:[SelectBtnDataSet],
               action: @escaping (Int, Int , Int, Int) -> Void) -> some View {
        
       return MultiPickerSelect(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            sets:sets,
            action:action)
    }
}

struct SelectBtnDataSet:Identifiable, Equatable{
    let id = UUID.init()
    var idx:Int = 0
    var selectIdx:Int = 0
    let title:String
    let datas:[SelectBtnData]
    var size:CGFloat = SystemEnvironment.isTablet ? 60 : 120
}


struct MultiPickerSelect<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let margin:CGFloat = Dimen.margin.heavy
    let presenting: () -> Presenting
    var title: String?
    var sets: [SelectBtnDataSet]
    let action: (Int, Int , Int, Int) -> Void
    @State var selectedA:Int = 0
    @State var selectedB:Int = 0
    @State var selectedC:Int = 0
    @State var selectedD:Int = 0
    @State var isUpdated:Bool = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                let a = self.sets.count > 0 ? self.sets[0].selectIdx : -1
                let b = self.sets.count > 1 ? self.sets[1].selectIdx : -1
                let c = self.sets.count > 2 ? self.sets[2].selectIdx : -1
                let d = self.sets.count > 3 ? self.sets[3].selectIdx : -1
                self.action(a,b,c,d)
                withAnimation{
                    self.isShowing = false
                }
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            if SystemEnvironment.currentPageType == .btv {
                PickerBox(
                    title:self.title,
                    sets:self.sets,
                    isShowing:self.isShowing,
                    selectedA:self.$selectedA,
                    selectedB:self.$selectedB,
                    selectedC:self.$selectedC,
                    selectedD:self.$selectedD
                ){
                    self.action(self.selectedA, self.selectedB, self.selectedC, self.selectedD)
                }
            } else {
                PickerBoxKids(
                    title:self.title,
                    sets:self.sets,
                    selectedA:self.$selectedA,
                    selectedB:self.$selectedB,
                    selectedC:self.$selectedC,
                    selectedD:self.$selectedD
                ){
                    self.action(self.selectedA, self.selectedB, self.selectedC, self.selectedD)
                }
            }
        }
        .opacity(self.isShowing ? 1 : 0)
        .onReceive( [self.isShowing].publisher ) { isShow in
            if self.sets.isEmpty {return}
            if isShow {
                if self.isUpdated {return}
                self.selectedA = self.sets.count > 0 ? self.sets[0].selectIdx : -1
                self.selectedB = self.sets.count > 1 ? self.sets[1].selectIdx : -1
                self.selectedC = self.sets.count > 2 ? self.sets[2].selectIdx : -1
                self.selectedD = self.sets.count > 3 ? self.sets[3].selectIdx : -1
                self.isUpdated = true
            } else {
                self.isUpdated = false
            }
            DataLog.d("isShowing update", tag: "multiPicker")
        }
    }
}

#if DEBUG
struct MultiPickerSelect_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .multiPicker(
            isShowing: .constant(true),
            title:"TEST",
            sets:
                [
                    SelectBtnDataSet(
                        title: "Test",
                        datas: [
                        SelectBtnData(title:"test" , index:0) ,
                        SelectBtnData(title:"test1" , index:1)]),
                    SelectBtnDataSet(
                        title: "Test",
                        datas: [
                        SelectBtnData(title:"test" , index:0) ,
                        SelectBtnData(title:"test1" , index:1)]),
                    SelectBtnDataSet(
                        title: "Test",
                        datas: [
                        SelectBtnData(title:"test" , index:0) ,
                        SelectBtnData(title:"test1" , index:1)])
                ]
        ){ _, _, _, _ in
        
        }

    }
}
#endif
