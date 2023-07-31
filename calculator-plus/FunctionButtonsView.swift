import Foundation
import SwiftUI
struct FunctionButtonsView: View {
    @Binding var showFunctions: Bool
    var calculator: CalculatorModel
    let trigFunctions = ["sin", "cos", "tan", "csc", "sec", "cot"]
    let inverseTrigFunctions = ["asin", "acos", "atan", "acsc", "asec", "acot"]
    let otherFunctions = ["log", "ln", "abs", "floor", "ceil", "round"]
    let twoParameterFunctions = ["logb", "root", "mod", "hypot", "nPr", "nCr"]
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                // Trig Functions
                ForEachButton(functions: trigFunctions)
            }
            Spacer()
            HStack(spacing: 10) {
                // Inverse Trig Functions
                ForEachButton(functions: inverseTrigFunctions)
            }
            Spacer()
            HStack(spacing: 10) {
                // Other Functions
                ForEachButton(functions: otherFunctions)
            }
            Spacer()
            HStack(spacing: 10) {
                // Two Parameter Functions
                ForEachButton(functions: twoParameterFunctions, hasComma: true)
            }
        }
    }
    
    private func ForEachButton(functions: [String], hasComma: Bool = false) -> some View {
        HStack(spacing: 15) {
            ForEach(functions, id: \.self) { function in
                FunctionButton(function: function, action: {
                    calculator.performOperation("\(function)\(hasComma ? "(,)" : "()")")
                    showFunctions = false
                })
            }
        }
    }
}
