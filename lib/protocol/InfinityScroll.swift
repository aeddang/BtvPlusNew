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
enum InfinityScrollType :Equatable{
    case reload(isDragEnd:Bool? = nil),
         vertical(isDragEnd:Bool? = nil),
         horizontal(isDragEnd:Bool? = nil),
         web(isDragEnd:Bool? = nil)
    
    static func ==(lhs: InfinityScrollType, rhs: InfinityScrollType) -> Bool {
        switch (lhs, rhs) {
        case ( .reload, .reload):return true
        case ( .vertical, .vertical):return true
        case ( .horizontal, .horizontal):return true
        case ( .web, .web):return true
        default: return false
        }
    }
}

class InfinityScrollModel:ComponentObservable, Identifiable{

    static let PULL_RANGE:CGFloat = 40
    static let PULL_COMPLETED_RANGE:CGFloat = 40
    static let DRAG_RANGE:CGFloat = 70
    static let DRAG_COMPLETED_RANGE:CGFloat = 60
    
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
    fileprivate(set) var prevPosition:CGFloat = 0
    fileprivate(set) var minDiff:CGFloat = 0
    
    
    var initIndex:Int? = nil
    var initPos:Float? = nil
    let idstr:String = UUID().uuidString
    var size = 20
    var isLoadable:Bool {
        get {
            return !self.isLoading && !self.isCompleted
        }
    }
    
    fileprivate(set) var isScrollEnd:Bool = false
    private(set) var isDragEnd:Bool = false
    private(set) var pullRange:CGFloat = 40
    private(set) var pullCompletedRange:CGFloat = 50
    private(set) var updateScrollDiff:CGFloat = 1.0
    private(set) var updatePullDiff:CGFloat = 0.3
    private(set) var cancelPullDiff:CGFloat = 5
    private(set) var completePullDiff:CGFloat = 15
    private(set) var cancelPullRange:CGFloat = 40
    private(set) var topRange:CGFloat = 80
    
    func setup(type: InfinityScrollType){
        switch type {
        case .horizontal (let end):
            pullRange = 40
            pullCompletedRange = 50
            //updateScrollDiff = 1.0
            updatePullDiff = 0.3
            cancelPullDiff = 5
            completePullDiff = 40
            cancelPullRange = pullRange
            isDragEnd = end ?? false
        case .vertical (let end):
            pullRange = InfinityScrollModel.DRAG_RANGE
            pullCompletedRange = InfinityScrollModel.DRAG_COMPLETED_RANGE
            //updateScrollDiff = 0.3
            updatePullDiff = 0.3
            cancelPullDiff = 10
            completePullDiff = 50
            cancelPullRange = pullRange
            isDragEnd = end ?? false
        case .reload (let end):
            pullRange = InfinityScrollModel.PULL_RANGE
            pullCompletedRange = InfinityScrollModel.PULL_COMPLETED_RANGE
            //updateScrollDiff = 0.3
            updatePullDiff = 0.3
            cancelPullDiff = 10
            completePullDiff = 1000
            cancelPullRange = pullRange
            isDragEnd = end ?? false
        case .web (let end):
            pullRange = 0
            pullCompletedRange = InfinityScrollModel.DRAG_RANGE + InfinityScrollModel.DRAG_COMPLETED_RANGE
            //updateScrollDiff = 0.3
            updatePullDiff = 0.3
            cancelPullDiff = 10
            completePullDiff = 1000
            cancelPullRange = 30
            isDragEnd = end ?? true
        }
    }
    
    func reload(){
        self.isCompleted = false
        self.page = 0
        self.total = 0
        self.isLoading = false
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
        if self.scrollStatus == .pullCancel { return }
        self.pullPosition = pos
        self.event = .pull
    }
    
    func onPullCancel(){
        if self.scrollStatus == .scroll { return }
        self.event = .pullCancel
        self.pullPosition = 0
        self.isScrollEnd = false
    }
    
    func onPullCompleted(){
        self.event = .pullCompleted
        self.isScrollEnd = self.isDragEnd
    }
    
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
    func onReady()
    func onMove(pos:CGFloat)
    func onBottom()
    func onTop()
    func onUp()
    func onDown()
    func onPull(pos:CGFloat)
    func onPullCompleted()
    func onPullCancel()
}
extension InfinityScrollViewProtocol {
    func onReady(){
        if let idx = self.viewModel.initIndex {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.uiEvent = .scrollTo(idx)
            }
        }
        if let pos = self.viewModel.initPos {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.uiEvent = .scrollMove(pos)
            }
        }
        self.viewModel.event = .ready
    }
    func onMove(pos:CGFloat){
        if self.viewModel.isScrollEnd {
            return
        }
        let diff = self.viewModel.prevPosition - pos
        //ComponentLog.d("pos " + pos.description, tag: "InfinityScrollViewProtocol")
        if abs(diff) > 600 { return }
        if abs(diff) > self.viewModel.minDiff{
            self.viewModel.scrollPosition = pos
            self.viewModel.prevPosition = ceil(pos)
        }
        if diff > 30 { return }
        
        if pos >= self.viewModel.pullRange && self.viewModel.scrollStatus != .pullCancel {
            self.viewModel.scrollStatus = .pull
            self.viewModel.minDiff = self.viewModel.updatePullDiff
            
            
            if diff < -self.viewModel.completePullDiff {
                ComponentLog.d("onPullCompleted pull range", tag: "InfinityScrollViewProtocol")
                self.onPullCompleted()
                return
            }
            if diff > self.viewModel.cancelPullDiff {
                if (pos + diff + 1) >= (self.viewModel.pullCompletedRange + self.viewModel.pullRange){
                    ComponentLog.d("onPullCompleted pull", tag: "InfinityScrollViewProtocol")
                    self.viewModel.isScrollEnd = self.viewModel.isDragEnd
                    self.onPullCompleted()
                } else {
                    ComponentLog.d("onPullCancel pull " + self.viewModel.isScrollEnd.description , tag: "InfinityScrollViewProtocol")
                    self.onPullCancel()
                }
                self.viewModel.prevPosition = ceil(pos)
                return
            }
            if abs(diff) > self.viewModel.minDiff { self.onPull(pos: pos) }
            if pos == 0 && diff > 0 {
                ComponentLog.d("onPullCancel pos", tag: "InfinityScrollViewProtocol")
                self.onPullCancel()
                self.viewModel.prevPosition = ceil(pos)
            }
            return
        }
        
        
        if pos >= -self.viewModel.topRange && pos < self.viewModel.cancelPullRange {
            if self.viewModel.scrollStatus == .pull {
                ComponentLog.d("onPullCancel scroll", tag: "InfinityScrollViewProtocol")
                self.onPullCancel()
                self.viewModel.prevPosition = ceil(pos)
            }
            self.viewModel.minDiff = self.viewModel.updateScrollDiff
            onTop()
        } else {
            if diff < 0 {
                self.onUp()
            }
            else if diff > 0 {
                self.onDown()
            }
        }
        self.viewModel.scrollStatus = .scroll
    }
    
    func onPull(pos:CGFloat){
        self.viewModel.onPull(pos: pos)
    }
    func onPullCompleted(){
        self.viewModel.onPullCompleted()
        self.viewModel.scrollStatus = .pullCancel
    }
    func onPullCancel(){
        self.viewModel.onPullCancel()
        self.viewModel.scrollStatus = .pullCancel
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
    
    
    
    
}


