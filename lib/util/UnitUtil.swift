//
//  UnitConverter.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import SwiftUI
import UIKit

extension Double {
    func toInt() -> Int {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return 0
        }
    }
    
    func secToMinString(_ div:String = ":") -> String {
        let sec = self.toInt() % 60
        let min = floor( Double(self / 60) ).toInt()
        return min.description + div + sec.description
    }
    
    func millisecToSec() -> Double {
        return self/1000.0
    }
}

extension String{
    func getArrayAfterRegex(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            DataLog.d("invalid regex: \(error.localizedDescription)", tag: "getArrayAfterRegex")
            return []
        }
    }
    
    func textHeightFrom(width: CGFloat,fontSize: CGFloat,  fontName: String = "System Font") -> CGFloat {

        #if os(macOS)
        typealias UXFont = NSFont
        let text: NSTextField = .init(string: self)
        text.font = NSFont.init(name: fontName, size: fontSize)

        #else
        typealias UXFont = UIFont
        let text: UILabel = .init()
        text.text = self
        text.numberOfLines = 0

        #endif
        text.font = UXFont.init(name: fontName, size: fontSize)
        text.lineBreakMode = .byWordWrapping
        return text.sizeThatFits(CGSize.init(width: width, height: .infinity)).height
    }
    
    func textSizeFrom(fontSize: CGFloat,  fontName: String = "System Font") -> CGSize {
        let font = UIFont.init(name: fontName, size: fontSize)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        return size
    }
    
    func underline() -> NSMutableAttributedString {
        let range = NSMakeRange(0,self.count)
        let attributedText = NSMutableAttributedString(string: self)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: range)
        return attributedText
    }
    
    //let isoDate = "2016-04-14T10:44:00+0000"
    func toDate(
        dateFormat:String = "yyyy-MM-dd'T'HH:mm:ssZ",
        local:String="en_US_POSIX"
     ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: local) // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from:self)
        return date
    }
    
    func isEmailType() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func isPasswordType() -> Bool {
        //let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$"
        //let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        //return predicate.evaluate(with: self)
        return self.count >= 6
    }
    
    func isNickNameType() -> Bool {
        let n = self.count
        if n < 2 { return false }
        if n > 10 { return false }
        let ruleEng = "[a-zA-Z]"
        let resultEng = self.getArrayAfterRegex(regex: ruleEng )
        if resultEng.count == n {
            if n < 3 { return false }
        }
        let ruleNum = "[0-9]"
        let resultNum = self.getArrayAfterRegex(regex: ruleNum )
        if resultNum.count == n { return false }
    
        let rule = "[0-9가-힣a-zA-Z]"
        let result = self.getArrayAfterRegex(regex: rule )
        if result.count == n { return true}
        return false
    }
    
    func isPhoneNumberType() -> Bool {
        if self.count < 7 { return false }
        return Int(self) != nil
    }
    
    func toDecimal(divid:Double = 1 ,f:Int = 0) -> String {
        guard let num = Double(self) else { return  "0"}
        let isDecimal = num.truncatingRemainder(dividingBy: divid) == 0 ? "%.0f" : "%."+f.description+"f"
        let n = num / divid
        let s = String(format: isDecimal , n)
        return Double(s)?.calculator ?? "0"
    }
    
    func toDigits(_ n:Int) -> String {
        let num = Int(self) ?? 0
        //DataLog.d("num " + num.description , tag:"toDigits")
        let fm = "%0" + n.description + "d"
        let str = String(format: fm , num)
        //DataLog.d("str " + str , tag:"toDigits")
        return str
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()
}

extension Formatter {
    static let number = NumberFormatter()
}
extension Locale {
    static let englishUS: Locale = .init(identifier: "en_US")
    static let frenchFR: Locale = .init(identifier: "fr_FR")
    static let portugueseBR: Locale = .init(identifier: "pt_BR")
    static let koreaKR: Locale = .init(identifier: "ko")
    // ... and so on
}
extension Numeric {
    func formatted(with groupingSeparator: String? = nil, style: NumberFormatter.Style, locale: Locale = .current) -> String {
        Formatter.number.locale = locale
        Formatter.number.numberStyle = style
        if let groupingSeparator = groupingSeparator {
            Formatter.number.groupingSeparator = groupingSeparator
        }
        return Formatter.number.string(for: self) ?? ""
    }
    // Localized
    var currency:   String { formatted(style: .currency) }
    // Fixed locales
    var currencyUS: String { formatted(style: .currency, locale: .englishUS) }
    var currencyFR: String { formatted(style: .currency, locale: .frenchFR) }
    var currencyBR: String { formatted(style: .currency, locale: .portugueseBR) }
    var currencyKR: String { formatted(style: .currency, locale: .koreaKR) }
    
    var calculator: String { formatted(with:",", style: .decimal) }
}
