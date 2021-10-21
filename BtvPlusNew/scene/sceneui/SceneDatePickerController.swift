//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct SceneDatePickerController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    
    @State var isShow = false
    
   
    @State var currentDate:Date = Date()
    @State var currentSelect:SceneSelect? = nil 
    @State var dateClose:Int = 0
        
    var body: some View {
        Form{
            Spacer()
        }
        .datePicker(
            isShowing: self.$isShow,
            selected: self.$currentDate,
            dateClose: self.dateClose
        ){ date in
            switch self.currentSelect {
            case .datePicker(_ , _, let handler) :
                if let handler = handler {
                    handler(date)
                }
            default: return
            }
            withAnimation{
                self.isShow = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        }
        .onReceive(self.sceneObserver.$select){ select in
            switch select{
            case .datePicker(let setup, let date, _) :
                self.currentSelect = select
                self.currentDate = date
                self.dateClose = setup.1
                
            default: return
            }
            withAnimation{
                self.isShow = true
            }
        }
        .accessibility(hidden: !self.isShow )
    }//body
    
    func reset(){
        self.currentSelect = nil
    }

}


