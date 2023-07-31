import Foundation
import SwiftUI

struct DocsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("""
                logb(x,b)
                x = value
                b = base
                
                root(x,n)
                nth-root of x
                """)
            }
        }
        .padding()
        .cornerRadius(10)
    }
}
