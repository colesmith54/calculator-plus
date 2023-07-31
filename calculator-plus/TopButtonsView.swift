import Foundation
import SwiftUI

struct TopButtonsView: View {
    @Binding var showFunctions: Bool
    @Binding var showGraph: Bool
    @Binding var graphs: [[Double: Double]]
    var calculator: CalculatorModel
    
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            NavButton(label: showFunctions ? "Num" : "Func", action: {
                showFunctions.toggle()
            })
            Spacer()
            ActionButton(label: "←", action: {
                calculator.moveCursor(by: -1)
            })
            Spacer()
            ActionButton(label: "→", action: {
                calculator.moveCursor(by: 1)
            })
            Spacer()
            if showGraph {
                ActionButton(label: "Save", action: {
                    graphs.append(calculator.graphingPoints)
                })
            } else {
                ConstantButton(constant: "Ans", action: {
                    calculator.performOperation("(ans)")
                })
            }
            Spacer()
        }
        .frame(height: 75)
    }
}
