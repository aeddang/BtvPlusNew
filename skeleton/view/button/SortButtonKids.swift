
import Foundation
import SwiftUI
struct SortButtonKids: View{
    var title:String? = nil
    var text:String
    var isFocus:Bool = false
    var isFill:Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.familyKids.bold,
        size: SystemEnvironment.isTablet ? Font.sizeKids.lightExtra : Font.sizeKids.thinExtra,
        color: Color.app.white
    )
    var size:CGFloat = DimenKids.tab.lightExtra
    var padding:CGFloat = DimenKids.margin.thin
    var bgColor:Color = Color.kids.primaryLight
    var cornerRadius:CGFloat = DimenKids.radius.light
    let action: () -> Void
    
    var body: some View {
        
        Button(action: {
            self.action()
        }) {
            ZStack{
                HStack(spacing:DimenKids.margin.thin){
                    if let title = self.title  {
                        Text(title)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(textModifier.color)
                        .opacity(0.6)
                    }
                    Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(textModifier.color)
                    .lineLimit(1)
                    if self.isFill {
                        Spacer().modifier(MatchParent())
                    }
                    Image(AssetKids.icon.sort)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.micro, height: DimenKids.icon.micro)
                }
                .padding(.horizontal, self.padding)
            }
            .frame(height:self.size)
            .background(self.bgColor)
            .clipShape(
                RoundedRectangle(cornerRadius: self.cornerRadius))
            
        }
        .buttonStyle(BorderlessButtonStyle())
       
    }
}
#if DEBUG
struct SortButtonKids_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SortButtonKids(
                title:"test",
                text: "test",
                isFocus: true
            )
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif
