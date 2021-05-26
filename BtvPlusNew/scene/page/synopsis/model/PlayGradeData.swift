//
//  SynopsisPrerollData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/09.
//

import Foundation

struct PlayGrade:Identifiable {
    var id: String = UUID().uuidString
    let icon:String
    let text:String
}


class PlayGradeData {
    private(set) var icon:String? = nil
    private(set) var text:String? = nil
    private(set) var gradeInfo:String? = nil
    private(set) var manufcoName:String? = nil
    private(set) var no:String? = nil
    private(set) var date:String? = nil
    private(set) var grades:[PlayGrade] = []

    private func addGrade(icon:String, value:String? , yn:String? ){
        if yn?.uppercased() != "Y" {return}
        guard let value = value else {return}
        var text = ""
        switch value {
        case "0": text = String.app.low
        case "12": text = String.app.middle
        case "15": text = String.app.high
        case "19": text = String.app.highst
        default: break
        }
        grades.append(PlayGrade(icon: icon, text: text))
    }
    
    private func getSafeValue(_ value:String?) -> String?{
        guard let value = value else {return nil}
        if value.isEmpty {return nil}
        return value
    }
    
    func setData(data:SynopsisContentsItem) -> PlayGradeData{
        self.icon = Asset.age.getPlayerIcon(age: data.wat_lvl_cd)
        self.manufcoName = getSafeValue(data.manufco_nm)
        self.no = getSafeValue(data.pcim_lvl_cls_no)
        self.date = getSafeValue(data.pcim_lvl_cls_dy)
        self.text = getSafeValue(data.wat_lvl_phrs)
        addGrade(icon: Asset.icon.playerContentInfo1, value: data.pcim_lvl1_wat_age_cd, yn: data.pcim_lvl1_exps_yn)
        addGrade(icon: Asset.icon.playerContentInfo2, value: data.pcim_lvl2_wat_age_cd, yn: data.pcim_lvl2_exps_yn)
        addGrade(icon: Asset.icon.playerContentInfo3, value: data.pcim_lvl3_wat_age_cd, yn: data.pcim_lvl3_exps_yn)
        addGrade(icon: Asset.icon.playerContentInfo4, value: data.pcim_lvl4_wat_age_cd, yn: data.pcim_lvl4_exps_yn)
        addGrade(icon: Asset.icon.playerContentInfo5, value: data.pcim_lvl5_wat_age_cd, yn: data.pcim_lvl5_exps_yn)
        addGrade(icon: Asset.icon.playerContentInfo6, value: data.pcim_lvl6_wat_age_cd, yn: data.pcim_lvl6_exps_yn)
        addGrade(icon: Asset.icon.playerContentInfo7, value: data.pcim_lvl7_wat_age_cd, yn: data.pcim_lvl7_exps_yn)
        
        if let name = self.manufcoName, let no = self.no {
            self.gradeInfo = String.app.mutual + " : " + name + "\n" + String.app.gradeNo + " : " + no
        } else if let name = self.manufcoName  {
            self.gradeInfo = String.app.mutual + " : " + name
        } else if let no = self.no  {
            self.gradeInfo = String.app.gradeNo + " : " + no
        }
        
        return self
    }
    
    func setDummy() -> PlayGradeData{
        self.icon = Asset.age.getPlayerIcon(age: "19")
        self.manufcoName = "test"
        self.no = "121212121212"
        self.date = "2012.09.01"
        self.text = "이 비디오물은 청소년 관람불가 등급으로\n만 18세 미만의 청소년은 시청할 수 없습니다."
        addGrade(icon: Asset.icon.playerContentInfo1, value: "0", yn: "y")
        addGrade(icon: Asset.icon.playerContentInfo2, value: "12", yn: "y")
        addGrade(icon: Asset.icon.playerContentInfo3, value: "15", yn: "y")
        addGrade(icon: Asset.icon.playerContentInfo4, value: "19", yn: "y")
        addGrade(icon: Asset.icon.playerContentInfo5, value: "0", yn: "y")
        addGrade(icon: Asset.icon.playerContentInfo6, value: "0", yn: "y")
        addGrade(icon: Asset.icon.playerContentInfo7, value: "19", yn: "y")
        
        if let name = self.manufcoName, let no = self.no {
            self.gradeInfo = String.app.mutual + " : " + name + "\n" + String.app.gradeNo + " : " + no
        } else if let name = self.manufcoName  {
            self.gradeInfo = String.app.mutual + " : " + name
        } else if let no = self.no  {
            self.gradeInfo = String.app.gradeNo + " : " + no
        }
        
        return self
    }
}
