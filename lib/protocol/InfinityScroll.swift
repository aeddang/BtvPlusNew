//
//  InfinityListView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/16.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine



class InfinityScrollModel:ComponentObservable, PageProtocol, Identifiable{
    
    static let PULL_RANGE:CGFloat = 30
    static let PULL_COMPLETED_RANGE:CGFloat = 60
    
    
    @Published var uiEvent:InfinityScrollUIEvent? = nil {
        didSet{if self.uiEvent != nil { self.uiEvent = nil}}
    }
    @Published var event:InfinityScrollEvent? = nil
    @Published var scrollStatus:InfinityScrollStatus = .scroll
    @Published var itemEvent:InfinityScrollItemEvent? = nil
    @Published private(set) var isCompleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var page = 0
    @Published private(set) var total = 0
    @Published fileprivate(set) var pullPosition:CGFloat = 0
    @Published fileprivate(set) var scrollPosition:CGFloat = 0
    var initIndex:Int? = nil
    var initPos:Float? = nil

    let pullRange:CGFloat
    
    let idstr:String = UUID().uuidString
    init(axis:Axis.Set = .vertical) {
        
        self.pullRange = Self.PULL_RANGE
    }
    
    deinit {
    }
    
    var size = 20
    var isLoadable:Bool {
        get {
            return !self.isLoading && !self.isCompleted
        }
    }
    func reload(){
        self.isCompleted = false
        self.page = 0
        self.total = 0
        self.isLoading = false
        //DataLog.d("page reload" + self.page.description, tag:self.tag)
    }
    
    func onLoad(){
        self.isLoading = true
    }
    
    func onComplete(itemCount:Int){
        isCompleted =  size > itemCount
        self.total = self.total + itemCount
        self.page = self.page + 1
        self.isLoading = false
    }
    
    func onError(){
        self.isLoading = false
    }
    
    func onPull(pos:CGFloat){
        self.pullPosition = pos
        if self.event == .pull { return }
        self.event = .pull
    }
    func onPullCancel(){
        if self.event != .pull && self.event != .pullCompleted  { return }
        self.event = .pullCancel
        self.pullPosition = 0
    }
    private func onPullCompleted(){
        self.event = .pullCompleted
    }
    
}
enum InfinityScrollUIEvent {
    case reload, scrollMove(Float, UnitPoint? = nil), scrollTo(Int, UnitPoint? = nil)
}
enum InfinityScrollEvent {
    case up, down, bottom, top, pull, pullCompleted, pullCancel, ready
}
enum InfinityScrollStatus: String{
    case scroll, pull, pullCancel
}
enum InfinityScrollItemEvent {
    case select(InfinityData), delete(InfinityData), declaration(InfinityData)
}

open class InfinityData:Identifiable, Equatable{
    public var id:String = UUID().uuidString
    var contentID:String = ""
    var index:Int = -1
    var deleteAble = false
    var declarationAble = false
    public static func == (l:InfinityData, r:InfinityData)-> Bool {
        return l.id == r.id
    }
}


protocol InfinityScrollViewProtocol :PageProtocol{
    var viewModel:InfinityScrollModel {get set}
    var prevPosition:CGFloat {get set}
    func onReady()
    func onMove(pos:CGFloat)
    func onBottom()
    func onTop()
    func onUp()
    func onDown()
    func onPull(pos:CGFloat)
}
extension InfinityScrollViewProtocol {
    func onReady(){
        if let idx = self.viewModel.initIndex {
            self.viewModel.uiEvent = .scrollTo(idx)
        }
        if let pos = self.viewModel.initPos {
            self.viewModel.uiEvent = .scrollMove(pos)
        }
        self.viewModel.event = .ready
    }
    func onMove(pos:CGFloat){
        //ComponentLog.d("onMove  " + pos.description , tag: "InfinityScrollViewProtocol")
        let diff = self.prevPosition - pos
        if abs(diff) > 1 { self.viewModel.scrollPosition = pos }
        if abs(diff) > 10 { return }
        //ComponentLog.d(" diff  " + diff.description , tag: "InfinityScrollViewProtocol")
        //ComponentLog.d(" scrollStatus  " + self.viewModel.scrollStatus.rawValue , tag: "InfinityScrollViewProtocol")
        if pos >= self.viewModel.pullRange && self.viewModel.scrollStatus != .pullCancel {
            if diff > 5 && self.viewModel.scrollStatus == .pull {
                self.viewModel.onPullCancel()
                self.viewModel.scrollStatus = .pullCancel
                //ComponentLog.d("onPullCancel " + diff.description , tag: "InfinityScrollViewProtocol")
            }
            else {
                self.onPull(pos:pos)
            }
            return
        }
        if pos >= 0 && pos < 5 {
            if self.viewModel.scrollStatus == .pull {
                self.viewModel.onPullCancel()
            }
            self.viewModel.scrollStatus = .scroll
            onTop()
            return
        }
        
        if diff < 0 {
            if pos >= 0 { return }
            self.onUp()
        }
        else if  diff > 0 {
            if pos >= 0 { return }
            self.onDown()
        }
        self.viewModel.scrollStatus = .scroll
    }
    
    func onBottom(){
        if self.viewModel.event == .bottom { return }
        self.viewModel.event = .bottom
        ComponentLog.d("onBottom", tag: "InfinityScrollViewProtocol" + self.viewModel.idstr)
    }
    
    func onTop(){
        if self.viewModel.event == .top { return }
        self.viewModel.event = .top
        ComponentLog.d("onTop", tag: "InfinityScrollViewProtocol" + self.viewModel.idstr)
    }
    
    func onUp(){
        if self.viewModel.event == .up { return }
        self.viewModel.event = .up
        ComponentLog.d("onUp", tag: "InfinityScrollViewProtocol" + self.viewModel.idstr)
    }
    
    func onDown(){
        if self.viewModel.event == .down { return }
        self.viewModel.event = .down
        ComponentLog.d("onDown", tag: "InfinityScrollViewProtocol" + self.viewModel.idstr)
    }
    
    func onPull(pos:CGFloat){
        self.viewModel.onPull(pos: pos)
        self.viewModel.scrollStatus = .pull
    }
    
}


