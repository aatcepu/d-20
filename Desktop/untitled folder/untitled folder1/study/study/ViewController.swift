import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button {
                print("Welcome to SwiftUI")
            } label: {
                Text("Login")
                    .foregroundColor(.green)
                    .fontWeight(.heavy)
                    .frame(width: 150, height: 150)
                    .background(.blue)
                    .cornerRadius(30)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
