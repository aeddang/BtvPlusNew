import Foundation
import SwiftUI


struct InputCellKids: PageView {
    var title:String = ""
    var lineLimited:Int = -1
    @Binding var input:String
    var inputFontSize = Font.size.tiny
    var isFocus:Bool = false
    var placeHolder:String = ""
    var keyboardType:UIKeyboardType = .default
    var tip:String? = nil
    var isEditable:Bool = true
    var isSecure:Bool = false
    var kern: CGFloat? = nil
    var actionTitle:String? = nil
    var action:(() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:DimenKids.margin.tinyExtra){
            Text(self.title)
                .modifier(BoldTextStyleKids(size: Font.size.thin, color:Color.app.brown))
                .multilineTextAlignment(.leading)
               
            HStack(alignment: .top, spacing:0){
                if self.isEditable {
                    if self.lineLimited == -1 {
                        if self.isSecure{
                            SecureField(self.placeHolder, text: self.$input)
                                .keyboardType(self.keyboardType)
                                .modifier(BoldTextStyleKids(
                                            size: self.inputFontSize, color: Color.kids.primary))
                        }else{
                            TextField(self.placeHolder, text: self.$input)
                                
                                .keyboardType(self.keyboardType)
                                .modifier(BoldTextStyleKids(
                                            size: self.inputFontSize, color: Color.kids.primary))
                        }
                        
                    } else {
                        FocusableTextView(
                            text:self.$input,
                            placeholder: "",
                            isfocus: true,
                            textModifier:TextModifier(
                                family:Font.familyKids.bold,
                                size:self.inputFontSize,
                                color: Color.kids.primary),
                            usefocusAble: false,
                            kern: self.kern,
                            inputChanged: {text , size in
                                //self.input = text
                                //self.inputHeight = min(size.height, (Self.inputHeight * CGFloat(self.lineLimited)))
                            }
                        ).frame(height : self.inputFontSize * CGFloat(self.lineLimited))
                    }
                }else{
                    Text(self.input)
                        .kerning(self.kern ?? Font.kern.regular)
                        .modifier(BoldTextStyleKids(
                                    size: self.inputFontSize,
                            color: Color.app.brown)
                        )
                }
                if self.actionTitle != nil{
                    TextButton(
                        defaultText: self.actionTitle!,
                        textModifier:TextModifier(
                            family:Font.familyKids.medium,
                            size:Font.sizeKids.thin,
                            color: Color.kids.primary),
                        isUnderLine: true)
                    {_ in
                        guard let action = self.action else { return }
                        action()
                    }
                }
            }
            .modifier(MatchHorizontal(height: DimenKids.tab.light))
            .padding(.horizontal, DimenKids.margin.tiny)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
            .overlay(
                RoundedRectangle(cornerRadius: DimenKids.radius.light)
                .stroke(
                    self.isFocus ? Color.kids.primary : Color.transparent.clear,
                    lineWidth: DimenKids.stroke.mediumExtra )
            )
            if self.tip != nil{
                Spacer().frame(height:DimenKids.margin.thinExtra)
                Text(self.tip!)
                    .modifier(MediumTextStyleKids(
                        size: Font.sizeKids.thin,
                        color: Color.app.brownLight))
            }
        }
        
    }
}

#if DEBUG
struct InputCellKids_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputCellKids(
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

