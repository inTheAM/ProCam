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
    @State private var isInManualfocus = false
    @State private var isShowingAutoManualSelection = false
    @State private var focusAmount = 0.0
    var body: some View {
        VStack(spacing: 0) {
            // The histogram view and button to toggle between auto/manual modes.
            HStack {
                histogram
                
                Spacer()
                
                autoManualModeButton
            }
            .padding()
            
            // The camera preview and bottom controls background,
            // with the controls overlaid in a `ZStack`.
            ZStack(alignment: .bottom) {
                VStack {
                    CameraPreview()
                        .overlay {
                            balanceIndicator
                        }
                        .overlay(alignment: .trailing) {
                            if isShowingAutoManualSelection {
                                VStack(alignment: .trailing) {
                                    VStack {
                                        autoButton
                                        manualButton
                                    }
                                    .background(Color.black.opacity(0.5).cornerRadius(28))
                                    
                                    zebrasButton
                                        .background(Color.black.opacity(0.5).cornerRadius(28))
                                        .padding(.vertical)
                                    Spacer()
                                }
                                .padding(8)
                                .padding(.top)
                                .zIndex(1)
                                .transition(.move(edge: .trailing))
                            }
                        }
                        .animation(.default, value: isShowingAutoManualSelection)
                    
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 272)
                }
                VStack {
                    Spacer()
                    CameraControlsGrid()
                        .padding(.bottom, isInManualfocus ? 232 : 208)
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    Divider()
                    
                    VStack {
                        if isInManualfocus {
                            
                            ZStack(alignment: .bottom) {
                                VStack {
                                    HStack {
                                        focusPeakingButton
                                        
                                        Spacer()
                                        
                                        portraitModeButton
                                            .matchedGeometryEffect(id: "portraitmode", in: namespace)
                                        focusLoupeButton
                                    }
                                    HStack {
                                        Spacer()
                                    }
                                    HStack {
                                        macroModeButton
                                        Spacer()
                                        autoManualFocusButton
                                            .matchedGeometryEffect(id: "automanualfocus", in: namespace)
                                    }
                                }
                                .padding(.bottom, 10)
                                .zIndex(2)
                                
                                SegmentedSlider(value: $focusAmount, lowerBound: 0, upperBound: 1, strideLength: 0.02)
                                    .zIndex(1)
                                
                            }
                            .padding(.horizontal, 8)
                        } else {
                            
                            HStack {
                                Spacer()
                            }
                            
                            // The Autofocus button and Portrait mode button
                            HStack {
                                
                                autoManualFocusButton
                                    .matchedGeometryEffect(id: "automanualfocus", in: namespace)
                                
                                Spacer(minLength: 0)
                                
                                portraitModeButton
                                    .matchedGeometryEffect(id: "portraitmode", in: namespace)
                            }
                            .padding([.horizontal, .top], 8)
                        }
                        // The last image in the user's library,
                        // capture button and
                        // button for switching between the different rear cameras.
                        HStack(alignment: .bottom) {
                            lastImageInLibrary
                            
                            Spacer()
                            
                            capturePhotoButton
                            
                            Spacer()
                            
                            switchBetweenRearCamerasButton
                        }
                    }
                    .background {
                        Color.white.opacity(0.05)
                            .background(Color.black)
                    }
                }
            }
            .animation(.default, value: isInManualfocus)
        }
        .ignoresSafeArea()
        .environmentObject(camera)
        .task {
            await camera.start()
        }
    }
}

extension ContentView {
#warning("Show camera preview")
    /// The preview of what the camera sees.
    struct CameraPreview: View {
        @EnvironmentObject var camera: Camera
        var body: some View {
            if let image = camera.preview {
                image
                    .scaledToFit()
                    .accessibilityLabel("Camera preview.")
            } else {
                Rectangle()
                    .foregroundColor(.cyan.opacity(0.2))
            }
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
        } label: {
            VStack {
                Image("AFTriangle")
                    .renderingMode(.template)
                    .resizable()
                    .padding(12)
                    .background(Circle().stroke(lineWidth: 2))
                    .frame(width: 44, height: 44)
                Text("AUTO")
                    .font(.system(size: 14))
            }
            .tint(.yellow)
        }
        .padding()
        .accessibilityLabel("Switch to Auto mode.")
    }
    
    /// The button to toggle manual mode.
    var manualButton: some View {
        Button {
            #warning("Toggle manual mode")
        } label: {
            VStack {
                Text("M")
                    .font(.title3.monospaced())
                    .padding()
                    .background(Circle().stroke(lineWidth: 2).foregroundColor(.gray))
                    .frame(width: 56, height: 56)
                Text("MANUAL")
                    .font(.system(size: 14))
                
            }
            .foregroundColor(.white)
        }
        .padding()
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
            #warning("Toggle Auto/Manual Focus")
            isInManualfocus.toggle()
        } label: {
            Text("AF")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(isInManualfocus ? .white : .yellow)
                .background {
                    CircleBackground(color: isInManualfocus ? .gray : .yellow)
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
    
#warning("Show last image in library")
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
            Text("1x")
                .padding(10)
                .background {
                    Circle().stroke(lineWidth: 2)
                }
                .foregroundColor(.white)
            
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 32)
        .accessibilityLabel("Switch between rear cameras. Currently at 1x")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
