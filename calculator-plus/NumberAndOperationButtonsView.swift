import Foundation
import SwiftUI

struct NumberAndOperationButtonsView: View {
    var calculator: CalculatorModel
    var showGraph: Bool
    @Binding var graphs: [[Double: Double]]
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            
            SpecialColumnView(calculator: calculator, graphs: $graphs)
            Spacer()
            NumberColumnView(numbers: [7, 4, 1, 0], calculator: calculator)
            NumberColumnView(numbers: [8, 5, 2], calculator: calculator, showGraph: showGraph)
            NumberColumnView(numbers: [9, 6, 3], calculator: calculator, showGraph: showGraph, lastButton: true)
            Spacer()
            OperationColumnView(calculator: calculator, showGraph: showGraph)
            
            Spacer()
        }
        .frame(height: 280)
    }
    
    private func NumberColumnView(numbers: [Int], calculator: CalculatorModel, showGraph: Bool = false, lastButton: Bool = false) -> some View {
        VStack {
            Spacer()
            ForEach(numbers, id: \.self) { number in
                NumberButton(number: number, action: { calculator.insertCharacter("\(number)") })
                Spacer()
            }
            if lastButton {
                if showGraph {
                    VariableButton(action: { calculator.performOperation("x") })
                } else {
                    OperationButton(operation: "=", action: { calculator.performOperation("=") })
                }
                Spacer()
            } else if numbers.count < 4 {
                DecimalButton(action: { calculator.insertCharacter(".")})
                Spacer()
            }
        }
    }
    
    private func SpecialColumnView(calculator: CalculatorModel, graphs: Binding<[[Double: Double]]>) -> some View {
        HStack(spacing: 10) {
            VStack {
                Spacer()
                ActionButton(label: "⌫", action: { calculator.deleteLastCharacter() })
                Spacer()
                ConstantButton(constant: "EE", action: { calculator.performOperation("E") })
                Spacer()
                OperationButton(operation: "(", action: { calculator.performOperation("(") })
                Spacer()
                OperationButton(operation: "√", action: { calculator.performOperation("√") })
                Spacer()
                ConstantButton(constant: "e", action: { calculator.performOperation("e") })
                Spacer()
            }
            VStack {
                Spacer()
                ActionButton(label: "C", action: {
                    if calculator.display == "" {
                        graphs.wrappedValue.removeAll()
                    }
                    calculator.clearDisplay()
                })
                Spacer()
                ConstantButton(constant: ",", action: { calculator.insertCharacter(",") })
                Spacer()
                OperationButton(operation: ")", action: { calculator.performOperation(")") })
                Spacer()
                OperationButton(operation: "^", action: { calculator.performOperation("^") })
                Spacer()
                ConstantButton(constant: "π", action: { calculator.performOperation("π") })
                Spacer()
            }
        }
    }
    
    private func OperationColumnView(calculator: CalculatorModel, showGraph: Bool) -> some View {
        VStack {
            Spacer()
            OperationButton(operation: "÷", action: { calculator.performOperation("÷") })
            Spacer()
            OperationButton(operation: showGraph ? "⋅" : "×", action: { calculator.performOperation("⋅") })
            Spacer()
            OperationButton(operation: "-", action: { calculator.performOperation("-") })
            Spacer()
            OperationButton(operation: "+", action: { calculator.performOperation("+") })
            Spacer()
        }
    }
}
