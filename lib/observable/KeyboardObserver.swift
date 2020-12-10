//
//  KeyboardObserver.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import SwiftUI
import Combine

enum KeyboardObserverEvent {
    case cancel
}
class KeyboardObserver: ObservableObject {
    
    
    private var cancellable: AnyCancellable?
    @Published var event: KeyboardObserverEvent? = nil
    {
        didSet{
            if self.event == nil { return }
            self.event = nil
        }
    }

    @Published private(set) var keyboardHeight: CGFloat = 0
    {
        didSet(oldVal){
            if oldVal == keyboardHeight { return }
            self.delayKeyBoardEvent()
        }
    }

    @Published private(set) var isOn:Bool = false
    
    private var keyboardSubscription:AnyCancellable?
    func delayKeyBoardEvent() {
        self.keyboardSubscription?.cancel()
        self.keyboardSubscription = Timer.publish(
            every: 0.005, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.keyboardSubscription?.cancel()
                self.keyboardSubscription = nil
                if self.keyboardHeight == 0 && self.isOn  {
                    self.isOn = false
                }
                else if !self.isOn {
                    self.isOn = true
                    
                }
                
                
        }
    }

      private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }

      private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ -> CGFloat in 0 }

    
      func start(){
        if cancellable != nil { return }
           cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
                   .subscribe(on: RunLoop.main)
                   .assign(to: \.keyboardHeight, on: self)
      }
        
      func cancel(){
          keyboardSubscription?.cancel()
          keyboardSubscription = nil
          cancellable?.cancel()
          cancellable = nil
          keyboardHeight = 0
      }
        
      deinit {
         cancel()
      }
}
