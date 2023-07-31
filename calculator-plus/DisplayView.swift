import Foundation
import SwiftUI

struct CalculatorConstants {
    static let characterWidths: [Character: CGFloat] = [
        "1": 20, "2": 27, "3": 27, "4": 27, "5": 27,
        "6": 27, "7": 25, "8": 27, "9": 27, "0": 27,
        "+": 27, "-": 20, "⋅": 32, "÷": 30, "(": 17,
        ")": 17, "√": 32, "^": 27, "e": 25, "π": 25
    ]
}

struct DisplayView: View {
    @Binding var cursorPosition: Int
    @Binding var display: String
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let spacing: CGFloat = 1
            
            let textWidthEstimate = display.reduce(0) { result, char in
                result + (CalculatorConstants.characterWidths[char] ?? 20) + spacing  // Add the spacing to each character
            }
            
            let optimalFontSize = textWidthEstimate > containerWidth ? (containerWidth / (textWidthEstimate - spacing)) * 34 : 34  // Subtract the last spacing
            
            HStack(spacing: 0) {  // Set the spacing
                Spacer()  // Pushes the text to the right side of the view
                ForEach(Array(display.enumerated()), id: \.offset) { index, char in
                    if index == cursorPosition {
                        BlinkingCursor()
                    }
                    Text(String(char))
                        .font(.system(size: optimalFontSize))  // adjusted font size
                }
                if cursorPosition >= display.count {
                    BlinkingCursor()
                }
            }
            .padding()
        }
    }
}

struct BlinkingCursor: View {
    @State private var opacity: Double = 1
    @State private var timer: Timer? = nil
    var body: some View {
        Rectangle()
            .fill(Color.primary)
            .frame(width: 2, height: 36)
            .opacity(opacity)
            .animation(.easeInOut, value: 1)
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
                    self.opacity = self.opacity == 1 ? 0 : 1
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
}
