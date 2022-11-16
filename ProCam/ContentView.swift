//
//  ContentView.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            cameraPreview
        }
        .ignoresSafeArea()
    }
    
    #warning("Show camera preview")
    var cameraPreview: some View {
        Rectangle()
            .foregroundColor(.cyan.opacity(0.2))
            .overlay {
                Circle().stroke()
                    .foregroundColor(.gray)
                    .frame(width: 32, height: 32)
            }
    }
    
    var autoManualFocusButton: some View {
        Button {
            #warning("Toggle Auto/Manual Focus")
        } label: {
            Text("AF")
                .padding(10)
                .foregroundColor(.yellow)
                .background {
                    CircleBackground(color: .yellow)
                }
        }
        .padding()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
