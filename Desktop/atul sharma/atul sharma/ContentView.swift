//
//  ContentView.swift
//  atul sharma
//
//  Created by students on 11/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
          
            Text("Welcome")
                .bold()
                .padding(30)
                .foregroundStyle(.blue)
            
                .font(.system(size: 50))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
