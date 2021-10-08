//
//  Buzz.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/26.
//

import Foundation
import BuzzAdBenefit

class Buzz{
    static let BAB_SDK_KR_iOS_DEV_APP_ID: String = "126955102496938"
    static let BAB_SDK_KR_iOS_DEV_UNIT_ID: String = "536965388173462"
    static let BAB_SDK_KR_iOS_PRD_APP_ID: String = "42532489130817"
    static let BAB_SDK_KR_iOS_PRD_UNIT_ID: String = "559982176087372"
    private static var isInit = false
    var completed: (() -> Void)? = nil
    static func initate(){
        if isInit {return}
        isInit = true
        let config = BABConfig(appId: SystemEnvironment.isStage ? BAB_SDK_KR_iOS_DEV_APP_ID : BAB_SDK_KR_iOS_PRD_APP_ID )
        
        BuzzAdBenefit.initialize(with: config)
    }
    
    func initate(pairing:Pairing, completed: (() -> Void)? = nil){
        self.completed = completed
        let birth = pairing.user?.birth.isEmpty == false ? (pairing.user?.birth ?? "0000") :  "0000"
        let yyyy = (birth.count) >= 4 ? birth.subString(start: 0, len: 4) : birth
        let userProfile = BABUserProfile(
            userId:pairing.stbId ?? "",
            birthYear: UInt(yyyy.toInt()), 
            gender: pairing.user?.gender == .femail ? BABUserGenderFemale : BABUserGenderMale )
        BuzzAdBenefit.setUserProfile(userProfile)
        
        let userPreference = BABUserPreference(autoPlayType: BABVideoAutoPlayEnabled)
        BuzzAdBenefit.setUserPreference(userPreference)
        
        let adLauncher = BABCustomLauncher()
        BuzzAdBenefit.setLauncher(adLauncher)
        NotificationCenter.default.addObserver(self, selector: #selector(loadBABAd), name: NSNotification.Name.BABSessionRegistered, object: nil)
    }
    
    func destory(){
        NotificationCenter.default.removeObserver(self)
        BuzzAdBenefit.setUserProfile(nil)
        BuzzAdBenefit.setUserPreference(nil)
        self.completed = nil
    }
    
    @objc private func loadBABAd() {
        
        self.completed?()
    }
}

open class BuzzViewModel: ComponentObservable {
    @Published var event:BuzzViewEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    
}

enum BuzzViewEvent {
    case close , info(UIViewController)
}

class BABCustomLauncher: NSObject, BABLauncher {
    func open(with launchInfo: BABLaunchInfo) {
        open(with: launchInfo, delegate: nil)
    }
    
    func open(with launchInfo: BABLaunchInfo, delegate: BABLauncherEventDelegate?) {
        // Custom Browser 실행
        let vc = CustomBrowserViewController()
        //rootViewController?.present(vc, animtated: true, completion:nil)
        
        ComponentLog.d("BABCustomLauncher " + vc.debugDescription, tag: "BuzzBill")
        let con = UIApplication.shared.windows.first?.rootViewController
        ComponentLog.d("UINavigationController " + con.debugDescription, tag: "BuzzBill")
        con?.children.first?.present(vc, animated: true, completion: nil)
      //  con?.viewControllers.first?.present(vc, animated: true, completion: nil)
    }
}

class CustomBrowserViewController: UIViewController {
    private lazy var browserViewController: UIViewController = {
        BuzzAdBrowser.sharedInstance().browserViewController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(self.browserViewController.view)
        self.browserViewController.didMove(toParent: self)
    }
}
