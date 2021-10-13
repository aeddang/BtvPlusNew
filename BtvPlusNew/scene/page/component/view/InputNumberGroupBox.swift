//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct InputNumberGroupBox: PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    var isInit:Bool = false
    @Binding var focusIdx:Int
    var inputSize:Int = 4
    var completed: (() -> Void)? = nil
    var action: ((_ input:String?) -> Void)
    
   
    let inputGroupSize:Int = 4
    @State var input1:String = ""
    @State var input2:String = ""
    @State var input3:String = ""
    @State var input4:String = ""
    
    var body: some View {
        HStack(spacing:Dimen.margin.lightExtra){
            InputNumberGroupItem(
                idx: 0,
                input: self.$input1,
                focusIdx: self.focusIdx,
                prev: {
                    
                },
                next:{ char in
                    self.input2 = char
                    DispatchQueue.main.async {
                        self.focusIdx = 1
                    }
                })
            .onTapGesture {
                self.focusIdx = 0
                self.onChanged()
            }
            InputNumberGroupItem(
                idx: 1,
                input: self.$input2,
                focusIdx: self.focusIdx,
                prev: {
                    DispatchQueue.main.async {
                        self.focusIdx = 0
                    }
                },
                next:{ char in
                    self.input3 = char
                    DispatchQueue.main.async {
                        self.focusIdx = 2
                    }
                })
            .onTapGesture {
                self.focusIdx = 1
                self.onChanged()
            }
            InputNumberGroupItem(
                idx: 2,
                input: self.$input3,
                focusIdx: self.focusIdx,
                prev: {
                    DispatchQueue.main.async {
                        self.focusIdx = 1
                    }
                },
                next:{ char in
                    self.input4 = char
                    DispatchQueue.main.async {
                        self.focusIdx = 3
                    }
                })
            .onTapGesture {
                self.focusIdx = 2
                self.onChanged()
            }
            InputNumberGroupItem(
                idx: 3,
                input: self.$input4,
                focusIdx: self.focusIdx,
                prev: {
                    DispatchQueue.main.async {
                        self.focusIdx = 2
                    }
                },
                action: {
                    self.focusIdx = self.findFocus()
                    self.onChanged()
                    if self.focusIdx == -1 {
                        if let com = self.completed {
                            com()
                        } else {
                            AppUtil.hideKeyboard()
                        }
                    
                    }
                })
            .onTapGesture {
                self.focusIdx = 3
            }
        }
        .modifier(MatchHorizontal(height: Dimen.tab.regular))
       
    }//body
    
    private func findFocus() -> Int {
        if self.input1.isEmpty {return 0}
        if self.input2.isEmpty {return 1}
        if self.input3.isEmpty {return 2}
        if self.input4.isEmpty {return 3}
        return -1
    }
    
    private func onChanged() {
        self.action(input1+input2+input3+input4)
    }
    
}

struct InputNumberGroupItem: PageView {
    let idx:Int
    @Binding var input:String
    var focusIdx:Int
    var placeholder:String = ""
    var maxLength:Int  = 4
    var isSecure:Bool = false
    var prev: (() -> Void)? = nil
    var next: ((String) -> Void)? = nil
    var action: (() -> Void)? = nil
    
    let radius:CGFloat = DimenKids.radius.lightExtra
    var body: some View {
        ZStack{
            FocusableTextField(
                text: self.$input,
                keyboardType: .numberPad,
                placeholder: self.placeholder,
                textAlignment: .left,
                maxLength:self.maxLength,
                isfocus: self.focusIdx == self.idx,
                isDynamicFocus: true,
                isSecureTextEntry:self.isSecure,
                inputChangedNext :{ char  in
                    self.next?(char)
                },
                inputChanged : { _ in
                    if self.input.isEmpty {
                        self.prev?()
                        return
                    }
                    if self.input.count == 4 {
                        self.action?()
                    }
                })
        }
        .padding(.horizontal, Dimen.margin.thin)
        .modifier(MatchParent())
        .background(Color.app.blueLight)
        .overlay(
            Rectangle()
                .stroke(
                    Color.app.white,
                    lineWidth: self.focusIdx == self.idx
                        ? Dimen.stroke.regular
                        : 0
                    )
        )
    }
}
            

#if DEBUG
struct InputNumberGroupBox_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InputNumberGroupBox(
                focusIdx: .constant(-1)
            ){ input in
                
            }
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif
