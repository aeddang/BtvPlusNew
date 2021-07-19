//
//  Drm.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/19.
//

import Foundation

enum DRMError: Error {
    case noCertificate
    case noSPCFound
    case noContentIdFound
    case noLicenseUrl
    case cannotEncodeCKCData
    case unableToGeneratePersistentKey
    case unableToFetchKey(underlyingError: Error?)
    
    func getDescription() -> String {
        switch self {
        case .noCertificate:
            return "no Certificate"
        case .noSPCFound:
            return "not SPCFound"
        case .noContentIdFound:
            return "not ContentIdFound"
        case .noLicenseUrl:
            return "no License url"
        case .cannotEncodeCKCData:
            return "cannot encode CKCData"
        case .unableToGeneratePersistentKey:
            return "unable to generatePersistentKey"
        case .unableToFetchKey:
            return "unable to fetchKey"
        }
    }
}
