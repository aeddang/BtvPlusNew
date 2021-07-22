//
//  CustomResourceLoaderDelegate.swift
//  External WebVTT Example
//
//  Created by Joris Weimar on 24/01/2019.
//  Copyright © 2019 Joris Weimar. All rights reserved.
//
import Foundation
import AVFoundation
/*
class FairplayResourceLoader: NSObject, AVAssetResourceLoaderDelegate , PageProtocol{
    private var originURL:URL
    private var delegate: CustomAssetPlayerDelegate?
    private var drm:FairPlayDrm
    private var info:AssetPlayerInfo? = nil
    init(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm) {
        self.originURL = m3u8URL
        self.drm = drm
        self.delegate = playerDelegate
        self.info = assetInfo
        super.init()
    }
   
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource
        loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
      
               
        guard let certificateData = drm.certificate else {
            self.delegate?.onAssetLoadError(.drm(.noCertificate))
            return false
        }
               
        guard
            let host = loadingRequest.request.url?.host,
            let contentIdentifierData = host.data(using: .utf8),
            let spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdentifierData, options: nil) else {
                DataLog.e("🔑 Unable to read the SPC data", tag: self.tag)
                loadingRequest.finishLoading(with: NSError(domain: "eu.osx.tvos.NPO.error", code: -4, userInfo: nil))
                return false
        }
        
        var licenseRequest = URLRequest(url: URL(string: drm.ckcURL)!)
        licenseRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        licenseRequest.httpMethod = "POST"
        var params = [String:String]()
        params["spc"] = spcData.base64EncodedString()
        params["assetId"] =  host
        licenseRequest.httpBody = params.map{$0.key + "=" + $0.value.toPercentEncoding()}.joined(separator: "&").data(using: .utf8)
        
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: licenseRequest) { data, response, error in
            guard let data = data else {
                DataLog.e("ckc nodata", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                loadingRequest.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            
            var responseString = String(data: data, encoding: .utf8)?
                .replacingOccurrences(of:"\n<ckc>", with: "")
                .replacingOccurrences(of:"</ckc>\n", with: "")
                .replacingOccurrences(of: "<ckc>", with: "")
                .replacingOccurrences(of: "</ckc>", with: "")
            
            DataLog.d("origin data: \(String(describing: data.bytes))", tag: self.tag)
            DataLog.d("origin data: \(String(describing: String(data: data, encoding: .utf8)))", tag: self.tag)
            DataLog.d("origin data base64: \(data.base64EncodedData())", tag: self.tag)
            
            let srrA = "AAAAAQAAAAB/yw4PQJNGBQDgMzIMovNaAAAEUAGs1kFabCoHn8FzO+/kgTYxtEngv0ussVCnOgP3tykqhdXTBcQKPqCvQIDJMuI4N/kW/okYdJ/nw2SUSk24SwbGNsXnQ5bTtVONMvLR0uXDJjksGs7Rbg3NCD5rQgNy3cz9WAKWciPvrSCZVZku/WEBCOuQAmPER7ZI4yt+Zh7TU2o8QQr6LU24AW6q7rzPznB/Wz6P310HjUbKLaH5IG7srIywpicRBv+6ygRCcMqj2Qm5hxDoaX502cew0cC/5yI6m00YRLwRlK9P2HOGfcPqRB6Fj773PByqzTqaJTcJr/k41AelNnAmhwRVKlWGHEpcBc86WPXzzhuwohLmyYzDtJvK4zOiTzxE9X0OsOw0qv9IDV1OaNvCWhxMGiWGsL4zPA4aCbVJ8NQMB7RlPhCdkg6ChQTTtXea3VNHwUSMBDLAQFSOiWokosPNUJvPQHfwPFd2v/IN2+/5juYvaRnRgh5KR2iCNqWsCtyE33ecozRoHy+qhqNeT02jZ9/h9UHAT1+0PGVm9khR0LvysL+CFlzU697htKU8IoCLDQserO+/jSMEvoVe0MuSRuk9XMK1599Ydksmh9uB1cDweNIi+taaTDhFJSuOo4IehjWUud3qCXQ4LhPvEvwRa44Cf8d2BHwXNTpH9P7eO82Tkn5D95rYl1gSB50dRP6TYCj9cl0jOGGupZv1AGsF31vGu1wgXk9F39ZR18E+iot5mBfBiBQ3OKajxgMjOLuU37uyALC9FAMAicvauY51kDLrW7QNv+PKXXFUjwZ327N92hMbn9x6Mv5Eg477XAunPuLsrZoOrd48eJQztR3kcBb7By1XotiEQS92F7ywagh8pmqJMoxwb3B/EvrKenVHYUxVUt07ilt6Tc+h+F8WYb6604PipgQ8+9wxqeRFDVGtjv4Ts0Ji8afCrFuxJnFD+OeBeHxfMB0qPORAwLXf8h2n+hbwLyK/uA186yG+b41R1aK8NFl+xe4xRYAZvTBlO4zqlY5khogDHGEi15+VqtyLDVpq9QilEXgSGuUqR8UjxnVyl9KF5+kkBjgsu2oHR5KQjAxlLP4RnX3cysyDPk3NU+vjgj1IBYOCg4ht/h5EJk/23Am2TeUZeBxNoHIcE3oIZ+hjetlUCL1WPRbhIlS67LGv1GQpMwbze7yDJOuZaGiXzijPCXVSkHlOf9tLhqTt+7lVKECcdo0hBULhSHnmyqSh0k8UfpKyHH4/GrIqUUODPQUGU4mgPPFVRsjg+UngNWHJweq+bGt1rJ0tNknvk2sLs0Ml0PbMWMLxYkXxUSBrI4ZvrAhTt8v6O69PpN8W/IkRVeKufz+NIDyprhaBXQrwGmYV4QSsYTP+KevdgLHXL+/mGRKxvJER7CtUFbRWylIYLqEVPxeV7YZPgw10GGMMrRVIfrwefydG3+KQ8F6pty3yU8sf060eXIKJ8upn4c3N4anJRPTGQHuViwxxqg=="
            
            let srrB = "AAAAAQAAAAAS01p3zxEuHtahQvD/c6hRAAAEcHoKe+cUA9wX5JiSx8Kd8B8olYcRXEuPLPTWZTPjr45qZZUeZ7PhD5Sm00238GJilUoyCKj6Ppq8DSBUNbuPzoR3wVJvLWAyax84kDTNqEbQC6XHRROZGr26s3wKq0HVZBQmTlJokMa1fGM6O9Q3enqeeAZ+CPJ0oxFEhdHQxxtAiqieIR8KAEfjjyGiIvkIPNq+FMpVl2gFK0uxUDGCubrr4/+17/OvPLe0RB9HH88Xa2h2u8mNGpRGcxtqJlQq/sJL7rXeyY1RxGq3WcocQxy64R3cbmE/ijR1tOzy7Sx91BBiqS+VtZFvOQdA3StJ6t5aq2+WOmsAtdN4WoWSg/+J66gfMSX+HbvmKUYYIbTocWadkYHY4D8iEJLN/Qut/vCOT1HusWuOMrpN7i3LN2Vy9vcp0TLxVSf7LOHDMTdqwIGisAqE1/7jY9NjQUlIApY/kcb6R95AcsXk2HW9RZ/kBNXahhwMG60jdyltH+SJg34pv6E7Jqsx8Bzzz1o8hlAXv9lml+9hVoZQs2iDQfVdY8NM5HxIxxRV4H+4OOTKqeF37lpZn2CkvZFcolrV5Hm5vxNU+9oPEjGAuEl7h59UyaRoC4Qmpj8ZaMuyE+qP/h3UJL0wyMBfoZbCCAEh0jCaBpHBWUSJ+eZD62YRmvcHxyGXC4zfUu2o8TWLbaz2njQ2Ffst8adNp5XAzBia3nIJVKvNKQjmuSdl2DDxF7musyUdfXk6ctIK6JbC0AkAgP95uojlesHc0aqE5UnpCwGKYYC2JOJHMy/zBk8h3BpMW36HyjwpQnyd/vd/n6+jyPVVhhDEwF8MQYLhDs9BesqESxOyBBCSScji8SYVSKBSDurp2/Fx+euWj5mC3pPE8lM+orRQJ1Yo8dHzTTDnxAVDlr7qol9iOh+s7FtHsKVrTBavkT2WSrecw6IJIng7MjNBX5awUiCbf3LwVGok0kDZ++nEmZcszB+jSruX+rvAkaQUAsHSrkCjfVOim45E4yo99VtTdyabM7lyZMdyVhopx4ecpll/EWVPlaTnD8EOFBJFSLXB6XGx5RgMTJ5BtSB1k/CUI4mIGXgQxOp0ijUnPZlVGgHPF/L3HXYoio93xuk4pL7KjZyAcMcWmvIDz22myx/Zt94bX56G2oAG2JiCemvVz9ntBZ+UHcypvgBXuYzkQsYg1FvI09WOzz0J4Wv/VhkTQPhSyMgT1dK7bOpkYjepdZZiKLLbaPXDJB1zibkuJ3U0a058FuTU5TbwIj/bh1vx1obxZTgf284UQkx2331gIVmyq1cxkJ/yfOoNvKx0g16UEez9DRp/n75Cl42LYEO57/di7oLanoGNtzFFroo82q+8jNkoLQcEZ+vKxB4zl/ojsKWz3rxDzEbiZ76csJ/TUrahenVGZvkCenL7FkIL5Ex5l02VKXHMj1+9GK/Jqk/YVjLVibdCSWF3h2POzg/LT8b6+/WGigxgOQOOvfkMJaEgC7rs3lA2GU7e3EVQO0A4eRsG2AUYiVS8"
            
           
            if let ckcData = Data(base64Encoded:responseString!) {
                DataLog.e("ckc base64Encoded responseString", tag: self.tag)
                loadingRequest.dataRequest?.respond(with:ckcData)
                loadingRequest.finishLoading()
            }
            if let aData = Data(base64Encoded:srrA) {
                DataLog.e("ckc base64Encoded A", tag: self.tag)
            }
            if let bData = Data(base64Encoded:srrB) {
                DataLog.e("ckc base64Encoded B", tag: self.tag)
               
            }
            
            /*
            do {
                let ckcData = try! Data(base64Encoded:responseString!)
                    
                
            } catch {
                if let err:NSError = error as? NSError {
                    DataLog.e("ckc base64Encoded error \(err.localizedDescription)", tag: self.tag)
                }
                DataLog.e("ckc base64Encoded error \(error.localizedDescription)", tag: self.tag)
            }*/
            
            
            DataLog.e("drm is Completed", tag: self.tag)
            self.drm.isCompleted = true
        }
        task.resume()
        return true
    }
    
    @discardableResult
    func getLicenseData(_ request: AVAssetResourceLoadingRequest, drmData:FairPlayDrm) -> Bool {
        DataLog.d("getSpcData", tag: self.tag)
        guard let certificate = drmData.certificate else {
            self.delegate?.onAssetLoadError(.drm(.noCertificate))
            request.finishLoading(with: DRMError.noCertificate)
            return false
        }
        let contentId = drmData.contentId ?? "" // content id
        guard let contentIdData = contentId.data(using: String.Encoding.utf8) else {
            self.delegate?.onAssetLoadError(.drm(.noContentIdFound))
            request.finishLoading(with: DRMError.noContentIdFound)
            return false
        }
        DataLog.d("contentId " + contentId , tag: self.tag)
        DataLog.d("contentIdData " + contentIdData.base64EncodedString() , tag: self.tag)
                
        guard let spcData = try? request.streamingContentKeyRequestData(
                forApp: certificate,
                contentIdentifier: contentIdData) else {
            request.finishLoading(with: NSError(domain: "spcData", code: -3, userInfo: nil))
            DataLog.e("DRM: false to get SPC Data from video", tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(.noSPCData))
            request.finishLoading(with: DRMError.noSPCData)
            return false
        }
        
        guard let ckcServer = URL(string: drmData.ckcURL) else {
            DataLog.e("ckc url error", tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(.noLicenseUrl))
            request.finishLoading(with: DRMError.noLicenseUrl)
            return false
        }
        
        var licenseRequest = URLRequest(url: ckcServer)
        licenseRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        licenseRequest.httpMethod = "POST"
        var params = [String:String]()
        params["spc"] = spcData.base64EncodedString()
        params["assetId"] = contentId
        licenseRequest.httpBody = params.map{$0.key + "=" + $0.value.toPercentEncoding()}.joined(separator: "&").data(using: .utf8)
        
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: licenseRequest) { data, response, error in
            guard let data = data else {
                DataLog.e("ckc nodata", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            /*
            var responseString = String(data: data, encoding: .utf8)
            responseString = responseString?
                .replacingOccurrences(of: "<ckc>", with: "")
                .replacingOccurrences(of: "</ckc>", with: "")
                .replacingOccurrences(of: "\n", with: "")
            guard let str = responseString  else { return }
            DataLog.d("license key data " + str, tag: self.tag)
            
            guard let decodedData = Data(base64Encoded: str, options: .ignoreUnknownCharacters) else {
                DataLog.e("ckc base64Decoded  decodedData", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            DataLog.d("license key decode data " + decodedData.debugDescription, tag: self.tag)
            if let decodedString = String(data: decodedData, encoding: .utf8) {
                DataLog.d("license key decode data " + decodedString, tag: self.tag)
            }
            */
            
            //request.dataRequest?.respond(with: data)
            //request.finishLoading()
            //self.drm.isCompleted = true
            /*
            guard let ckcData = Data(base64Encoded:str, options: .ignoreUnknownCharacters)  else {
                DataLog.e("ckc base64Encoded", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            */
            
            
            
            //DataLog.d("origin data: \(String(describing: data.bytes))", tag: self.tag)
            //DataLog.d("origin data: \(String(describing: String(data: data, encoding: .utf8)))", tag: self.tag)
            //DataLog.d("origin data base64: \(data.base64EncodedData())", tag: self.tag)
            
            var responseString = String(data: data, encoding: .utf8)
            //responseString = responseString?
                // .replacingOccurrences(of: "\n", with: "")
                
            let str = "AAAAAQAAAACltlSP3gUc9MEpIsMkC1YAAAADMH0+Rl19Z1hR2gMVAh/geizrqh2UBVEU5wqKw07WuE/S6WF9Ls4aGrw9wV5uVhyrD7zxw1ls27Q59ZEA7EYYo9/ZFxKPhal4G8F2u2e0/GlZ1DWsuQrGfTLphWh9OuardrhKzrACF7vj2HKIPpNR9KmYrQPrQM6vDnSpNGoMjQ44J5Su0OuDKOt58Syj+0DUdCeg8lVdB23p1lFizUkAwyZ1uFzWhXzowqla7kie/srQpLucEkNQhlEy6vZ9AIuq+UfC7u0hApxwxjDPbSD+fgcBI2Rm0ohRhdG4eXkLrRXrSXEkywnAri9hW6HYCqEE4KbHf8j/3O7c+UfmzkibbHjo9wER9Bike0/BOc0GagKmMLBr8wiIjwsXNsc4tdKMfm3gv5ODTfVX3LlMo0O1vJ6H+01WRbh0UlXMN3stS4V0nmk+Y85IQ2cqRLx2mZtKXfYHse60Z1Xtz/A+NCLoO2c42nNkYeXk1pkTKo28w0JoAr5z4R2IHx5+mLlDW23jcJ9tGXKFxCROPqopBni3LRt5WilY2dbc/qWYAUpiL7pyRuHkhs6V1UOTrRD0Qf4CuYiMB43+kJLI/4U7WiJiFSfshRAojxgWvCU6KluKbxjKAE+n3yJ8ITicjShDtRuGoSYy18GoSxD9efHDSeewZdVZpc5oUeHPZNNEasRBciWmkbIeYSCbZidDHELv49/68Dqyyck8zwxxSOXoAHPTFbxMuy49GyB+HO9pGnHU7MMthquwTHda1uUBVy7i28qlGPtKsTxpku6331muf8MVl5U05LlCxAFUuV7cMeat3Cl3Ahi0WZ1YM0t8mm3HCuUwaP5qFQEHeF3FRWXEQqFkGyoJvSKdhRqFjL24b3XefGflfvozBqJCbZCwWgHbNk0s0Y8PwLH9cQyhUshmLghocdA+nTyh/7qHO6+2r3yILw5GsLnC9jfcqCvQgHD301EJpLQ7rUIOSif+diujMd6Tp5KXIUlA50YDnABtvTvLplvwOOxkufA1sR2ukCWQNj1j92v2y6ZGJmJRXODyO7eZE2eihbhfsEQNZ/DxrkS8B1VITUodZ8ArUpoNcpw5V6t/GQ=="
            

            /*
            guard let ckcData = Data(base64Encoded:str)  else {
                DataLog.e("ckc base64Encoded", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            
            guard let ckcData = str.data(using: .utf8) else {
                DataLog.e("ckc base64Encoded", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }*/
            //DataLog.d("data: \(String(describing: ckcData.bytes))", tag: self.tag)
            //DataLog.d("data: \(String(describing: String(data: ckcData, encoding: .utf8)))", tag: self.tag)
            //DataLog.d("data base64: \(ckcData.base64EncodedString())", tag: self.tag)
            
            
            request.dataRequest?.respond(with:data)
            request.finishLoading()
            self.drm.isCompleted = true
            
            /*
            var persistentKeyData: Data?
            do {
                persistentKeyData = try request.persistentContentKey(fromKeyVendorResponse: ckcData, options: nil)
            } catch {
                DataLog.e("Failed to get persistent key with error: \(error)", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.unableToGeneratePersistentKey))
                request.finishLoading(with: DRMError.unableToGeneratePersistentKey)
                return
            }
            request.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
            request.dataRequest?.respond(with: persistentKeyData!)
            request.finishLoading()
            */
        }
        task.resume()
        return true
    }
    
   
    
    @discardableResult
    func redirectRequest(_ request: AVAssetResourceLoadingRequest) -> Bool {
        

        guard let path = request.request.url?.absoluteString else {return false}
        let redirect = path.replace("skd://", with: "https://")
        guard let redirectUrl = URL(string:redirect) else {return false}
        let redirectRequest = URLRequest(url: redirectUrl)
        DataLog.d("redirectRequest " + redirect, tag:self.tag)
        
        //redirectRequest.httpMethod = "POST"
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: redirectRequest) {
            (data, response, error) in
            guard error == nil,
                let data = data else {
                    request.finishLoading(with: error)
                    return
            }
            request.dataRequest?.respond(with:data)
            request.finishLoading()
            
        }
        task.resume()
        return true
    }
    
    func handleRequest(_ request: AVAssetResourceLoadingRequest, path:String) -> Bool {
        
        DataLog.d("handleRequest", tag:self.tag)
        
        guard let contentKeyIdentifierURL = request.request.url,
            let assetIDString = contentKeyIdentifierURL.host
        else {
            self.delegate?.onAssetLoadError(.drm(.noContentIdFound))
            request.finishLoading(with: DRMError.noContentIdFound)
            return false
        }
        if assetIDString == self.originURL.host {
            self.delegate?.onAssetLoadError(.drm(.noContentIdFound))
            request.finishLoading(with: DRMError.noContentIdFound)
            return false
    
        }
        drm.contentId = assetIDString
        return self.getLicenseData(request, drmData: drm)
        
        /*
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) {
            [weak self] (data, response, error) in
            guard error == nil,
                let data = data else {
                    request.finishLoading(with: error)
                    return
            }
            if self?.drm.isCompleted == true {
               
                request.finishLoading()
            } else {
                guard let contentKeyIdentifierURL = request.request.url,
                    let assetIDString = contentKeyIdentifierURL.host
                else {
                    self?.delegate?.onAssetLoadError(.drm(reason: "assetID"))
                    request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
                    return
                }
                if assetIDString == self?.originURL.host {
                    self?.delegate?.onAssetLoadError(.drm(reason: "assetID"))
                    request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
            
                } else if let drm = self?.drm{
                    drm.contentId = assetIDString
                    self?.getLicenseData(request, drmData: drm)
                }
            }
        }
        task.resume()
        return true
        */
    }
}
*/
