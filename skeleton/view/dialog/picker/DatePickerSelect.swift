//
//  Picker.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/31.
//

import Foundation
import SwiftUI
extension View {
    func datePicker(
        isShowing: Binding<Bool>,
        selected: Binding<Date>,
        dateClose : Int = 0,
        action: @escaping (_ date:Date?) -> Void) -> some View {

        var defaultClosedRange: ClosedRange<Date> {
            let startDay = Calendar.current.date(byAdding: .year, value: -dateClose, to: Date())!
            let now = Date()
            return startDay...now
        }
    
        return DatePickerSelect(
            isShowing: isShowing,
            presenting: { self },
            selected: selected,
            dateClosedRange : defaultClosedRange,
            action:action)
    }
}
struct DatePickerSelect<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
   
    @Binding var selected:Date
    var dateClosedRange: ClosedRange<Date>
    let action: (_ date:Date?) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                withAnimation{
                    self.isShowing = false
                }
                self.action(nil)
            
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack(spacing:0){
                DatePicker(
                    "",
                    selection: self.$selected,
                    in:dateClosedRange,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .exChangeTextColor(Color.app.white)
                .datePickerStyle(WheelDatePickerStyle())
                FillButton(
                    text: String.app.confirm,
                    isSelected: true
                ){_ in
                    self.action(self.selected)
                }
            }
            .padding(.bottom, self.sceneObserver.safeAreaIgnoreKeyboardBottom)
            .background(Color.app.blue)
        }
        .opacity(self.isShowing ? 1 : 0)
        
        
    }
    
}

#if DEBUG
struct DatePickerSelect_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .datePicker( 
            isShowing: .constant(true),
            selected: .constant(Date())
        ){ date in
        
        }
    }
}
#endif
