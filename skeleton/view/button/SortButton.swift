
import Foundation
import SwiftUI
struct SortButton: View{
    var title:String? = nil
    var text:String
    var isFocus:Bool = false
    var isFill:Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.lightExtra,
        color: Color.app.white
    )
    var size:CGFloat = Dimen.tab.regular
    var padding:CGFloat = Dimen.margin.thin
    var bgColor:Color = Color.app.blueLight
    var strokeColor:Color = Color.app.greyExtra
    var cornerRadius:CGFloat = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.thin){
                    if self.title != nil {
                        Text(self.title!)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(textModifier.color)
                        .opacity(0.6)
                    }
                    Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(textModifier.color)
                    if self.isFill {
                        Spacer().modifier(MatchParent())
                    }
                    Image(Asset.icon.sort)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                }
                .padding(.horizontal, self.padding)
            }
            .frame(height:self.size)
            .background(self.bgColor)
            .clipShape(
                RoundedRectangle(cornerRadius: self.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(
                            self.isFocus ? Color.app.white
                            :  self.isFill ? self.strokeColor : Color.app.blueLight,
                            lineWidth: self.isFill ? 1 : 3)
                
            )
        }
    }
}
#if DEBUG
struct SortButtonButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SortButton(
                title:"test",
                text: "test",
                isFocus: true,
                isFill: true,
                bgColor: Color.app.blue
            )
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif
