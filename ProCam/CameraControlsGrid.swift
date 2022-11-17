//
//  CameraControlsGrid.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

struct CameraControlsGrid: View {
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 40, height: 6)
                .foregroundColor(.gray)
                .offset(y: 88)
            
            LazyVGrid(columns: [GridItem].init(repeating: GridItem(.flexible()), count: 5)) {
                histogramButton
                flashlightButton
                Spacer()
                gridOverlayButton
                Spacer()
                switchFrontRearCameraButton
                heicRawButton
                timerButton
                whiteBalanceButton
                settingsButton
            }
            .padding()
            .offset(y: 77)
        }
    }
    
    var histogramButton: some View {
        Button {
            #warning("Toggle histogram visibility")
        } label: {
            Image(systemName: "waveform")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .aspectRatio(contentMode: .fit)
                .frame(height: 20, alignment: .top)
                .clipped()
                .foregroundColor(.white)
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Show histogram.")
    }
    
    var flashlightButton: some View {
        Button {
            #warning("Toggle flashlight")
        } label: {
            Image(systemName: "bolt.slash.fill")
                .scaledToFit()
                .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.white)
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Turn on flashlight.")
    }
    
    var gridOverlayButton: some View {
        Button {
            #warning("Toggle grid visibility")
        } label: {
            Image(systemName: "grid")
                .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                }
                
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Show overlay grid.")
    }
    
    var switchFrontRearCameraButton: some View {
        Button {
            #warning("Switch between front and rear cameras")
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 50))
                
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Switch to front camera.")
    }
    
    var heicRawButton: some View {
        Button {
            #warning("Switch between HEIC and RAW formats")
        } label: {
            Text("HEIC")
                .font(.caption)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                }
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Switch from HEIC to RAW format.")
    }
    
    var timerButton: some View {
        Button {
            #warning("Show timer settings")
        } label: {
            Image(systemName: "timer")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Change timer settings.")
    }
    
    var whiteBalanceButton: some View {
        Button {
            #warning("Show white balance modes")
        } label: {
            Text("AWB")
                .foregroundColor(.white)
                
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Change white balance modes.")
    }
    
    var settingsButton: some View {
        Button {
            #warning("Show app settings")
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                
        }
        .padding()
        .frame(height: 56, alignment: .center)
        .accessibilityLabel("Show ap settings.")
    }
}

struct CameraControlsGrid_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsGrid()
            .preferredColorScheme(.dark)
    }
}
