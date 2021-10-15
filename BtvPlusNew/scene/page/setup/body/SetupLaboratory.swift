//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupLaboratory: PageView {
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text("Laboratory").modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: "DRM 플레이어",
                    more:{
                        self.pagePresenter.openPopup(PageProvider.getPageObject(.playerTest))
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                
                SetupItem (
                    isOn: .constant(true),
                    title: "강제로 APPLE",
                    more:{
                        if self.repository.pairing.pairingStbType == .btv {
                            self.repository.pairing.pairingStbType = .apple
                        } else {
                            self.repository.pairing.pairingStbType = .btv
                        }
                        
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                
                SetupItem (
                    isOn: .constant(true),
                    title: "test push",
                    subTitle: self.repository.pushManager.apnsToken,
                    more:{
                        let push = UNMutableNotificationContent()
                        push.title = "test Title"
                        push.subtitle = "test subTitle"
                        push.body = "test body"
                        push.badge = 1
                        var userInfo = [String:Any]()
                        var aps = [String:Any]()
                        var system_data = [String:Any]()
                        system_data["messageId"] = "pixunptufh3uncbogyadn"
                        system_data["type"] = "message"
                    
                        aps["mutable-content"] = 1
                        aps["alert"] = "알람이 오네요" + UUID().uuidString
                        aps["badge"] = 10
                        aps["sound"] = "default"
                        userInfo["aps"] = aps
                        push.userInfo = userInfo
                        
                        //"aps":{
                        //      "alert":{
                        //         "title":"시놉 바로가기",
                        //         "body":"push 메시지입니다."
                        //      },
                        //      "mutable-content":1
                        //   },
                        //    "system_data":{
                        //      "messageId":"pixunptufh3uncbogyadn",
                        //      "ackUrl":"",
                        //      "blob":null,
                        //      "hasMore":false,
                        //      "type":"message"
                        //   },
                        //   "user_data":{
                        //      "msgType":"content",
                        //      "sysType":"Admin",
                        //      "imgType":"icon",
                        //      "landingPath":"SYNOP",
                        //      "posterUrl":"PIMG",
                        //      "title":"시놉 바로가기",
                        //      "iconUrl":"IIMG",
                        //      "receiveLimit":"",
                        //      "destPos":"http:\\/\\/m.btvplus.co.kr?type=30&id=CE0001166079",
                        //      "timestamp":"20201111180000",
                        //      "notiType":"ALL"
                        //   }
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                        let request = UNNotificationRequest(
                            identifier: UUID().uuidString,
                            content: push.copy() as! UNNotificationContent , trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    }
                )
                
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupTest_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupLaboratory()
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
