//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct InputNumberBox: PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    var isInit:Bool = false
    var title:String? = nil
    var text:String? = nil
    var tip:String? = nil
    var msg:String? = nil
    var size:CGFloat = SystemEnvironment.isTablet ? 821 : 346
    
    var action: ((_ input:String?) -> Void)
    
    @State var focusIdx:Int = -1
    let inputSize:Int = 4
    @State var input1:String = ""
    @State var input2:String = ""
    @State var input3:String = ""
    @State var input4:String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            Spacer().modifier(MatchParent())
                .background(Color.transparent.black70)
            
            VStack{
                VStack{
                    VStack (alignment: .center, spacing:0){
                        if let title = self.title{
                            Text(title)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.regular, color: Color.app.brown))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(spacing:DimenKids.margin.tiny){
                            if self.isInit {
                                ZStack{
                                    HStack(spacing:DimenKids.margin.lightExtra){
                                        InputNumberItem(
                                            idx: 0,
                                            input: self.$input1,
                                            focusIdx: self.focusIdx){
                                                self.focusIdx = 1
                                            }
                                        InputNumberItem(
                                            idx: 1,
                                            input: self.$input2,
                                            focusIdx: self.focusIdx){
                                                self.focusIdx = 2
                                            }
                                        InputNumberItem(
                                            idx: 2,
                                            input: self.$input3,
                                            focusIdx: self.focusIdx){
                                                self.focusIdx = 3
                                            }
                                        InputNumberItem(
                                            idx: 3,
                                            input: self.$input4,
                                            focusIdx: self.focusIdx){
                                                self.focusIdx = -1
                                                AppUtil.hideKeyboard()
                                            }
                                    }
                                    Spacer().frame(
                                        width:(DimenKids.item.inputNum.width + (DimenKids.margin.tiny-1))
                                            * CGFloat(self.inputSize),
                                        height: DimenKids.item.inputNum.height)
                                        .background(Color.transparent.clearUi)
                                        .onTapGesture {
                                            self.focusIdx = self.findFocus()
                                        }
                                }
                                Button(action: {
                                    self.input1 = ""
                                    self.input2 = ""
                                    self.input3 = ""
                                    self.input4 = ""
                                    self.focusIdx = 0
                                    
                                    
                                }) {
                                    Image(AssetKids.icon.delete)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: DimenKids.icon.light,
                                               height: DimenKids.icon.light)
                                        
                                }
                            }
                            
                        }
                        .padding(.vertical, DimenKids.margin.regularExtra)
                        
                        if let text = self.text{
                            Text(text)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.tiny, color:Color.app.brownLight))
                                .fixedSize(horizontal: false, vertical: true)
                                
                        }
                        
                        if let tip = self.tip{
                            Text(tip)
                                .modifier(MediumTextStyleKids(
                                    size: Font.sizeKids.tiny,color:Color.app.brownLight ))
                                
                        }
                        if let msg = self.msg{
                            Text(msg)
                                .modifier(MediumTextStyleKids(
                                            size: Font.sizeKids.tiny,color: Color.kids.primary))
                                
                        }
                    }
                   
                    HStack(spacing:DimenKids.margin.thin){
                        RectButtonKids(
                            text: String.app.cancel,
                            isSelected: false
                        ){_ in
                            self.action(nil)
                        }
                        
                        RectButtonKids(
                            text: String.app.corfirm,
                            isSelected: true
                        ){_ in
                            if !self.isInputCompleted() {
                                self.appSceneObserver.event = .toast(
                                    String.alert.incorrectNumberOfCharacter
                                    .replace( self.inputSize.description) )
                            } else {
                                self.action(self.input1 + self.input2 + self.input3 + self.input4)
                            }
                        }
                        .opacity(self.isInputCompleted() ? 1.0 : 0.3)
                    }
                    .padding(.top, DimenKids.margin.regularExtra )
                }
                .modifier(ContentBox())
            }
            .frame(
                minWidth: 0,
                maxWidth: self.size,
                minHeight: 0,
                maxHeight:.infinity
            )
            
        }
        .modifier(MatchParent())
        .onTapGesture {
            self.focusIdx = -1
            AppUtil.hideKeyboard()
        }
        .onReceive(self.keyboardObserver.$isOn) { isOn in
            
        }
        .onAppear(){
            self.focusIdx = 0
        }
    }//body
    
    private func findFocus() -> Int {
        if self.input1.isEmpty {return 0}
        if self.input2.isEmpty {return 1}
        if self.input3.isEmpty {return 2}
        if self.input4.isEmpty {return 3}
        return 0
    }
    private func isInputCompleted() -> Bool {
        if self.input1.isEmpty {return false}
        if self.input2.isEmpty {return false}
        if self.input3.isEmpty {return false}
        if self.input4.isEmpty {return false}
        return true
    }
}

struct InputNumberItem: PageView {
    let idx:Int
    @Binding var input:String
    var focusIdx:Int
    var action: () -> Void
    
    let radius:CGFloat = DimenKids.radius.lightExtra
    var body: some View {
        ZStack{
            FocusableTextField(
                text: self.$input,
                keyboardType: .numberPad,
                placeholder: "●",
                maxLength: 1,
                textModifier: TextModifier(
                    family: Font.familyKids.bold,
                    size: Font.sizeKids.black,
                    color: Color.app.brownDeep),
                isfocus: self.focusIdx == self.idx,
                isSecureTextEntry:true,
                inputChanged : { _ in
                    if self.input.isEmpty {return}
                    self.action()
                })
        }
        .frame(width: DimenKids.item.inputNum.width, height: DimenKids.item.inputNum.height)
        .background(Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: self.radius))
        .overlay(
            RoundedRectangle(cornerRadius: self.radius)
                .stroke(
                    self.focusIdx == self.idx
                        ? Color.kids.primary
                        : Color.app.sepiaLight,
                    lineWidth: self.focusIdx == self.idx
                        ? DimenKids.stroke.mediumExtra
                        : DimenKids.stroke.regular
                    )
        )
    }
}
            

#if DEBUG
struct InputNumberBox_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InputNumberBox(
                title: String.alert.watchLv,
                text: String.alert.watchLvInput,
                tip: String.alert.incorrectNumberOfCharacter
            ){ input in
                
            }
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif
