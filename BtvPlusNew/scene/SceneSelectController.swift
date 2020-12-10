//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Foundation
import SwiftUI



enum SceneSelect:Equatable {
    case select((String,[String]))
    
    func check(key:String)-> Bool{
        switch (self) {
           case let .select(v):
            return v.0 == key
        }
    }
    
    static func ==(lhs: SceneSelect, rhs: SceneSelect) -> Bool {
        switch (lhs, rhs) {
           case (let .select(lh), let .select(rh)):
            return lh.0 == rh.0
        }
    }
}
enum SceneSelectResult {
    case complete(SceneSelect,Int)
}


struct SceneSelectController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var buttons:[SelectBtnData] = []
    @State var currentSelect:SceneSelect? = nil
        
    var body: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: self.$isShow,
            title: self.$title,
            buttons: self.$buttons)
        { idx in
            switch self.currentSelect {
                case .select(let data) : self.selectedSelect(idx ,data:data)
                default: do { return }
            }
            withAnimation{
                self.isShow = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        }
        
        .onReceive(self.sceneObserver.$select){ select in
            self.currentSelect = select
            switch select{
                case .select(let data) : self.setupSelect(data:data)
                default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
        
    }//body
    
    func reset(){
        self.buttons = []
        self.currentSelect = nil
    }
    
    
    
    func setupSelect(data:(String,[String])) {
        self.title = data.0
        let range = 0 ..< data.1.count
        self.buttons = zip(range, data.1).map {index, text in
            SelectBtnData(title: text, index: index)
        }
    }
    func selectedSelect(_ idx:Int, data:(String,[String])) {
        self.sceneObserver.selectResult = .complete(.select(data), idx)
        self.sceneObserver.selectResult = nil
    }
    
   
}


