//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct InputNumberField: PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    var isInit:Bool = false
    var isFocus:Bool = false
    var title:String? = nil
    var text:String? = nil
    var tip:String? = nil
    var msg:String? = nil
    var action: ((_ input:String?) -> Void)
    
    let size:CGFloat = SystemEnvironment.isTablet ? 821 : 346
    let inputSize:Int = 4
    let placeholder:String = "●●●●"
    @State var input:String = ""
    
    func getTextStype()-> TextModifier {
        if #available(iOS 15.0, *) {
            return TextModifier(
                family: Font.familyKids.bold,
                size: Font.sizeKids.regular,
                color: Color.app.brownDeep)
        }
        return TextModifier(
            family: Font.familyKids.medium,
            size: Font.sizeKids.regular,
            color: Color.app.brownDeep)
    }
    
    func getTextSpacing()-> CGFloat {
        if #available(iOS 15.0, *) {
            return DimenKids.item.inputNum.width + Dimen.margin.microUltra
        }
        return DimenKids.item.inputNum.width - Dimen.margin.microUltra
    }
    
    func getHolderSpacing()-> CGFloat {
        return DimenKids.item.inputNum.width - Dimen.margin.microUltra
    }
    
    func getTextLeading()-> CGFloat {
        return (DimenKids.item.inputNum.width)/2 + Font.sizeKids.regular
    }
    
    
    
  
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
                         HStack(spacing:DimenKids.margin.thinExtra){
                            if self.isInit {
                                ZStack(alignment: .leading){
                                    HStack(spacing:DimenKids.margin.lightExtra){
                                        InputNumberCell(isFocus: self.findFocus() == 0)
                                        InputNumberCell(isFocus: self.findFocus() == 1)
                                        InputNumberCell(isFocus: self.findFocus() == 2)
                                        InputNumberCell(isFocus: self.findFocus() == 3)
                                    }
                                    if self.isInit {
                                        ZStack(alignment: .leading){
                                            FocusableTextField( 
                                                text: self.$input,
                                                keyboardType: .numberPad,
                                                placeholder: self.placeholder,
                                                placeholderColor : Color.app.grey,
                                                textAlignment : .left,
                                                maxLength: self.inputSize,
                                                kern: self.getTextSpacing(),
                                                kernHolder: self.getHolderSpacing(),
                                                textModifier: self.getTextStype(),
                                                isfocus: self.isFocus,
                                                isSecureTextEntry:true,
                                                inputChanged: { text in
                                                    
                                                },
                                                inputCopmpleted: { text in
                                                    
                                                })
                                                .frame( height: DimenKids.item.inputNum.height)
                                                .padding(.leading, self.getTextLeading() )
                                        }
                                        .frame(
                                            width: (DimenKids.item.inputNum.width * CGFloat(self.inputSize))
                                                    + (DimenKids.margin.lightExtra * CGFloat(self.inputSize-1)),
                                            height: DimenKids.item.inputNum.height)
                                        .clipped()
                                    }
                                }
                                
                                Button(action: {
                                    self.input = ""
                                    
                                }) {
                                    Image(self.isDeleteable() ? AssetKids.icon.deleteOn : AssetKids.icon.delete)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: DimenKids.icon.light,
                                               height: DimenKids.icon.light)
                                        
                                }
                            }
                        }
                        .padding(.vertical, DimenKids.margin.regularExtra)
                        if let msg = self.msg{
                            Text(msg)
                                .modifier(MediumTextStyleKids(
                                            size: Font.sizeKids.thin,color: Color.kids.primary))
                                
                        }
                        if let text = self.text{
                            Text(text)
                                .kerning(Font.kern.thin)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.tiny, color:Color.app.brownLight))
                                .fixedSize(horizontal: false, vertical: true)
                                
                        }
                        
                        if let tip = self.tip{
                            Text(tip)
                                .modifier(MediumTextStyleKids(
                                    size: Font.sizeKids.tiny,color:Color.app.brownLight ))
                                
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
                            text: String.app.confirm,
                            isSelected: true
                        ){_ in
                            if !self.isInputCompleted() {
                                self.appSceneObserver.event = .toast(
                                    String.alert.incorrectNumberOfCharacter
                                    .replace( self.inputSize.description) )
                            } else {
                                self.action(self.input)
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
            .offset(y:self.isFocus
                        ? SystemEnvironment.isTablet
                            ? -DimenKids.margin.medium : -DimenKids.margin.heavyUltra
                        : 0)
            
        }
        .modifier(MatchParent())
        
        
        .onAppear(){
           
        }
    }//body
    private func findFocus() -> Int {
        return self.input.count
    }
    private func isInputCompleted() -> Bool {
        return self.input.count == self.inputSize
    }
    
    private func isDeleteable() -> Bool {
        return !self.input.isEmpty
    }
    
}

struct InputNumberCell: PageView {
    var isFocus:Bool = false
    
    let radius:CGFloat = DimenKids.radius.lightExtra
    var body: some View {
        Spacer()
        .frame(width: DimenKids.item.inputNum.width, height: DimenKids.item.inputNum.height)
        .background(Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: self.radius))
        .overlay(
            RoundedRectangle(cornerRadius: self.radius)
                .strokeBorder(
                    self.isFocus
                        ? Color.kids.primary
                        : Color.app.sepiaLight,
                    lineWidth: self.isFocus
                        ? DimenKids.stroke.mediumExtra
                        : DimenKids.stroke.regular
                    )
        )
    }
}
            

#if DEBUG
struct InputNumberField_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InputNumberField(
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
