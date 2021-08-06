//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct InputBox: PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    struct Data:Identifiable{
        let id:String = UUID().uuidString
        var idx:Int = 0
        var title:String = ""
        var text:String? = nil
        var inputSize:Int? = nil
    }
    @Binding var input:String 
    var isFocus:Bool = false
    var isInit:Bool = false
    var title:String? = nil
    var text:String? = nil
    var tip:String? = nil
    var msg:String? = nil
    var placeHolder:String = ""
    var inputSize:Int = 4
    var inputSizeMin:Int? = nil
    var keyboardType:UIKeyboardType = .default
    var isSecure:Bool = false
    var radios: [InputBox.Data]? = nil
    var size:CGFloat = SystemEnvironment.isTablet ? 346 : 265
    var action: ((_ input:String?, _ idx:Int?) -> Void)
    
    @State var selectedText:String? = nil
    @State var selectedIdx:Int? = nil
    @State var selectedInputSize:Int? = nil
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.action(nil, nil)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
                
            VStack{
                VStack (alignment: .leading, spacing:0){
                    if let title = self.title{
                        ZStack{
                            Spacer().modifier(MatchHorizontal(height: 0))
                            Text(title)
                                .modifier(BoldTextStyle(size: Font.size.regular))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    }
                    if self.radios != nil {
                        HStack(spacing:Dimen.margin.regular){
                            ForEach(self.radios!) { radio in
                                RadioButton(
                                    isChecked: self.selectedIdx == radio.idx,
                                    size: CGSize(width: Dimen.icon.lightExtra, height: Dimen.icon.lightExtra),
                                    text: radio.title,
                                    textSize: Font.size.thinExtra
                                ){ isSelected in
                                    if !isSelected {return}
                                    self.selectedIdx = radio.idx
                                    self.selectedText = radio.text
                                    self.selectedInputSize = radio.inputSize
                                }
                            }
                        }
                        .padding(.top, Dimen.margin.medium)
                        if let text = self.selectedText{
                            Text(text)
                                .modifier(MediumTextStyle(size: Font.size.lightExtra))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Dimen.margin.regular)
                        }
                    }
                    if let text = self.text{
                        Text(text)
                            .modifier(MediumTextStyle(size: Font.size.lightExtra))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Dimen.margin.regular)
                    }
                    ZStack{
                        if self.isInit {
                            FocusableTextField(
                                text: self.$input,
                                keyboardType: self.keyboardType,
                                placeholder: self.placeHolder,
                                maxLength: self.selectedInputSize ?? self.inputSize,
                                kern: 1,
                                textModifier: BoldTextStyle(size: Font.size.regular).textModifier,
                                isfocus: self.isFocus,
                                isSecureTextEntry:self.isSecure,
                                inputCopmpleted: { text in
                                    self.action(self.input, self.selectedIdx)
                                })
                        }
                    }
                    .modifier(MatchHorizontal(height: Dimen.tab.light))
                    .background(Color.app.blueLight)
                    .padding(.top, Dimen.margin.thin)
                    
                    if let tip = self.tip{
                        Text(tip)
                            .modifier(MediumTextStyle(
                                size: Font.size.tiny,color:Color.app.grey ))
                            .padding(.top, Dimen.margin.thin)
                            
                    }
                    if let msg = self.msg{
                        Text(msg)
                            .modifier(MediumTextStyle(
                                        size: Font.size.tiny,color: Color.brand.primary))
                            .padding(.top, Dimen.margin.thin)
                            
                    }
                    
                }
                .padding(.horizontal, Dimen.margin.regular)
                HStack(spacing:0){
                    FillButton(
                        text: String.app.cancel,
                        isSelected: true ,
                        textModifier: TextModifier(
                            family: Font.family.bold,
                            size: Font.size.lightExtra,
                            color: Color.app.white,
                            activeColor: Color.app.white
                        ),
                        size: Dimen.button.regular,
                        bgColor:Color.brand.secondary
                    ){_ in
                        self.action(nil, nil)
                    }
                    
                    FillButton(
                        text: String.app.confirm,
                        isSelected: self.isInputCompleted() ,
                        textModifier: TextModifier(
                            family: Font.family.bold,
                            size: Font.size.lightExtra,
                            color: Color.app.white,
                            activeColor: Color.app.white
                        ),
                        size: Dimen.button.regular,
                        bgColor:Color.brand.primary
                    ){_ in
                        if !self.isInputCompleted() {
                            self.appSceneObserver.event = .toast(
                                String.alert.incorrectNumberOfCharacter
                                .replace( (self.selectedInputSize ?? self.inputSize).description))
                        } else {
                            self.action(self.input, self.selectedIdx)
                        }
                        
                    }
                }
                .padding(.top, Dimen.margin.medium)
            }
            .padding(.top, Dimen.margin.regular)
            .frame( width: self.size )
            .background(Color.app.blue)
        }
        .modifier(MatchParent())
        
        .onAppear(){
            guard let radios = self.radios else {return}
            self.selectedIdx = radios.first?.idx
            self.selectedText = radios.first?.text
            self.selectedInputSize = radios.first?.inputSize
        }
    }//body
    
    
    func isInputCompleted() -> Bool {
        let size = self.selectedInputSize ?? self.inputSize
        if let min = self.inputSizeMin {
            return min < self.input.count && self.input.count <= size
        } else{
            return self.input.count == size
        }
    }
}


#if DEBUG
struct InputBox_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InputBox(
                input: .constant("test"),
                title: String.alert.watchLv,
                text: String.alert.watchLvInput,
                tip: String.alert.incorrectNumberOfCharacter
            ){ input, idx in
                
            }
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif
