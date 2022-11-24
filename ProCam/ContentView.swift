//
//  ContentView.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var namespace
    @StateObject private var camera = Camera()
    @StateObject private var hapticFeedback = HapticFeedback.shared
    @State private var isShowingAutoManualSelection = false
    var body: some View {
        VStack(spacing: 0) {
            // The histogram view and button to toggle between auto/manual modes.
            HStack {
                histogram
                
                Spacer()
                
                autoManualModeButton
            }
            .opacity(0)
            .padding()
            
            // The camera preview and bottom controls background,
            // with the controls overlaid in a `ZStack`.
            
            VStack(spacing: 0) {
                cameraPreview
                    .overlay {
                        balanceIndicator
                    }
                    .overlay {
                        if camera.isShowingGrid {
                            grid
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if camera.isInManualfocus {
                            SegmentedSlider(value: $camera.focusAmount, lowerBound: 0, upperBound: 1, strideLength: 0.02)
                                .padding(.bottom)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        switchBetweenRearCamerasButton
                            .background {
                                Color.black.opacity(0.3)
                                    .clipShape(Circle())
                            }
                            .padding()
                    }
                    .overlay(alignment: .topTrailing) {
                                HStack {
                                    if camera.cameraMode == .auto  {
                                        autoButton
                                    } else {
                                        manualButton
                                    }
                                }
                                .background(Color.black.opacity(0.2).cornerRadius(16))
                                .padding()
                        
                    }
                    .animation(.default, value: isShowingAutoManualSelection)
                
                VStack {
                CameraControlsGrid()
                
                Divider()
                    if camera.isInManualfocus {
                        ZStack {
                            VStack {
                                HStack {
                                    focusPeakingButton
                                    
                                    Spacer()
                                    
                                    portraitModeButton
                                        .matchedGeometryEffect(id: "portraitmode", in: namespace)
                                    focusLoupeButton
                                }
                                HStack {
                                    macroModeButton
                                    Spacer()
                                    autoManualFocusButton
                                        .matchedGeometryEffect(id: "automanualfocus", in: namespace)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 8)
                    } else {
                        
                        // The Autofocus button and Portrait mode button
                        HStack {
                            if camera.supportsManualFocus {
                                autoManualFocusButton
                                    .transition(.scale)
                                    .matchedGeometryEffect(id: "automanualfocus", in: namespace)
                            }
                            Spacer(minLength: 0)
                            
                            portraitModeButton
                                .matchedGeometryEffect(id: "portraitmode", in: namespace)
                        }
                        .padding([.horizontal], 8)
                    }
                    // The last image in the user's library,
                    // capture button and
                    // button for switching between the different rear cameras.
                    
                    HStack(alignment: .bottom) {
                        lastImageInLibrary
                        
                        Spacer()
                    }
                }
                
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            capturePhotoButton
        }
        .animation(.default, value: camera.isInManualfocus)
        .environmentObject(camera)
        .environmentObject(hapticFeedback)
        .task {
            await camera.start()
        }
    }
}

extension ContentView {
    
    /// The preview of what the camera sees.
    @ViewBuilder var cameraPreview: some View {
        if let image = camera.preview {
            image
                .scaledToFit()
                .accessibilityLabel("Camera preview.")
        } else {
            Rectangle()
                .foregroundColor(.black)
        }
    }
    
    var grid: some View {
        ZStack {
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 1)
                Spacer()
                Rectangle()
                    .frame(width: 1)
                Spacer()
            }
            .opacity(0.5)
            
            VStack {
                Spacer()
                Rectangle()
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .frame(height: 1)
                Spacer()
            }
            .opacity(0.5)
        }
    }
    
    #warning("Show histogram")
    /// The histogram view.
    var histogram: some View {
        Text("Histogram")
            .font(.caption)
    }
    
    /// The button to toggle between auto and manual camera modes.
    var autoManualModeButton: some View {
        Button {
            #warning("Toggle Auto/Manual mode")
            isShowingAutoManualSelection.toggle()
        } label: {
            Image("AFTriangle")
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 12)
                .tint(.gray)
        }
        .padding(.trailing)
        .accessibilityLabel("Show menu to switch between auto and manual modes.")
    }
    
    /// The button to toggle auto mode.
    var autoButton: some View {
        Button {
            #warning("Toggle auto mode")
            camera.cameraMode = .manual
        } label: {
            Text("AUTO")
                .font(.system(size: 14))
                .tint(.yellow.opacity(0.6))
        }
        .padding(8)
        .accessibilityLabel("Switch to Auto mode.")
    }
    
    /// The button to toggle manual mode.
    var manualButton: some View {
        Button {
            #warning("Toggle manual mode")
            camera.cameraMode = .auto
        } label: {
                Text("MANUAL")
                    .font(.system(size: 14))
                    .tint(.yellow.opacity(0.6))
        }
        .padding(8)
        .accessibilityLabel("Switch to manual mode.")
    }
    
    /// The button to toggle showing zebras overlay
    var zebrasButton: some View {
        Button {
            #warning("Toggle zebras")
        } label: {
            VStack {
                Image(systemName: "line.3.horizontal.circle")
                    .font(.system(size: 24, weight: .light))
                    .rotationEffect(.init(degrees: -50))
                    .scaleEffect(2)
                    .clipShape(Circle())
                    .padding(4)
                    .background(Circle().stroke(lineWidth: 2))
                    .padding(4)
                    .background(Circle().stroke(lineWidth: 2))
                    .frame(width: 48, height: 48)
                Text("ZEBRAS")
                    .font(.system(size: 14))
            }
            .foregroundColor(.white)
        }
        .padding(18)
        .accessibilityLabel("Show zebras.")
    }
    
    
    
    /// The indicator for device position, either horizontal or vertical.
    var balanceIndicator: some View {
        Circle()
            .stroke()
            .foregroundColor(.gray)
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)
    }
    
    /// The button to toggle between autofocus and manual focus.
    var autoManualFocusButton: some View {
        Button {
            camera.toggleFocusMode()
        } label: {
            Text("AF")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(camera.isInManualfocus ? .white : .yellow)
                .background {
                    CircleBackground(color: camera.isInManualfocus ? .gray : .yellow)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Switch between autofocus and manual focus.")
    }
    
    /// The button to toggle focus peaking on or off.
    var focusPeakingButton: some View {
        Button {
            #warning("Toggle Focus Peaking")
        } label: {
            Image(systemName: "circle.dashed")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Turn on focus peaking.")
    }
    
    /// The button to toggle focus peaking on or off.
    var macroModeButton: some View {
        Button {
            #warning("Toggle Macro Mode")
        } label: {
            Image(systemName: "camera.macro")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Turn on macro mode.")
    }
    
    /// The button to toggle focus peaking on or off.
    var focusLoupeButton: some View {
        Button {
            #warning("Toggle focus loupe")
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Turn on focus loupe.")
    }
    
    /// The button to turn on or off Portrait Mode.
    var portraitModeButton: some View {
        Button {
            #warning("(De)Activate Portrait Mode")
        } label: {
            Image("PortraitMode")
                .renderingMode(.template)
                .resizedToFit()
                .frame(width: 16, height: 16)
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal, .vertical])
        .accessibilityLabel("Activate portrait mode.")
    }
    
    /// The preview of the last image in the user's photo library.
    var lastImageInLibrary: some View {
        Group {
            if let thumbnail = camera.thumbnailImage {
                thumbnail
                    .resizable()
                    .scaledToFill()
            } else {
                Spacer()
            }
        }
        .frame(width: 96, height: 96)
        .clipped()
        .cornerRadius(8)
        .padding(.horizontal, 8)
        .accessibilityLabel("Show last photo taken.")
    }
    
    /// The button to capture the photo.
    var capturePhotoButton: some View {
        Button {
            camera.capture()
            hapticFeedback.playTick(isEmphasized: true)
        } label: {
            LinearGradient(colors: [.gray.opacity(0.7), .white], startPoint: .top, endPoint: .bottom)
                .clipShape(Circle())
                .background {
                    Circle().foregroundColor(.white)
                }
                .padding(4)
                .frame(width: 80, height: 80)
                .background {
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(.white)
                }
        }
        .padding([.horizontal, .bottom], 32)
        .accessibilityLabel("Capture photo.")
    }
    
    /// The button to switch between the different rear cameras.
    var switchBetweenRearCamerasButton: some View {
        Button {
            camera.switchRearCamera()
        } label: {
            Text(camera.currentLens)
                .font(.caption)
                .fixedSize()
                .padding(8)
                .background {
                    Circle().stroke(lineWidth: 2)
                }
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
        .padding(8)
        .accessibilityLabel("Switch between rear cameras. Currently at 1x")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
