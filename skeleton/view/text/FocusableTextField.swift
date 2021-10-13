//
//  FocusableTextField.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FocusableTextField: UIViewRepresentable{
    @Binding var text:String
    var keyboardType: UIKeyboardType = .default
    var returnVal: UIReturnKeyType = .default
    var placeholder: String = ""
    var placeholderColor:Color = Color.app.blackLight
    var textAlignment:NSTextAlignment = .center
    var maxLength: Int = -1
    var kern: CGFloat = 1
    var kernHolder: CGFloat? = nil
    var textModifier:TextModifier = RegularTextStyle().textModifier
    var isfocus:Bool
    var isDynamicFocus:Bool = false
    var isSecureTextEntry:Bool = false
    var focusIn: (() -> Void)? = nil
    var focusOut: (() -> Void)? = nil
    var inputChange: ((_ text:String) -> Void)? = nil
    var inputChangedNext: ((_ char:String) -> Void)? = nil
    var inputChanged: ((_ text:String) -> Void)? = nil
    var inputClear: (() -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    @State var isFinalFocus:Bool? = nil
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        let font =  UIFont(name: self.textModifier.family, size: self.textModifier.size)
        textField.text = self.text
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = self.returnVal
        textField.delegate = context.coordinator
        textField.placeholder = self.placeholder
        textField.autocorrectionType = .no
        //textField.clearButtonMode = .whileEditing
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = self.textAlignment
        let color = textModifier.color == Color.app.white ? UIColor.white : textModifier.color.uiColor()
        textField.textColor = color
        textField.isSecureTextEntry = self.isSecureTextEntry
        textField.autoresizingMask = .flexibleWidth
        textField.defaultTextAttributes.updateValue(self.kern, forKey: .kern)
        textField.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ,
            attributes: [
                NSAttributedString.Key.kern: self.kernHolder ?? self.kern,
                NSAttributedString.Key.font: font ?? UIFont.init(),
                NSAttributedString.Key.foregroundColor: placeholderColor.uiColor()
            ])
        textField.font = font
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != self.text { uiView.text = self.text }
        
        if self.isfocus == self.isFinalFocus {
            if #available(iOS 15.0, *) {
                if self.isfocus && self.isDynamicFocus {
                    if !uiView.isFocused {
                        DispatchQueue.main.async {
                            uiView.becomeFirstResponder()
                        }
                    }
                }
            }
            return
        }
        if self.isfocus {
            ComponentLog.d("on focus " + uiView.isFocused.description, tag:"FocusableTextField")
            if !uiView.isFocused {
                ComponentLog.d("uiView.becomeFirstResponder " + uiView.isFocused.description, tag:"FocusableTextField")
                uiView.becomeFirstResponder()
                self.focusIn?()
            }
        }else if !self.isfocus {
            ComponentLog.d("dis focus " + uiView.isFocused.description, tag:"FocusableTextField")
            if uiView.isFocused {
                ComponentLog.d("uiView.resignFirstResponder " + uiView.isFocused.description, tag:"FocusableTextField")
                uiView.resignFirstResponder()
                self.focusOut?()
            }
        }
        
        DispatchQueue.main.async {
            self.isFinalFocus = self.isfocus
        }
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
      
        init(_ textField: FocusableTextField) {
            self.parent = textField
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if parent.maxLength != -1 {
                    if updatedText.count > parent.maxLength {
                        self.parent.inputChangedNext?(string)
                        return false
                    }
                }
                parent.inputChange?(updatedText)
            }
            return true
        }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            let text = textField.text ?? ""
            DispatchQueue.main.async {
                if self.parent.text != text {
                    self.parent.text = text
                    self.parent.inputChanged?(text)
                }
            }
        }
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            guard let  inputClear = self.parent.inputClear else { return true }
            if textField.text?.isEmpty == true {
                inputClear()
            }
            //textField.text = ""
            return false
        
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let  inputCopmpleted = self.parent.inputCopmpleted else { return true }
            inputCopmpleted(textField.text ?? "")
            //textField.text = ""
            return false
        
        }

    }
}


