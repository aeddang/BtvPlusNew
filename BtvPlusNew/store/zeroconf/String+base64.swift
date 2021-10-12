//
//  String+base64.swift
//  BtvPlusNew
//
//  Created by Hyun-pil Yang on 2021/10/12.
//

import Foundation

extension String {

    func fromBase64String() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64String() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
