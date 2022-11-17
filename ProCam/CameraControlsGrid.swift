//
//  CameraControlsGrid.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

/// The grid of controls over the camera.
/// Implemented as a Vertical Stack containing the drag indicator and the grid of controls.
/// The grid of controls is initally offset downards so that only the top row is visible in the camera preview
struct CameraControlsGrid: View {
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 40, height: 6)
                .foregroundColor(.gray)
                .offset(y: 16)
            
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
        }
        .padding()
        .offset(y: 88)
    }
    
    // MARK: - Grid Elements
    
    /// A button that toggles the histogram visibility.
    var histogramButton: some View {
        Button {
            #warning("Toggle histogram visibility")
        } label: {
            Image(systemName: "waveform")
                // Sets image font and design.
                .font(.system(size: 32, weight: .light, design: .monospaced))
                // Sets frame height and aligns the image to the top of the frame.
                .frame(height: 20, alignment: .top)
                // Clips the image to only show content inside the frame.
                .clipped()
                .foregroundColor(.white)
        }
        .padding()
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Show histogram.")
    }
    
    /// A button that toggles the flash.
    var flashlightButton: some View {
        Button {
            #warning("Toggle flashlight")
        } label: {
            Image(systemName: "bolt.slash.fill")
                .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding()
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Turn on flashlight.")
    }
    
    /// A button that toggles the visibility of the grid overlay on the camera preview.
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
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Show overlay grid.")
    }
    
    /// A button that switches between the front and rear cameras.
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
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Switch to front camera.")
    }
    
    /// A button that switches between HEIC and RAW photo modes.
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
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Switch from HEIC to RAW format.")
    }
    
    /// A button that shows the timer settings.
    var timerButton: some View {
        Button {
            #warning("Show timer settings")
        } label: {
            Image(systemName: "timer")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                
        }
        .padding()
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Change timer settings.")
    }
    
    /// A button that shows white balance options.
    var whiteBalanceButton: some View {
        Button {
            #warning("Show white balance modes")
        } label: {
            Text("AWB")
                .foregroundColor(.white)
                
        }
        .padding()
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Change white balance modes.")
    }
    
    /// A button that brings up the settings modal view.
    var settingsButton: some View {
        Button {
            #warning("Show app settings")
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                
        }
        .padding()
        .frame(height: 72, alignment: .center)
        .accessibilityLabel("Show ap settings.")
    }
}

struct CameraControlsGrid_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsGrid()
            .preferredColorScheme(.dark)
    }
}
