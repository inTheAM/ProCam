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
    @EnvironmentObject var hapticFeedback: HapticFeedback
    @EnvironmentObject var camera: Camera
    
    @State private var isShowingTimerSettings = false
    
    @State private var isShowingWhiteBalanceSettings = false
    
    var body: some View {
        TabView {
                if isShowingTimerSettings {
                    HStack {
                        timerSettings
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale))
                    }
                } else if isShowingWhiteBalanceSettings {
                    HStack {
                        whiteBalanceSettings
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale))
                    }
                } else {
                    HStack {
                        switchFrontRearCameraButton
                        Spacer()
                        gridOverlayButton
                        Spacer()
                        flashlightButton
                        Spacer()
                        timerButton
                        Spacer()
                        whiteBalanceButton
                    }
                    .transition(.scale)
                    .padding()
                    
                    HStack  {
                        heicRawButton
                        Spacer()
                        histogramButton
                        Spacer()
                        settingsButton
                        Spacer()
                        Spacer()
                    }
                    .transition(.scale)
                    .padding()
                }
        }
        .frame(height: 48)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.default, value: isShowingTimerSettings)
        .animation(.default, value: isShowingWhiteBalanceSettings)
        
    }
}

extension CameraControlsGrid {
    
    // MARK: - Grid Elements
    
    /// A button that toggles the histogram visibility.
    var histogramButton: some View {
        Button {
            #warning("Toggle histogram visibility")
        } label: {
            Image(systemName: "waveform")
                // Sets image font and design.
                .scaledToFill()
                .font(.system(size: 28, weight: .light, design: .monospaced))
                // Sets frame height and aligns the image to the top of the frame.
                .frame(height: 20, alignment: .top)
                // Clips the image to only show content inside the frame.
                .clipped()
                .foregroundColor(.white)
        }
        .accessibilityLabel("Show histogram.")
    }
    
    /// A button that toggles the flash.
    var flashlightButton: some View {
        Button {
            camera.toggleFlashMode()
        } label: {
            Image(systemName: camera.flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 20, weight: .ultraLight, design: .monospaced))
                .foregroundColor(camera.flashMode == .on ? .yellow : .white)
        }
        .accessibilityLabel("Turn on flashlight.")
    }
    
    /// A button that toggles the visibility of the grid overlay on the camera preview.
    var gridOverlayButton: some View {
        Button {
            camera.toggleGrid()
        } label: {
            Image(systemName: "grid")
                .font(.system(size: 20, weight: .ultraLight, design: .monospaced))
                .foregroundColor((camera.isShowingGrid ? Color.yellow : .white).opacity(0.4))
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 2)
                        .foregroundColor(camera.isShowingGrid ? .yellow : .white)
                }
        }
        .accessibilityLabel("Show overlay grid.")
    }
    
    /// A button that switches between the front and rear cameras.
    var switchFrontRearCameraButton: some View {
        Button {
            camera.flipCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 50))
        }
        .accessibilityLabel("Switch to front camera.")
    }
    
    /// A button that switches between HEIC and RAW photo modes.
    var heicRawButton: some View {
        Button {
            #warning("Switch between HEIC and RAW formats")
        } label: {
            Text("HEIC")
                .font(.system(size: 8, weight: .light))
                .fixedSize()
                .foregroundColor(.white)
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                }
        }
        .accessibilityLabel("Switch from HEIC to RAW format.")
    }
    
    // MARK: Timer settings
    /// A button that shows the timer settings.
    var timerButton: some View {
        Button {
            isShowingTimerSettings = true
        } label: {
            Image(systemName: "timer")
                .font(.system(size: 24, weight: .light, design: .monospaced))
                .foregroundColor(.white)
                
        }
        .accessibilityLabel("Change timer settings.")
    }
    
    var timerSettings: some View {
        Group {
            Text("TIMER")
                .font(.caption)
                .foregroundColor(.gray)
            Button {
                #warning("Set timer off")
                isShowingTimerSettings = false
            } label: {
                Text("OFF")
                    .fixedSize()
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Turn off capture timer.")
            
            Button {
                #warning("Set timer to 3s")
                isShowingTimerSettings = false
            } label: {
                Image("Timer")
                    .renderingMode(.template)
                    .resizedToFit()
                    .frame(width: 28)
                    .overlay {
                        Text("3")
                            .font(.caption)
                    }
                    .tint(.white)
            }
            .accessibilityLabel("Set timer to 3s.")
            
            Button {
                #warning("Set timer to 10s")
                isShowingTimerSettings = false
            } label: {
                Image("Timer")
                    .renderingMode(.template)
                    .resizedToFit()
                    .frame(width: 28)
                    .overlay {
                        Text("10")
                            .font(.caption)
                    }
                    .tint(.white)
            }
            .accessibilityLabel("Set timer to 10s.")
            
            Button {
                #warning("Set timer to 30s")
                isShowingTimerSettings = false
            } label: {
                Image("Timer")
                    .renderingMode(.template)
                    .resizedToFit()
                    .frame(width: 28)
                    .overlay {
                        Text("30")
                            .font(.caption)
                    }
                    .tint(.white)
            }
            .accessibilityLabel("Set timer to 30s.")
        }
    }
    
    // MARK: - White balance settings
    /// A button that shows white balance options.
    var whiteBalanceButton: some View {
        Button {
            isShowingWhiteBalanceSettings = true
        } label: {
            Text("AWB")
                .font(.caption)
                .fixedSize()
                .foregroundColor(.white)
        }
        .accessibilityLabel("Change white balance modes.")
    }
        
    var whiteBalanceSettings: some View {
        Group {
            Text("WHITE BALANCE")
                .foregroundColor(.gray)
                .font(.caption)
            Button {
                #warning("Set white balance auto")
                isShowingWhiteBalanceSettings = false
            } label: {
                Text("AWB")
                    .fixedSize()
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Turn on auto white balance.")
            
            Button {
                #warning("Set white balance")
                isShowingWhiteBalanceSettings = false
            } label: {
                Image(systemName: "cloud")
                    .renderingMode(.template)
                    .resizedToFit()
                    .frame(width: 32)
                    .tint(.white)
            }
            .accessibilityLabel("Set timer to 3s.")
            
            Button {
                #warning("Set white balance")
                isShowingWhiteBalanceSettings = false
            } label: {
                Image(systemName: "sun.max")
                    .renderingMode(.template)
                    .resizedToFit()
                    .frame(width: 32)
                    .tint(.white)
            }
            .accessibilityLabel("Set timer to 10s.")
            
            Button {
                #warning("Set white balance")
                isShowingWhiteBalanceSettings = false
            } label: {
                Image("Light")
                    .resizable()
                    .frame(width: 28, height: 30)
                    .tint(.white)
            }
            .accessibilityLabel("Set timer to 30s.")
        }
    }
    
    /// A button that brings up the settings modal view.
    var settingsButton: some View {
        Button {
            #warning("Show app settings")
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 20, weight: .light, design: .monospaced))
                .foregroundColor(.white)
        }
        .accessibilityLabel("Show ap settings.")
    }
}

struct CameraControlsGrid_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsGrid()
            .preferredColorScheme(.dark)
    }
}
