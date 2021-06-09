//
//  AlertBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/02.
//

import Foundation
import SwiftUI
extension AlertBoxKids {
    static let idealWidth:CGFloat = SystemEnvironment.isTablet ? 565: 326
    static let maxWidth:CGFloat = SystemEnvironment.isTablet ? 820 : 428
}
struct AlertBoxKids: PageComponent {
    let maxTextCount:Int = 200
    @Binding var isShowing: Bool
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var tipText: String?
    var referenceText: String?
    var imgButtons: [AlertBtnData]?
    var buttons: [AlertBtnData]
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        VStack{
            VStack (alignment: .center, spacing:0){
                if (self.text?.count ?? 0) > self.maxTextCount {
                    ScrollView{
                        AlertBodyKids(title: self.title, image: self.image, text: self.text, subText: self.subText, tipText: self.tipText, referenceText: self.referenceText)
                    }
                    .padding(.bottom, DimenKids.margin.mediumExtra)
                    
                } else {
                    AlertBodyKids(title: self.title, image: self.image, text: self.text, subText: self.subText, tipText: self.tipText, referenceText: self.referenceText)
                        .padding(.bottom, DimenKids.margin.mediumExtra)
                }
                if self.imgButtons != nil {
                    HStack(spacing:Dimen.margin.regular){
                        ForEach(self.imgButtons!) { btn in
                            ImageButton(
                                defaultImage: btn.img,
                                text: btn.title,
                                isSelected: true ,
                                index: btn.index,
                                size: CGSize(width: DimenKids.icon.heavy, height: DimenKids.icon.heavy)
                                
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            }
                        }
                    }
                    .padding(.bottom, DimenKids.margin.medium)
                }
                HStack(spacing:DimenKids.margin.thin){
                    ForEach(self.buttons) { btn in
                        RectButtonKids(
                            text: btn.title,
                            index: btn.index,
                            isSelected: btn.index == self.buttons.count-1
                        ){idx in
                            self.action(idx)
                            withAnimation{
                                self.isShowing = false
                            }
                        }
                    }
                }
            }
            .modifier(ContentBox())
        }
        .frame(
            minWidth: 0,
            idealWidth: Self.idealWidth,
            maxWidth: Self.maxWidth,
            minHeight: 0,
            maxHeight:.infinity
        )
        .padding(.all, Dimen.margin.heavy)
    }
}

struct AlertBodyKids: PageComponent{
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var tipText: String?
    var referenceText: String?
    var body: some View {
        VStack (alignment: .center, spacing:0){
            if self.title != nil{
                Text(self.title!)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.regular, color: Color.app.brown))
                    .fixedSize(horizontal: false, vertical: true)
                    
            }
            if self.referenceText != nil {
                Text(self.referenceText!)
                    .multilineTextAlignment(.center)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.brown))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, DimenKids.margin.tiny)
                Spacer().modifier(LineHorizontal(color: Color.app.black))
                    .padding(.top, DimenKids.margin.tiny)
            }
            if self.image != nil{
                Image(uiImage: self.image!)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.thin))
                    .padding(.top, DimenKids.margin.light)
                    
            }
            if self.text != nil{
                Text(self.text!)
                    .multilineTextAlignment(.center)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownLight))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, DimenKids.margin.light)
            }
            if self.subText != nil{
                Text(self.subText!)
                    .multilineTextAlignment(.center)
                    .modifier(BoldTextStyle(size: Font.sizeKids.thinExtra, color: Color.app.brownLight))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, DimenKids.margin.thinExtra)
            }
            if self.tipText != nil{
                Text(self.tipText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyleKids(size: Font.sizeKids.tiny, color: Color.app.brownLight))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, DimenKids.margin.tiny)
            }
            
        }
    }
}
