import Foundation
import SwiftUI

struct SettingsView: View {
    @StateObject var calculator = CalculatorModel()
    @Binding var angleUnit: Int
    @Binding var showGraph: Bool
    let angleUnits = ["Rad", "Deg"]
    
    var body: some View {
        VStack {
            Picker("", selection: $angleUnit) {
                ForEach(0..<2) { index in
                    Text(self.angleUnits[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .cornerRadius(10)
            Toggle(isOn: $showGraph) {
                Text("Enable Graphing")
            }
            .padding()
        }
        .onChange(of: angleUnit) {
            calculator.updateAngleUnit(unit: angleUnit)
        }
        .onChange(of: showGraph) {
            calculator.updateGraphing(value: showGraph)
        }
    }
}
