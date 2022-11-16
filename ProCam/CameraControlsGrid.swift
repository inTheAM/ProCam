//
//  CameraControlsGrid.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

struct CameraControlsGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem].init(repeating: GridItem(.flexible()), count: 5)) {
            histogramButton
        }
        .padding()
    }
    
    var histogramButton: some View {
        Button {
            #warning("Toggle histogram visibility")
        } label: {
            Image(systemName: "waveform")
                .font(.system(size: 40, weight: .light, design: .monospaced))
                .frame(height: 24, alignment: .top)
                .clipped()
                .foregroundColor(.white)
        }
    }
}

struct CameraControlsGrid_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsGrid()
            .preferredColorScheme(.dark)
    }
}
