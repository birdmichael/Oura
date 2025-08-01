//
//  ContentView.swift
//  Oura
//
//  Created by BM on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingShuffle = false
    
    var body: some View {
        NavigationView {
            VStack {
                CardDrawingView()
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            showingShuffle = true
                        }) {
                            Image(systemName: "shuffle")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
            }
        }
        .sheet(isPresented: $showingShuffle) {
            CardShuffleView()
        }
    }
}

#Preview {
    ContentView()
}
