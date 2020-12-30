//
//  SpanText.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/30.
//

import Foundation
import SwiftUI
import WebKit
extension String {
    var decoded: String {
            let attr = try? NSAttributedString(data: Data(utf8), options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)

            return attr?.string ?? self
        }
    
    var encoded:NSAttributedString {
        let data = Data(self.utf8)
        guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return NSAttributedString.init()
        }
        return attributedString
    }
    
    func html(str:String , style:String = Font.family.regular) -> String {
        return  "<div>" + self + "<span style=' font:" + style + "'>" + str
    }
    func appand(str:String, color:Color = Color.yellow, size:CGFloat = 30) -> String {
        let px = String(format:"%.0f", size) + "px"
        let hex = color.uiColor().toHexString()
        let span = "<font size='" + px + "'"
            + " color='" + hex + "'>"
            + str + "</font>"
        return self + span
    }
    
    func end(str:String) -> String {
        return self + "</span>" + str + "</div>"
    }

}

struct SpanText: UIViewRepresentable {
    let htmlString: String
    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.loadHTMLString(self.htmlString, baseURL: nil)
        return web
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct HTMLText: UIViewRepresentable {

   let attributedString: NSAttributedString

   func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        label.attributedText = attributedString
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}

#if DEBUG
struct SpanText_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            Text("This is HTML String")
            HTMLText(attributedString:
                        "".html(str: "Testing")
                            .appand(str: " HTML ", color: .blue)
                            .end(str: "Content").encoded)
            SpanText(
                htmlString:"This is HTML String"
            )
        }
        .frame(width: 320, height: 120)
        .background(Color.blue)
    }
}
#endif
