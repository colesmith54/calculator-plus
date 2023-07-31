import Foundation
import SwiftUI

enum SpecialButtonLabel: String {
    case funcButton = "Func"
    case ans = "Ans"
    case save = "Save"
    case num = "Num"
}

struct CalculatorButton: View {
    let label: String
    let action: () -> Void
    var isFunction: Bool = false
    
    var body: some View {
        let size: CGFloat = SpecialButtonLabel(rawValue: label) != nil ? 60.0 : 44.0
        Button(action: action) {
            Text(label)
                .font(isFunction ? .callout : .title2)
                .frame(width: size, height: size)
                .padding(.all, 0)
                .aspectRatio(1, contentMode: .fit)
                .background(Color(.systemGray5))
                .cornerRadius(5)
        }
        .accessibility(label: Text("Button for \(label)"))
    }
}

struct ActionButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: label, action: action)
    }
}

struct NumberButton: View {
    let number: Int
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: String(number), action: action)
    }
}

struct DecimalButton: View {
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: ".", action: action)
    }
}

struct OperationButton: View {
    let operation: String
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: operation, action: action)
    }
}

struct ConstantButton: View {
    let constant: String
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: constant, action: action)
    }
}

struct FunctionButton: View {
    let function: String
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: function, action: action, isFunction: true)
    }
}

struct NavButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: label, action: action)
    }
}

struct VariableButton: View {
    let label: String = "x"
    let action: () -> Void
    var body: some View {
        CalculatorButton(label: label, action: action)
    }
}
