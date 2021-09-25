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
    
    @State var sets:[SelectBtnDataSet] = []
    @State var currentSelect:SceneSelect? = nil
        
    var body: some View {
        Form{
            Spacer()
        }
        .multiPicker(
            isShowing: self.$isShow,
            title: "",
            sets: self.sets)
        { a, b, c, d in
            switch self.currentSelect {
            case .picker(let data, _, let handler) :
                if let handler = handler {
                    handler(a)
                } else {
                    self.selectedPicker(a ,data:data)
                }
            case .multiPicker(_, _, let handler) :
                if let handler = handler {
                    handler(a, b, c, d)
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
            self.currentSelect = select
            switch select{
            case .picker(let data, let idx, _): self.setupPicker(data:data, idx:idx)
            case .multiPicker(let data, let idxs, _): self.setupPicker(data:data, idxs:idxs)
            default: return
            }
            withAnimation{
                self.isShow = true
            }
        }
        
    }//body
    
    func reset(){
        self.sets = []
        self.currentSelect = nil
    }
    
    func setupPicker(data:(String,[String]), idx:Int) {
        
        let range = 0 ..< data.1.count
        
        let buttons = zip(range, data.1).map {index, text in
            SelectBtnData(title: text, index: index)
        }
        self.sets.append(SelectBtnDataSet(idx:0, selectIdx:idx, title: data.0, datas: buttons))
       
    }
    func setupPicker(data:(String,[[String]]), idxs:[Int]) {
        zip(0 ..< data.1.count, data.1).forEach{index, set in
            let range = 0 ..< set.count
            let buttons = zip(range, set).map {idx, text in
                SelectBtnData(title: text, index: idx)
            }
            self.sets.append(SelectBtnDataSet(idx:index, selectIdx:idxs[index], title: data.0, datas: buttons))
        }
    }
    func selectedPicker(_ idx:Int, data:(String,[String])) {
        self.sceneObserver.selectResult = .complete(.picker(data, idx), idx)
        self.sceneObserver.selectResult = nil
    }
    
   
}


