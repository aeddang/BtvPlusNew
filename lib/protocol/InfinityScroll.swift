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
    @Published var uiEvent:InfinityScrollUIEvent? = nil
    {
        didSet{
            self.uiEvent = nil
        }
    }
    @Published var event:InfinityScrollEvent? = nil
    @Published var itemEvent:InfinityScrollItemEvent? = nil
    @Published private(set) var isCompleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var page = 0
    @Published private(set) var total = 0
    @Published fileprivate(set) var pullCount = 0
    @Published fileprivate(set) var pullPosition:CGFloat = 0
    static let PULL_MAX = 7
    private var increasePull:AnyCancellable? = nil
    private let pullMax:Int
    init(pullMax:Int? = nil) {
        self.pullMax = pullMax ?? Self.PULL_MAX
    }
    
    deinit {
        self.cancelPull()
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
        DataLog.d("onPull" , tag:self.tag)
        self.increasePull?.cancel()
        self.increasePull = Timer.publish(
            every: 0.05, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.pullCount += 1
               // DataLog.d("onPull" + self.pullCount.description , tag:self.tag)
                if self.pullCount >= self.pullMax {
                    self.onPullCompleted()
                }
            }
    }
    func onPullCancel(){
        if self.event != .pull && self.event != .pullCompleted  { return }
        self.event = .pullCancel
        self.pullPosition = 0
        self.cancelPull()
    }
    private func onPullCompleted(){
        self.event = .pullCompleted
        //DataLog.d("onPullCompleted" + self.pullCount.description , tag:self.tag)
        self.cancelPull()
    }
    private func cancelPull(){
        self.increasePull?.cancel()
        self.increasePull = nil
        self.pullCount = 0
    }
}
enum InfinityScrollUIEvent {
    case reload
}
enum InfinityScrollEvent {
    case up, down, bottom, top, pull, pullCompleted, pullCancel
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
    func onMove(pos:CGFloat)
    func onBottom()
    func onTop()
    func onUp()
    func onDown()
    func onPull(pos:CGFloat)
}
extension InfinityScrollViewProtocol {
   
    
    func onMove(pos:CGFloat){
        //ComponentLog.d("onMove  " + pos.description , tag: "InfinityScrollViewProtocol")
        let diff = self.prevPosition - pos
        
        if pos >= 30 {
            onPull(pos:pos)
            return
        }
        if pos >= 1 && pos < 5 {
            self.viewModel.onPullCancel()
            onTop()
            return
        }
        
        if diff < 0 {
            if pos >= 0 {
                return
            }
            self.onUp()
        }
        else if  diff > 0 {
            if pos >= 0 {
                return
            }
            self.onDown()
        }
    }
    
    func onBottom(){
        if self.viewModel.event == .bottom { return }
        self.viewModel.event = .bottom
        //ComponentLog.d("onBottom", tag: "InfinityScrollViewProtocol")
    }
    
    func onTop(){
        if self.viewModel.event == .top { return }
        self.viewModel.event = .top
       // ComponentLog.d("onTop", tag: "InfinityScrollViewProtocol")
    }
    
    func onUp(){
        if self.viewModel.event == .up { return }
        self.viewModel.event = .up
        //ComponentLog.d("onUp", tag: "InfinityScrollViewProtocol")
    }
    
    func onDown(){
        if self.viewModel.event == .down { return }
        self.viewModel.event = .down
        //ComponentLog.d("onDown", tag: "InfinityScrollViewProtocol")
    }
    
    func onPull(pos:CGFloat){
        self.viewModel.onPull(pos: pos)
    }
    
   
}


protocol InfinityListViewProtocol :PageProtocol{
    var viewModel:InfinityScrollModel {get set}
    var allDatas:[InfinityData] {get}
    var appearDatas:[InfinityData] {get set}
    var prevIndex:Int {get set}
    var initScrollMove:Bool {get set}
    func onItemAppear()->Int
    func onBottom()
    func onTop()
    func onUp()
    func onDown()
}
extension InfinityListViewProtocol {
    func onItemAppear()->Int{
        if allDatas.count <= 3 { return 0 }
        if !initScrollMove { return 0 }
        let sorted = appearDatas.sorted { $0.index < $1.index}
        guard let first = sorted.first else { return 0 }
        //ComponentLog.d("index " + sorted.reduce("", {$0 + "\n" + $1.index.description}), tag: self.tag)
        if prevIndex != first.index {
            if first == allDatas.first {
                self.onTop()
                return first.index
            }
            if sorted.last == allDatas.last {
                self.onBottom()
                return first.index
            }
        }
        
       // ComponentLog.d("index " + first.index.description, tag: self.tag)
        //if abs(prevIndex - first.index) > 1 { return first.index }
        if prevIndex > first.index { self.onUp() }
        else if prevIndex < first.index { self.onDown() }
        return first.index
    }
    
    func onBottom(){
        self.viewModel.event = .bottom
        ComponentLog.d("onBottom", tag: self.tag)
    }
    
    func onTop(){
        self.viewModel.event = .top
        self.viewModel.event = .pullCompleted
        ComponentLog.d("onTop", tag: self.tag)
    }
    
    func onUp(){
        if self.viewModel.event == .up { return }
        self.viewModel.event = .up
        ComponentLog.d("onUp", tag: self.tag)
    }
    
    func onDown(){
        if self.viewModel.event == .down { return }
        self.viewModel.event = .down
        ComponentLog.d("onDown", tag: self.tag)
    }
}


