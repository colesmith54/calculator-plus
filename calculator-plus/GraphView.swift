import Foundation
import SwiftUI
struct GraphView: View {
    var graphingPoints: [Double: Double]
    var savedGraphs: [[Double: Double]]
    let yJumpThreshold = 0.99
    
    @State private var xRange: ClosedRange<Double> = -10...10
    @State private var yRange: ClosedRange<Double> = -10...10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                drawGrid(geometry: geometry)
                drawAxes(geometry: geometry)
                drawAxisLabels(geometry: geometry)
                drawSavedGraphs(geometry: geometry)
                drawCurrentGraph(geometry: geometry)
            }
        }
    }
    
    private func drawGrid(geometry: GeometryProxy) -> some View {
        Path { path in
            let graphWidth = geometry.size.width
            let graphHeight = geometry.size.height
            // Horizontal lines
            for i in stride(from: yRange.lowerBound, through: yRange.upperBound, by: 1) {
                let y = graphHeight - CGFloat((i - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)) * graphHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: graphWidth, y: y))
            }
            // Vertical lines
            for i in stride(from: xRange.lowerBound, through: xRange.upperBound, by: 1) {
                let x = CGFloat((i - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)) * graphWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: graphHeight))
            }
        }
        .stroke(Color.gray.opacity(0.2))
    }
    
    private func drawAxes(geometry: GeometryProxy) -> some View {
        Path { path in
            let graphWidth = geometry.size.width
            let graphHeight = geometry.size.height
            // x-axis
            path.move(to: CGPoint(x: 0, y: graphHeight / 2))
            path.addLine(to: CGPoint(x: graphWidth, y: graphHeight / 2))
            // y-axis
            path.move(to: CGPoint(x: graphWidth / 2, y: 0))
            path.addLine(to: CGPoint(x: graphWidth / 2, y: graphHeight))
        }
        .stroke(Color.gray)
    }
    
    private func drawAxisLabels(geometry: GeometryProxy) -> some View {
        ZStack {
            // Drawing x-axis labels
            ForEach(Int(xRange.lowerBound)...Int(xRange.upperBound), id: \.self) { i in
                let x = CGFloat((Double(i) - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)) * geometry.size.width
                Text(String(i))
                    .font(.system(size: 8))
                    .position(x: x, y: geometry.size.height / 2)
            }
            // Drawing y-axis labels
            ForEach(Int(yRange.lowerBound)...Int(yRange.upperBound), id: \.self) { i in
                let y = geometry.size.height - CGFloat((Double(i) - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)) * geometry.size.height
                Text(String(i))
                    .font(.system(size: 8))
                    .position(x: geometry.size.width / 2, y: y)
            }
        }
    }
    
    private func drawSavedGraphs(geometry: GeometryProxy) -> some View {
        ForEach(savedGraphs, id: \.self) { graph in
            plotGraph(graph, geometry: geometry)
        }
    }
    
    private func drawCurrentGraph(geometry: GeometryProxy) -> some View {
        plotGraph(graphingPoints, geometry: geometry)
    }
    
    private func plotGraph(_ points: [Double: Double], geometry: GeometryProxy) -> some View {
        Path { path in
            let sortedPoints = points.sorted(by: { $0.key < $1.key })
            var startPointSet = false
            var previousY: Double? = nil
            var previousYJump: Double? = nil
            
            for index in sortedPoints.indices {
                let x = sortedPoints[index].key
                let y = sortedPoints[index].value
                
                if y.isNaN || !y.isFinite{
                    startPointSet = false
                    previousY = 0.0
                    previousYJump = 0.0
                    continue
                }
                
                // Check for a large jump at the beginning
                if index == 1, let prevY = previousY, abs(y - prevY) > yJumpThreshold {
                    startPointSet = false
                    previousY = y
                    previousYJump = 0.0
                    continue
                }
                
                if let prevY = previousY {
                    let yJump = abs(y - prevY)
                    
                    if let prevYJump = previousYJump, abs(yJump - prevYJump) > yJumpThreshold {
                        startPointSet = false
                        previousY = y
                        previousYJump = yJump
                        continue
                    }
                    
                    previousYJump = yJump
                }
                
                let screenX = CGFloat((x - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)) * geometry.size.width
                let screenY = geometry.size.height - CGFloat((y - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)) * geometry.size.height
                
                if !startPointSet {
                    path.move(to: CGPoint(x: screenX, y: screenY))
                    startPointSet = true
                } else {
                    path.addLine(to: CGPoint(x: screenX, y: screenY))
                }
                previousY = y
            }
        }
        .stroke(Color.red, lineWidth: 2)
        .frame(width: geometry.size.width, height: geometry.size.height)
        .clipped()
    }
}
