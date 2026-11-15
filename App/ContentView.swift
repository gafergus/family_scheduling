import FamilyCore
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    Text("Nothing scheduled yet.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Today")
        }
    }
}

#Preview {
    ContentView()
}
