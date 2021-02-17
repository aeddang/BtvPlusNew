//
//  UnitConverter.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import SwiftUI
import UIKit
import CryptoKit

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
        return min.description.toFixLength(2) + div + sec.description.toFixLength(2)
    }
    func secToHourString(_ div:String = ":") -> String {
        let sec = self.toInt() % 60
        let min = floor( Double(self / 60) ).toInt() % 60
        let hour = floor( Double(self / 3600) ).toInt()
        return hour.description.toFixLength(2) + div + min.description.toFixLength(2) + div + sec.description.toFixLength(2)
    }
    
    func millisecToSec() -> Double {
        return self/1000.0
    }
    
    func toPercent(n:Int = 0) -> String {
        return self.toTruncateDecimal(n:n) + "%"
    }
    
    func toTruncateDecimal (n:Int = 0) -> String {
        return String(format: "%." + n.description + "f", self)
    }
}

extension Date{
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        return localDate
    }
    func currentTimeMillis() -> Double {
        return Double(self.timeIntervalSince1970 * 1000)
    }
    
    func toTimestamp(dateFormat:String = "yyyy-MM-dd'T'HH:mm:ssZ",
                     local:String="en_US_POSIX") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: local) // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from:self)
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func getDDay() -> Int {
        Int(ceil(self.timeIntervalSince(AppUtil.networkTimeDate()) / 24)) - 1
    }
}

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

extension String{
    func replace(_ originalString:String, with newString:String) -> String {
        return self.replacingOccurrences(of: originalString, with: newString)
    }
    func replace(_ newString:String) -> String {
        return self.replacingOccurrences(of: "%s" , with: newString)
    }
    
    func parseJson() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            DataLog.e("parse : jsonString data error", tag: "parseJson")
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                DataLog.e("parse : dictionary error", tag: "parseJson")
                return nil
            }
            return dictionary
        } catch {
            DataLog.e("parse : JSONSerialization " + error.localizedDescription, tag: "parseJson")
           return nil
        }
    }
    
    
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
    
    func toBool() -> Bool {
        if self.uppercased() == "TRUE" {return true}
        if self.uppercased() == "Y" {return true}
        if self == "1" {return true}
        return false
    }
    
    func toInt() -> Int {
        return Int(self) ?? -1
    }
    
    func toFixLength(_ l:Int, prefix:String = "000000") -> String {
        if self.count >= l { return self }
        let fix:String = prefix + self
        return String(fix.suffix(l))
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
    
    func toSHA256() -> String {
        let inputData = Data(self.utf8)
        let hashed = CryptoKit.SHA256.hash(data: inputData)
        return hashed.hexStr
    }
    
    func toAES(key:String , iv:String, pass:String = "") -> String {
        let key = SymmetricKey(data: key.data(using: .utf8)!)
        //let ivData = Data(iv.utf8)
        let inputData = Data(self.utf8)
        let iv = AES.GCM.Nonce()
        let sealedBox = try? AES.GCM.seal(inputData, using: key, nonce: iv)
        return sealedBox?.combined?.base64EncodedString() ?? ""
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
    
    func onlyNumric()-> String {
        let ruleNum = "[0-9]"
        return self.getArrayAfterRegex(regex: ruleNum ).reduce("", {$0 + $1})
    }
    
    func isNickNameType() -> Bool {
        let n = self.count
        if n < 1 { return false }
        if n > 8 { return false }
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
    func isCertificationNumberType() -> Bool {
        if self.count < 6 { return false }
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
