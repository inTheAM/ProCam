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
                #warning("Show camera preview")
                Rectangle()
                    .foregroundColor(.cyan.opacity(0.2))
                    .overlay {
                        Circle().stroke()
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                    }
        }
        .ignoresSafeArea()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
