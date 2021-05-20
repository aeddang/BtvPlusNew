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
enum SceneRadio:Equatable {
    case sort((String,[String]))
    
    func check(key:String)-> Bool{
           switch (self) {
              case let .sort(v):
               return v.0 == key
           }
       }
    static func ==(lhs: SceneRadio, rhs: SceneRadio) -> Bool {
        switch (lhs, rhs) {
           case (let .sort(lh), let .sort(rh)):
            return lh.0 == rh.0
        }
    }
}
enum SceneRadioResult {
    case complete(SceneRadio,Int)
}


struct SceneRadioController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    
    @State var isShow = false
    @State var buttons:[RadioBtnData] = []
    @State var currentRadio:SceneRadio? = nil
    
   
    var body: some View {
        Form{
            Spacer()
        }
        .radio(
            isShowing: self.$isShow,
            buttons: self.$buttons)
            { idx in
                switch self.currentRadio {
                    case .sort(let data) : self.selectedSort(idx ,data:data)
                    default: do { return }
                }
                withAnimation{
                    self.isShow = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
            }
        
        .onReceive(self.sceneObserver.$radio){ radio in
            self.currentRadio = radio
            switch radio{
                case .sort(let data) : self.setupSort(data:data)
                default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
        
    }//body
    
    func reset(){
        self.buttons = []
        self.currentRadio = nil
    }
    

    func setupSort(data:(String,[String])) {
        let range = 0 ..< data.1.count
        self.buttons = zip(range,data.1).map {index, text in
            RadioBtnData(title: text, index: index)
        }
    }
    func selectedSort(_ idx:Int, data:(String,[String])) {
        self.sceneObserver.radioResult = .complete(.sort(data), idx)
    }
    
   
}


