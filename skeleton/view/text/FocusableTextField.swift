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
    var keyboardType: UIKeyboardType = .default
    var returnVal: UIReturnKeyType = .default
    var placeholder: String = ""
    @Binding var isfocusAble:Bool
    var inputChanged: ((_ text:String) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = self.returnVal
        textField.delegate = context.coordinator
        textField.placeholder = self.placeholder
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if self.isfocusAble {
            uiView.becomeFirstResponder()
            
        } else {
            uiView.resignFirstResponder()
        }
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

                guard let  inputChanged = self.inputChanged else { return true}
                inputChanged(updatedText)
            }

            return true
        }
        
        func updatefocus(textfield: UITextField) {
            textfield.becomeFirstResponder()
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let  inputCopmpleted = self.inputCopmpleted else { return true }
            inputCopmpleted(textField.text ?? "")
            textField.text = ""
            return false
        
        }

    }
}


