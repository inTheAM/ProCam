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
    @State private var offset: CGFloat = 88
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: -6) {
                RoundedRectangle(cornerRadius: 4)
                    .frame( height: 6)
                    .foregroundColor(.gray)
                    .rotationEffect(dragIndicatorAngle)
                RoundedRectangle(cornerRadius: 4)
                    .frame( height: 6)
                    .foregroundColor(.gray)
                    .rotationEffect(-dragIndicatorAngle)
            }
            .frame(width: 40)
            
            LazyVGrid(columns: [GridItem].init(repeating: GridItem(.flexible()), count: 5)) {
                histogramButton
                Spacer()
                flashlightButton
                Spacer()
                gridOverlayButton
                switchFrontRearCameraButton
                heicRawButton
                timerButton
                whiteBalanceButton
                settingsButton
            }
        }
        .padding()
        .offset(y: offset)
        .animation(.default, value: offset)
    }
    
    /// The angle by which the rectangle should be rotated by the view.
    var dragIndicatorAngle: Angle {
        // Calculate the distance between the current position and the maximum offset for the view ie 88
        let currentOffset = 88 - offset
        
        // Use the calculated distance to calclate the angle between 0 and 30 degrees the rectangle should be rotated to
        let angle = currentOffset/88 * 20
        
        // Return the calculated angle
        return Angle(degrees: angle)
    }
    
    // MARK: - Grid Elements
    
    /// A button that toggles the histogram visibility.
    var histogramButton: some View {
        Button {
            #warning("Toggle histogram visibility")
        } label: {
            Image(systemName: "waveform")
                // Sets image font and design.
                .font(.system(size: 28, weight: .light, design: .monospaced))
                // Sets frame height and aligns the image to the top of the frame.
                .frame(height: 20, alignment: .top)
                // Clips the image to only show content inside the frame.
                .clipped()
                .foregroundColor(.white)
        }
        .padding()
        .accessibilityLabel("Show histogram.")
    }
    
    /// A button that toggles the flash.
    var flashlightButton: some View {
        Button {
            #warning("Toggle flashlight")
        } label: {
            Image(systemName: "bolt.slash.fill")
                .font(.system(size: 28, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding()
        .accessibilityLabel("Turn on flashlight.")
    }
    
    /// A button that toggles the visibility of the grid overlay on the camera preview.
    var gridOverlayButton: some View {
        Button {
            #warning("Toggle grid visibility")
        } label: {
            Image(systemName: "grid")
                .font(.system(size: 28, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                }
        }
        .padding()
        .accessibilityLabel("Show overlay grid.")
    }
    
    /// A button that switches between the front and rear cameras.
    var switchFrontRearCameraButton: some View {
        Button {
            #warning("Switch between front and rear cameras")
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 28, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 50))
        }
        .padding()
        .accessibilityLabel("Switch to front camera.")
    }
    
    /// A button that switches between HEIC and RAW photo modes.
    var heicRawButton: some View {
        Button {
            #warning("Switch between HEIC and RAW formats")
        } label: {
            Text("HEIC")
                .font(.caption)
                .fixedSize()
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                }
        }
        .padding()
        .accessibilityLabel("Switch from HEIC to RAW format.")
    }
    
    /// A button that shows the timer settings.
    var timerButton: some View {
        Button {
            #warning("Show timer settings")
        } label: {
            Image(systemName: "timer")
                .font(.system(size: 28, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                
        }
        .padding()
        .accessibilityLabel("Change timer settings.")
    }
    
    /// A button that shows white balance options.
    var whiteBalanceButton: some View {
        Button {
            #warning("Show white balance modes")
        } label: {
            Text("AWB")
                .fixedSize()
                .foregroundColor(.white)
        }
        .padding()
        .accessibilityLabel("Change white balance modes.")
    }
    
    /// A button that brings up the settings modal view.
    var settingsButton: some View {
        Button {
            #warning("Show app settings")
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 28, weight: .light, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding()
        .accessibilityLabel("Show ap settings.")
    }
}

struct CameraControlsGrid_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsGrid()
            .preferredColorScheme(.dark)
    }
}
