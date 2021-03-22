//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ScenePickerController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    
    @State var isShow = false
    @State var selected:Int = 0
    @State var buttons:[SelectBtnData] = []
    @State var currentSelect:SceneSelect? = nil
        
    var body: some View {
        Form{
            Spacer()
        }
        .picker(
            isShowing: self.$isShow,
            title: "",
            buttons: self.buttons,
            selected: self.$selected)
        { idx in
            switch self.currentSelect {
                case .picker(let data, _) : self.selectedPicker(idx ,data:data)
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
            case .picker(let data, let idx): self.setupPicker(data:data, idx:idx)
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
    
    func setupPicker(data:(String,[String]), idx:Int) {
        
        let range = 0 ..< data.1.count
        self.buttons = zip(range, data.1).map {index, text in
            SelectBtnData(title: text, index: index)
        }
        self.selected = idx
    }
    func selectedPicker(_ idx:Int, data:(String,[String])) {
        self.sceneObserver.selectResult = .complete(.picker(data, idx), idx)
        self.sceneObserver.selectResult = nil
    }
    
   
}


