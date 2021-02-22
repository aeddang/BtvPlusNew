//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class BannerData:InfinityData{
    private(set) var image: String = Asset.noImg16_9
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
   
    func setData(data:BlockItem, idx:Int = -1) -> BannerData {
        if let poster = data.bnr_off_img_path {
            image = ImagePath.thumbImagePath(filePath: poster, size: ListItem.banner.size)
        }
        index = idx
        return self
    }
}

struct BannerItem: PageView {
    var data:BannerData
    var body: some View {
        ZStack{
            ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
        }
        .modifier(MatchHorizontal(height: ListItem.banner.size.height))
        .background(Color.app.blueLight)
        .clipped()
    }
}

#if DEBUG
struct BannerItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            BannerItem( data:
                BannerData())
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
    }
}
#endif

