//
//  ContentView.swift
//  Oura
//
//  Created by BM on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            CardDrawingView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
