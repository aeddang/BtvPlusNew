//
//  FocusableTextField.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FocusableTextField: UIViewRepresentable {
    @Binding var text:String
    var keyboardType: UIKeyboardType = .default
    var returnVal: UIReturnKeyType = .default
    var placeholder: String = ""
    var placeholderColor:Color = Color.app.blackLight
    var textAlignment:NSTextAlignment = .center
    var maxLength: Int = -1
    var kern: CGFloat = 1
    var textModifier:TextModifier = RegularTextStyle().textModifier
    var isfocus:Bool
    var isSecureTextEntry:Bool = false
    var inputChange: ((_ text:String) -> Void)? = nil
    var inputChanged: ((_ text:String) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        let font =  UIFont(name: self.textModifier.family, size: self.textModifier.size)
        textField.text = self.text
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = self.returnVal
        textField.delegate = context.coordinator
        textField.placeholder = self.placeholder
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = self.textAlignment
        let color = textModifier.color == Color.app.white ? UIColor.white : textModifier.color.uiColor()
        textField.textColor = color
        textField.isSecureTextEntry = self.isSecureTextEntry
        textField.defaultTextAttributes.updateValue(self.kern, forKey: .kern)
        textField.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ,
            attributes: [
                NSAttributedString.Key.kern: self.kern,
                NSAttributedString.Key.font: font ?? UIFont.init(),
                NSAttributedString.Key.foregroundColor: placeholderColor.uiColor()
            ])
        textField.font = font
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if self.isfocus {
            if !uiView.isFocused {
                uiView.becomeFirstResponder()
            }
        } else {
            if uiView.isFocused {
                uiView.resignFirstResponder()
            }
        }
        if uiView.text != self.text { uiView.text = self.text }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self,inputChanged:inputChanged, inputCopmpleted:inputCopmpleted)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
        var inputChanged: ((_ text:String) -> Void)? = nil
        var inputCopmpleted: ((_ text:String) -> Void)? = nil
        init(_ textField: FocusableTextField, inputChanged: ((_ text:String) -> Void)?, inputCopmpleted:((_ text:String) -> Void)?) {
            self.parent = textField
            self.inputChanged = inputChanged
            self.inputCopmpleted = inputCopmpleted
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if parent.maxLength != -1 {
                    if updatedText.count > parent.maxLength {return false}
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
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let  inputCopmpleted = self.inputCopmpleted else { return true }
            inputCopmpleted(textField.text ?? "")
            //textField.text = ""
            return false
        
        }

    }
}


