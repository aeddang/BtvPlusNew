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
    @Binding var text:String
    var keyboardType: UIKeyboardType = .default
    var returnVal: UIReturnKeyType = .done
    var placeholder: String = ""
    var isfocus:Bool
    var textModifier:TextModifier = RegularTextStyle().textModifier
    var usefocusAble:Bool = true
    var isSecureTextEntry:Bool = false
    var textAlignment:NSTextAlignment = .left
    var kern: CGFloat? = nil
    var limitedLine: Int = 1
    var limitedSize: Int = -1
    var inputChange: ((_ text:String, _ size:CGSize) -> Void)? = nil
    var inputChanged: ((_ text:String, _ size:CGSize) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    
    @State var attrs:[NSAttributedString.Key : Any]? = nil
    
    func makeUIView(context: Context) -> UITextView {
        /*
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        */
        if let kern = self.kern {
            self.attrs
                = [.kern: kern, .font: UIFont(name: textModifier.family, size: textModifier.size) as Any]
        }
        let textView = UITextView(frame: .zero)
        textView.textColor = textModifier.color.uiColor()
        //
        textView.keyboardType = self.keyboardType
        textView.returnKeyType = self.returnVal
        textView.delegate = context.coordinator
        textView.autocorrectionType = .yes
        textView.textAlignment = self.textAlignment
        textView.sizeToFit()
        
        textView.textContentType = .oneTimeCode
        textView.isSecureTextEntry = self.isSecureTextEntry
        textView.backgroundColor = UIColor.clear
        if limitedLine != -1 {
            textView.textContainer.maximumNumberOfLines = self.limitedLine
        }
        
        if let attrs = self.attrs {
            textView.attributedText = NSAttributedString(string: self.text, attributes: attrs)
        } else {
            textView.font = UIFont(name: textModifier.family, size: textModifier.size)
            textView.text = self.text
        }
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text { uiView.text = self.text }
        if !self.usefocusAble {return}
        if self.isfocus {
            if !uiView.isFocused {
                uiView.becomeFirstResponder()
            }
            
        } else {
            if uiView.isFocused {
                uiView.resignFirstResponder()
            }
        }
        if uiView.text != self.text {
            if let attrs = self.attrs {
                uiView.attributedText = NSAttributedString(string: self.text, attributes: attrs)
            } else {
                uiView.text = self.text
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: FocusableTextView
        init(_ parent: FocusableTextView) {
            self.parent = parent
        }
       
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if self.parent.limitedLine == 1 && text == "\n" {
                guard let  inputCopmpleted = self.parent.inputCopmpleted else { return true }
                inputCopmpleted(textView.text)
                return false
            }
            if let currentText = textView.text,
                let textRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: textRange, with: text)
                if self.parent.limitedSize != -1 {
                    if updatedText.count > self.parent.limitedSize { return false }
                }
                self.parent.inputChange?(updatedText, textView.contentSize)
            }
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            //self.parent.text = textView.text
            self.parent.inputChanged?(textView.text , textView.contentSize)
        }
       
    
        func updatefocus(textView: UITextView) {
            textView.becomeFirstResponder()
        }
       

        func textViewShouldReturn(_ textView: UITextView) -> Bool {
            guard let  inputCopmpleted = self.parent.inputCopmpleted else { return true }
            inputCopmpleted(textView.text)
            return false
        
        }

    }
}


