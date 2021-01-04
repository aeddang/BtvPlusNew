//
//  FocusableTextField.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FocusableTextView: UIViewRepresentable {
    var keyboardType: UIKeyboardType = .default
    var returnVal: UIReturnKeyType = .default
    var placeholder: String = ""
    @Binding var text:String
    @Binding var isfocusAble:Bool
    var fontSize:CGFloat = Font.size.regular
    var usefocusAble:Bool = true
    var limitedSize: Int = -1
    var inputChange: ((_ text:String, _ size:CGSize) -> Void)? = nil
    var inputChanged: ((_ text:String, _ size:CGSize) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: self.fontSize)
        textView.keyboardType = self.keyboardType
        textView.returnKeyType = self.returnVal
        textView.delegate = context.coordinator
        textView.autocorrectionType = .yes
        textView.sizeToFit()
        textView.text = self.text
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text { uiView.text = self.text }
        if !self.usefocusAble {return}
        if self.isfocusAble {
            uiView.becomeFirstResponder()
            
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text:self.$text,
                    limitedSize: self.limitedSize,
                    inputChange:inputChange,
                    inputChanged: inputChanged,
                    inputCopmpleted:inputCopmpleted)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text:String
        var limitedSize: Int = -1
        var inputChange: ((_ text:String, _ size:CGSize) -> Void)? = nil
        var inputChanged: ((_ text:String, _ size:CGSize) -> Void)? = nil
        var inputCopmpleted: ((_ text:String) -> Void)? = nil
        init(text:Binding<String>,
             limitedSize:Int,
             inputChange: ((_ text:String, _ size:CGSize) -> Void)?,
             inputChanged: ((_ text:String, _ size:CGSize) -> Void)?,
             inputCopmpleted:((_ text:String) -> Void)?) {
           
            self._text = text
            self.limitedSize = limitedSize
            self.inputChange = inputChange
            self.inputChanged = inputChanged
            self.inputCopmpleted = inputCopmpleted
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let currentText = textView.text,
                let textRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: textRange, with: text)
                if self.limitedSize != -1 {
                    if updatedText.count > self.limitedSize { return false }
                }
                guard let  inputChange = self.inputChange else { return true}
                inputChange(updatedText, textView.contentSize)
            }
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            guard let  inputChanged = self.inputChanged else { return }
            inputChanged(textView.text , textView.contentSize)
        }
       
    
        func updatefocus(textView: UITextView) {
            textView.becomeFirstResponder()
        }

        func textViewShouldReturn(_ textView: UITextView) -> Bool {
            guard let  inputCopmpleted = self.inputCopmpleted else { return true }
            inputCopmpleted(textView.text)
            textView.text = ""
            return false
        
        }

    }
}


