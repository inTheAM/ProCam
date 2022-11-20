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
    /// The vertical offset for the view.
    /// Initialized at 68 to offset the view downwards.
    @State private var offset: CGFloat = 68
    
    /// Detects when the state of the application changes eg when the user moves it to the background, the app becomes inactive or the user switches back to the app.
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var hapticFeedback: HapticFeedback
    
    @State private var isShowingTimerSettings = false
    
    @State private var isShowingWhiteBalanceSettings = false
    
    var body: some View {
        VStack(spacing: 4) {
            dragIndicator
            
            LazyVGrid(columns: [GridItem].init(repeating: GridItem(.flexible()), count: 5), spacing: 40) {
                histogramButton
                Spacer()
                flashlightButton
                Spacer()
                gridOverlayButton
                if isShowingTimerSettings {
                    timerSettings
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale))
                } else if isShowingWhiteBalanceSettings {
                    whiteBalanceSettings
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale))
                } else {
                    Group {
                        switchFrontRearCameraButton
                        heicRawButton
                        timerButton
                        whiteBalanceButton
                        settingsButton
                    }
                    .transition(.scale)
                }
            }
            .padding(.vertical)
            .animation(.default, value: isShowingTimerSettings)
            .animation(.default, value: isShowingWhiteBalanceSettings)
        }
        .padding(.horizontal)
        .background {
            LinearGradient(colors: [.clear, .black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
        }
        // Simultaneous Gesture is used to attach gestures to views which already have a gesture attached.
        // For example, the grid elements are buttons, which already recognize tap gestures.
        // To attach a drag gesture to the buttons, `.simultaneousGesture` is preferred to `.gesture`
        .simultaneousGesture(
            
            // Declare a drag gesture with a minimum distance.
            // A minimum distance of 0 means taps will also be recognized.
            DragGesture(minimumDistance: 10)
            // When the user drags on the screen, the changes are received here.
                .onChanged { value in
                    // The distance the drag gesture has covered thus far
                    let distance = value.translation.height * 0.5
                    
                    // Setting the allowed distance for which the drag gesture will be used to perform an action, eg offsetting a view.
                    let allowedDistance = max(min(distance, 68), 0)
                    
                    // Assigning the allowable distance to the view offset
                    offset = allowedDistance
                    
                }
            // When the drag gesture is over, we receive data about the entire drag here.
                .onEnded { value in
                    // If the current offset is above 20, offset the view down to 68
                    if offset < 20 {
                        offset = 0
                        hapticFeedback.playTick(isEmphasized: true)
                        // If the current offset is less than 20, offset the view up to 0
                    } else {
                        offset = 68
                        isShowingWhiteBalanceSettings = false
                        isShowingTimerSettings = false
                        hapticFeedback.playTick(isEmphasized: true)
                    }
                }
        )
        .animation(.default, value: offset)
        .offset(y: offset)
        // Detect when the application goes to the background or becomes inactive and reset the offset
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background || newScenePhase == .inactive {
                offset = 68
            }
        }
    }
}

extension CameraControlsGrid {
    
    // MARK: - Drag Indicator
    
    /// The drag indicator
    var dragIndicator: some View {
        HStack(spacing: -4) {
            RoundedRectangle(cornerRadius: 4)
                .frame( height: 4)
                .foregroundColor(.gray)
                .rotationEffect(dragIndicatorAngle)
            RoundedRectangle(cornerRadius: 4)
                .frame( height: 4)
                .foregroundColor(.gray)
                .rotationEffect(-dragIndicatorAngle)
        }
        .frame(width: 32)
    }
    
    /// The angle by which the rectangle should be rotated by the view.
    var dragIndicatorAngle: Angle {
        // Calculate the distance between the current position and the maximum offset for the view ie 68
        let currentOffset = 68 - offset
        
        // Use the calculated distance to calclate the angle between 0 and 30 degrees the rectangle should be rotated to
        let angle = currentOffset/68 * 20
        
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
            #warning("Toggle flashlight")
        } label: {
            Image(systemName: "bolt.slash.fill")
                .font(.system(size: 20, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white)
        }
        .accessibilityLabel("Turn on flashlight.")
    }
    
    /// A button that toggles the visibility of the grid overlay on the camera preview.
    var gridOverlayButton: some View {
        Button {
            #warning("Toggle grid visibility")
        } label: {
            Image(systemName: "grid")
                .font(.system(size: 20, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                }
        }
        .accessibilityLabel("Show overlay grid.")
    }
    
    /// A button that switches between the front and rear cameras.
    var switchFrontRearCameraButton: some View {
        Button {
            #warning("Switch between front and rear cameras")
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
            #warning("Show timer settings")
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
            #warning("Show white balance modes")
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
