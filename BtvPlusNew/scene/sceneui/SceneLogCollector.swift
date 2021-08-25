//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct SceneLogCollector: PageComponent {
    @EnvironmentObject var repository:Repository
    @State var isCollection = false
    var body: some View {
        VStack(alignment: .trailing){
            HStack(spacing: Dimen.margin.light){
                Spacer()
                Button(action: {
                    self.isCollection.toggle()
                    LogManager.isMemory = self.isCollection
                }) {
                    ZStack{
                        Circle().background(self.isCollection ? Color.red : Color.gray).opacity(0.5)
                            .frame(width: 50,height: 50)
                        Circle().background(self.isCollection ? Color.red : Color.gray).opacity(1.0)
                            .frame(width: 20,height: 20)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                    .frame(width:50, height:50)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
                
                Button(action: {
                    self.share()
                }) {
                    ZStack{
                        Image( Asset.icon.share)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: 50,height: 50)
                    }
                    .background(self.isCollection ? Color.red : Color.gray).opacity(0.5)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    
                }
            }
            .padding(.top, Dimen.app.top + Dimen.margin.light)
            .padding(.trailing,Dimen.margin.light)
            Spacer()
        }
        .modifier(MatchParent())
        .onAppear(){
            self.isCollection = LogManager.isMemory
        }
    }
   
    func share(){
        self.repository.shareManager.share(
            Shareable(
                pageID: .home,
                text: LogManager.memoryLog
            )
        )
        self.isCollection = false
        LogManager.isMemory = false
    }
    
}


#if DEBUG
struct SceneLogCollector_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneLogCollector()
            .environmentObject(Repository())
            
            .frame(width:340,height:300)
        }
    }
}
#endif
