//
//  ReflashSpinner.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/05.
//
import Foundation
import SwiftUI
extension ReflashSpinner{
    static let DEGREE_MAX:Double = 80
}
struct ReflashSpinner: PageComponent {
    @Binding var progress:Double
    var text:String? = nil
    var body: some View {
        VStack{
            Image(Asset.shape.spinner)
                .resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                .rotationEffect(.degrees(self.progress * 2.0 ) )
            if text != nil {
                Text(text!)
                .modifier(LightTextStyle(size: Font.size.lightExtra, color: Color.app.grey))
            }
        }
        .modifier(MatchHorizontal(height: 90, margin: 0))
        .opacity(self.progress / Self.DEGREE_MAX)
    }//body
}

#if DEBUG
struct ReflashSpinner_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ReflashSpinner(progress: .constant(90))
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 500, alignment: .center)
        }
    }
}
#endif
