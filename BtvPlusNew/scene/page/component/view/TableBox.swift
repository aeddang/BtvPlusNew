//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct TableBox: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    struct Data:Identifiable{
        let id:String = UUID().uuidString
        var title:String = ""
        var text:String = ""
        var axis:Axis = .horizontal
    }
    var datas: [TableBox.Data]? = nil
    var headerSize:CGFloat = SystemEnvironment.isTablet ? 80 : 57
    var bodySize:CGFloat = SystemEnvironment.isTablet ? 234 : 167
    var body: some View {
        VStack (alignment: .leading, spacing:1){
           if self.datas != nil {
                ForEach(self.datas!) { data in
                    if data.axis == .horizontal {
                     TableBoxItemHorizontal(
                        data: data,
                        headerSize: self.headerSize,
                        bodySize: self.bodySize
                        )
                    } else {
                        TableBoxItemVertical(
                            data: data
                        )
                    }
                }
           }
        }
        .background(Color.app.blue)
        .onAppear(){
           
        }
    }//body
}

struct TableBoxItemHorizontal: PageView {
   
    var data: TableBox.Data
    let headerSize:CGFloat
    let bodySize:CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing:1) {
            Text(data.title)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.tiny : Font.size.thinExtra,
                            color: Color.app.white))
                .frame(width: self.headerSize)
                
            Text(data.text)
                .kerning(Font.kern.thin)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.tiny : Font.size.thinExtra,
                            color: Color.app.greyDeep))
                .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.tiny :  Dimen.margin.thin)
                .frame(width: self.bodySize, alignment: .leading)
                .multilineTextAlignment(.leading)
                .background(Color.app.blueDeep)
                
        }
        .background(Color.app.blueLight)
        .onAppear(){
           
        }
    }//body
}

struct TableBoxItemVertical: PageView {
   
    var data: TableBox.Data
    
    var body: some View {
        VStack(alignment: .leading, spacing:0) {
            Spacer().modifier(MatchHorizontal(height: 0))
            Text(data.title)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.tiny : Font.size.thinExtra,
                            color: Color.app.white))
                .multilineTextAlignment(.leading)
                
            Text(data.text)
                .kerning(Font.kern.thin)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.tiny : Font.size.thinExtra,
                            color: Color.app.greyDeep))
                .multilineTextAlignment(.leading)
                .padding(.top, Dimen.margin.microExtra)
        }
        .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.tiny :  Dimen.margin.thin)
        .background(Color.app.blueDeep)
        .onAppear(){
           
        }
    }//body
}

#if DEBUG
struct TableBox_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            TableBox(
                datas: [
                    TableBox.Data(title: String.pageText.privacyAndAgreeTitle1, text: String.pageText.privacyAndAgreeText1),
                    TableBox.Data(title: String.pageText.privacyAndAgreeTitle2, text: String.pageText.privacyAndAgreeText2),
                    TableBox.Data(title: String.pageText.privacyAndAgreeTitle3, text: String.pageText.privacyAndAgreeText3)
                
                ]
            )
        }
        .frame(width: 320)
        .background(Color.brand.bg)
        .environmentObject(PagePresenter())
    }
}
#endif
