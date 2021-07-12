//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage


struct ExamBody: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @ObservedObject var viewModel:KidsExamModel = KidsExamModel()
    var type:DiagnosticReportType = .english
    var isView:Bool = false
    var body: some View {
        ZStack{
            HStack( spacing: DimenKids.margin.light){
                ZStack(alignment: .bottom){
                    KFImage(URL(string: self.image ?? ""))
                        .resizable()
                        .cancelOnDisappear(true)
                        .loadImmediately()
                        .aspectRatio(contentMode: .fit)
                        .modifier(MatchParent())
                        .padding(.bottom, SystemEnvironment.isTablet ? 106 : 48)
                    if isView {
                        ProgressBox(viewModel: self.viewModel){ move in
                            self.viewModel.move(move)
                        }
                    } else {
                        ProgressBox(viewModel: self.viewModel)
                    }
                }
                .padding(.bottom, self.sceneObserver.safeAreaBottom + DimenKids.margin.thin)
                ExamControl(
                    viewModel: self.viewModel,
                    isView: self.isView
                )
            }
            .modifier(ContentHorizontalEdgesKids())
            
        }
        
        .onReceive(self.viewModel.$event){evt in
            switch evt {
            case .quest(_ , let question ) :
                withAnimation{
                    self.image = question.imagePath
                }
            default : break
            }
        }
    }
    @State var image:String? = nil
   
}

#if DEBUG
struct ExamBody_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Form{
                ExamBody(
                  
                )
                .background(Color.app.grey)
            }
            .previewLayout(.device)
            Form{
                ExamBody(
                    
                )
                .frame(width: 620, height: 400)
                .background(Color.app.grey)
            }
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
        }
    }
}
#endif