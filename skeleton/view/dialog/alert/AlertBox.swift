//
//  AlertBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/02.
//

import Foundation
import SwiftUI

struct AlertBox: PageComponent {
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
                        AlertBody(title: self.title, image: self.image, text: self.text, subText: self.subText, tipText: self.tipText, referenceText: self.referenceText)
                    }
                    .padding(.top, Dimen.margin.regular)
                    .padding(.bottom, Dimen.margin.medium)
                    .padding(.horizontal, Dimen.margin.regular)
                } else {
                    AlertBody(title: self.title, image: self.image, text: self.text, subText: self.subText, tipText: self.tipText, referenceText: self.referenceText)
                        .padding(.top, Dimen.margin.regular)
                        .padding(.bottom, Dimen.margin.medium)
                        .padding(.horizontal, Dimen.margin.regular)
                }
                if self.imgButtons != nil {
                    HStack(spacing:Dimen.margin.regular){
                        ForEach(self.imgButtons!) { btn in
                            ImageButton(
                                defaultImage: btn.img,
                                text: btn.title,
                                isSelected: true ,
                                index: btn.index,
                                size: CGSize(width: Dimen.icon.heavyExtra, height: Dimen.icon.heavyExtra)
                                
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            }
                        }
                    }
                    .padding(.bottom, Dimen.margin.medium)
                }
                HStack(spacing:0){
                    ForEach(self.buttons) { btn in
                        FillButton(
                            text: btn.title,
                            index: btn.index,
                            isSelected: true ,
                            textModifier: TextModifier(
                                family: Font.family.bold,
                                size: Font.size.lightExtra,
                                color: Color.app.white,
                                activeColor: Color.app.white
                            ),
                            size: Dimen.button.regular,
                            margin: Dimen.margin.thin,
                            bgColor: self.buttons.count == 1
                                ? Color.brand.primary
                                :(btn.index % 2 == 1) ? Color.brand.primary  : Color.brand.secondary
                        ){idx in
                            self.action(idx)
                            withAnimation{
                                self.isShowing = false
                            }
                        }
                    }
                }
            }
            .background(Color.app.blue)
        }
        .frame(
            minWidth: 0,
            idealWidth: SystemEnvironment.isTablet ? 370 : 247,
            maxWidth:  SystemEnvironment.isTablet ? 480 : 320,
            minHeight: 0,
            maxHeight: (self.text?.count ?? 0) > self.maxTextCount
                ? (SystemEnvironment.isTablet ? 480 : 320)
                : .infinity
        )
        .padding(.all, Dimen.margin.heavy)
        
    }
}

struct AlertBody: PageComponent{
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
                    .modifier(BoldTextStyle(size: Font.size.regular))
                    .fixedSize(horizontal: false, vertical: true)
                    
            }
            if self.image != nil{
                Image(uiImage: self.image!)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    .padding(.top, Dimen.margin.medium)
                    
            }
            if self.text != nil{
                Text(self.text!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.medium)
            }
            if self.subText != nil{
                Text(self.subText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.tiny)
            }
            if self.tipText != nil{
                Text(self.tipText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.regular)
            }
            if self.referenceText != nil{
                Text(self.referenceText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyLight))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.tiny)
            }
        }
    }
}
