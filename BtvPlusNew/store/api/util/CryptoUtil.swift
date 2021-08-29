import UIKit
import CryptoSwift

@objc
@objcMembers
class CryptoUtil: NSObject {
    class func aes256(plain: String!, key: String!, iv: String!) -> String? {
        do {
            let aes = try AES(key: key, iv: iv)
            let chiperText = try aes.encrypt(plain.bytes).toBase64()
            return chiperText
        } catch { DataLog.e("aes256 error") }
        return nil
    }
    
    class func cbsEncode(plain: String, keyStr: String) -> String {

        let key = keyStr.data(using: .utf8)?.bytes
        let str_iv = keyStr.subString(start: 0, len: 16)   //String(keyStr[0..<16])
        let iv = str_iv.data(using: .utf8)?.bytes
        do {
            let encryptedText = try AES(key: key!, blockMode: CBC(iv: iv!), padding: .pkcs7).encrypt(plain.bytes)
            return encryptedText.toHexString()
        } catch {
            return "Encrypt Fail"
        }
    }
}
