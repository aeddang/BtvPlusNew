import Foundation
import SwiftUI

extension InputCell{
    static var inputFontSize = Font.size.lightExtra
    static var inputHeight:CGFloat = inputFontSize
   
}
struct InputCell: PageView {
    var title:String = ""
    var titleWidth:CGFloat = Dimen.tab.titleWidth
    var lineLimited:Int = -1
    @Binding var input:String
    var isFocus:Bool = false
    var placeHolder:String = ""
    var keyboardType:UIKeyboardType = .default
    var tip:String? = nil
    var isEditable:Bool = true
    var isSecure:Bool = false
    @State private var inputHeight:CGFloat = Self.inputHeight
    var actionTitle:String? = nil
    var action:(() -> Void)? = nil
    var body: some View {
        HStack(alignment:.top, spacing:0){
            Text(self.title)
                .modifier(MediumTextStyle(size: Font.size.light))
                .multilineTextAlignment(.leading)
                .frame(width:self.titleWidth, alignment: .leading)
                .padding(.top, 14)
            
            VStack(alignment: .leading, spacing:0){
                HStack(alignment: .top, spacing:0){
                    if self.isEditable {
                        if self.lineLimited == -1 {
                            if self.isSecure{
                                SecureField(self.placeHolder, text: self.$input)
                                    .keyboardType(self.keyboardType)
                                    .modifier(MediumTextStyle(
                                                size: Self.inputFontSize))
                            }else{
                                TextField(self.placeHolder, text: self.$input)
                                    .keyboardType(self.keyboardType)
                                    .modifier(MediumTextStyle(
                                        size: Self.inputFontSize))
                            }
                            
                        } else {
                            FocusableTextView(
                                placeholder: "",
                                text:self.$input,
                                isfocusAble: .constant(true),
                                fontSize:Self.inputHeight,
                                usefocusAble: false,
                                inputChanged: {text , size in
                                    //self.input = text
                                    //self.inputHeight = min(size.height, (Self.inputHeight * CGFloat(self.lineLimited)))
                                }
                            ).frame(height : Self.inputHeight * CGFloat(self.lineLimited))
                        }
                    }else{
                        Text(self.input)
                        .modifier(MediumTextStyle(
                                    size: Self.inputFontSize,
                            color: Color.app.blueLight)
                        )
                    }
                    if self.actionTitle != nil{
                        TextButton(
                            defaultText: self.actionTitle!,
                            textModifier:TextModifier(
                                family:Font.family.medium,
                                size:Font.size.thin,
                                color: Color.brand.primary),
                            isUnderLine: true)
                        {_ in
                            guard let action = self.action else { return }
                            action()
                        }
                    }
                }
                .modifier(MatchHorizontal(height: Dimen.tab.regular))
                .padding(.horizontal, Dimen.margin.light)
                .background(Color.app.blueLight)
                if self.tip != nil{
                    Spacer().frame(height:Dimen.margin.thinExtra)
                    Text(self.tip!)
                        .modifier(MediumTextStyle(
                            size: Font.size.thin,
                            color: Color.app.greyLightExtra))
                }
            }
            .overlay(
               Rectangle()
                .stroke(
                    self.isFocus ? Color.app.white : Color.app.blueLight,
                    lineWidth: Dimen.stroke.regular )
            )
        }
    }
}

#if DEBUG
struct InputCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputCell(
                title: "title",
                input: .constant("test"),
                //isFocus: .constant(true),
                tip: "sdsdsdd",
                actionTitle: "btn"
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

