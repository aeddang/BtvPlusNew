//
//  DataProvider.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/05.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class DataProvider : ObservableObject {
    let bands:Bands = Bands()
    
    @Published private(set) var request:ApiQ? = nil
    
    @Published var result:ApiResultResponds? = nil
        {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil
        {didSet{ if error != nil { error = nil} }}
    
    func requestData(q:ApiQ){
        self.request = q
    }
}
