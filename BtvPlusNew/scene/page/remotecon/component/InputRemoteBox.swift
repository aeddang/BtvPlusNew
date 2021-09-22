//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct InputRemoteBox: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var setup:Setup

    
    var isInit:Bool = false
    var title:String = ""
    var type:RemoteInputType = .text
    var placeHolder:String = ""
    var tip:String? = nil
    var inputSize:Int = 10
    var inputSizeMin:Int? = nil
    var keyboardType:UIKeyboardType = .default

    var action: (_ input:String?, _ type:RemoteInputType) -> Void
    @State var input:String = ""
    @State var isFocus:Bool = true
    @State var selectedText:String? = nil
    @State var selectedInputSize:Int? = nil
    @State var safeAreaBottom:CGFloat = Dimen.app.keyboard
    var body: some View {
        VStack(alignment: .center) {
            HStack{
                Spacer()
                Button(action: {
                    AppUtil.hideKeyboard()
                    if self.setup.remoconVibration {
                        UIDevice.vibrate()
                    }
                    self.action(nil, self.type)
                }) {
                    Image(Asset.remote.close)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.medium,
                               height: Dimen.icon.medium)
                }
            }
            .padding(.all, Dimen.margin.thin)
            Spacer()
            VStack (alignment: .center, spacing:0){
                Text(self.title)
                    .modifier(BoldTextStyle(size: SystemEnvironment.isTablet ? Font.size.regular : Font.size.medium))
                    
                if self.isInit {
                    VStack{
                        FocusableTextField(
                            text:self.$input,
                            keyboardType: self.keyboardType,
                            placeholder: self.placeHolder,
                            maxLength: self.selectedInputSize ?? self.inputSize,
                            kern: 1,
                            textModifier: BoldTextStyle(size: Font.size.black).textModifier,
                            isfocus: self.isFocus,
                            isSecureTextEntry:false,
                           
                            inputCopmpleted: { text in
                                
                                self.action(text + " ", self.type)
                            })
                        Spacer().modifier(MatchHorizontal(height: 1))
                            .background(Color.app.white.opacity(0.4))
                    }
                    .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.regular :  Dimen.margin.heavyExtra)
                    .frame(
                        width: min( Dimen.button.regularHorizontal , Font.size.black * CGFloat(self.inputSize))
                    )
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
                    size: Dimen.button.medium,
                    bgColor:Color.brand.primary
                ){_ in
                    
                    if self.setup.remoconVibration {
                        UIDevice.vibrate()
                    }
                    if !self.isInputCompleted() {
                        self.appSceneObserver.event = .toast(
                            String.alert.incorrectNumberOfCharacter
                            .replace( (self.selectedInputSize ?? self.inputSize).description))
                    } else {
                        self.action(self.input, self.type)
                    }
                    
                }
                .frame( width:  Dimen.button.regularHorizontal )
                .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.mediumExtra : Dimen.margin.medium)
                
                if let tip = self.tip {
                    Text(tip)
                        .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.thin : Font.size.lightExtra))
                        .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.tinyUltra : Dimen.margin.thin)
                }
            }
            .frame(
                 height: CGFloat(SystemEnvironment.isTablet ? 253 : 205)
            )
            Spacer()
        }
        .modifier(MatchParent())
        .padding(.top, self.sceneObserver.safeAreaTop)
        .padding(.bottom, self.safeAreaBottom)
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .background(Color.transparent.black70)
        .onAppear(){
            
        }
        .onTapGesture {
            self.isFocus = false
        }
        
    }//body
    
    
    func isInputCompleted() -> Bool {
        let size = self.selectedInputSize ?? self.inputSize
        if let min = self.inputSizeMin {
            return min <= self.input.count && self.input.count <= size
        } else{
            return self.input.count == size
        }
    }
}


#if DEBUG
struct InputRemoteBox_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InputRemoteBox(
                isInit: true,
                title: String.remote.inputText,
                placeHolder:String.remote.inputTextHolder,
                inputSize: 8,
                inputSizeMin: 1
                
               
            ){ input, type in
                
            }
        }
        .frame(width: 420, height: 620)
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(AppSceneObserver())
        .environmentObject(KeyboardObserver())
        .environmentObject(Pairing())
    }
}
#endif
