import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var calculator = CalculatorModel()
    @State private var showFunctions = false
    @State private var showSettings = false
    @State private var showDocs = false
    @State private var showGraph = false
    @State private var angleUnit: Int = 0
    @State private var graphs: [[Double: Double]] = [[:]]
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showDocs.toggle()
                        }) {
                            Image(systemName: "questionmark")
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                        }
                    }
                    
                    if showGraph {
                        GraphView(graphingPoints: calculator.graphingPoints, savedGraphs: graphs)
                            .padding(.horizontal, 20)
                    } else {
                        ScrollView {
                            VStack(alignment: .trailing) {
                                ForEach(calculator.history, id: \.self) { historyItem in
                                    Text(historyItem)
                                        .font(.headline)
                                        .padding(.bottom, 2)
                                }
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .rotationEffect(Angle(degrees: 180))
                        }
                        .rotationEffect(Angle(degrees: 180))
                    }
                    
                    DisplayView(cursorPosition: $calculator.cursorPosition, display: $calculator.display)
                        .frame(height: geometry.size.height * 0.075)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Divider()
                    
                    VStack(spacing: 10) {
                        
                        TopButtonsView(showFunctions: $showFunctions, showGraph: $showGraph, graphs: $graphs, calculator: calculator)
                        
                        Divider()
                        
                        Spacer()
                        if showFunctions {
                            FunctionButtonsView(showFunctions: $showFunctions, calculator: calculator)
                                .frame(height: geometry.size.height * 0.3)
                        } else {
                            NumberAndOperationButtonsView(calculator: calculator, showGraph: showGraph, graphs: $graphs)
                                .frame(height: geometry.size.height * 0.3)
                        }
                    }
                }
                if showSettings {
                    SettingsView(angleUnit: $angleUnit, showGraph: $showGraph)
                        .frame(width: geometry.size.width * 0.45, height: geometry.size.height * 0.20)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.horizontal, geometry.size.width * 0.0375)
                        .padding(.vertical, 55)
                }
                if showDocs {
                    DocsView()
                        .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.25)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.horizontal, geometry.size.width * 0.6125)
                        .padding(.vertical, 55)
                }
            }
        }
    }
}
