//
//  InputAccssory.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/17.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import UIKit
import SwiftUI

struct InputAccessory: UIViewRepresentable  {
    
    func makeUIView(context: Context) -> UITextField {

        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        customView.backgroundColor = UIColor.red
        let sampleTextField =  UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        sampleTextField.inputAccessoryView = customView
        sampleTextField.placeholder = "placeholder"

        return sampleTextField
    }
    func updateUIView(_ uiView: UITextField, context: Context) {
    }
}

#if DEBUG
struct InputAccessory_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputAccessory()
        }
    }
}
#endif
