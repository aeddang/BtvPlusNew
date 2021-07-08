//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI



struct ExamBody: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var body: some View {
        HStack( spacing: DimenKids.margin.light){
            VStack(){
                Spacer()
                ProgressBox(
                    progress: 5,
                    max: 10,
                    hold: 2){ move in
                    
                }
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom + DimenKids.margin.thin)
            ExamControl()
        }
        .modifier(ContentHorizontalEdgesKids())
    }
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
