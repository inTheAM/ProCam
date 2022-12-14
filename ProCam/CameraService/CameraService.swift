//
//  CameraService.swift
//  ProCam
//
//  Created by Ahmed Mgua on 20/11/22.
//

import AVFoundation
import Combine
import CoreGraphics
import VideoToolbox
import CoreImage
import UIKit

final class CameraService: NSObject {
    /// The active capture session
    private let captureSession = AVCaptureSession()
    
    /// The photo capture output
    private var photoOutput = AVCapturePhotoOutput()
    
    /// The video data output
    private var videoOutput = AVCaptureVideoDataOutput()
    
    /// Tracks whether the capture session has been configured.
    private var isCaptureSessionConfigured = false
    
    /// The active device input for the capture session.
    private var deviceInput: AVCaptureDeviceInput?
    
    /// All capture devices on the device.
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera], mediaType: .video, position: .unspecified).devices
    }
    private var multiLensDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera],  mediaType: .video, position: .unspecified).devices
    }
    
    /// Front capture devices
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }
    
    /// Rear capture devices
    private var rearCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    /// The active capture device.
    /// On assignment, the capture session is updated for the new device.
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    private var focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
    
    /// Tracks whether the capture session is running
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    var supportsManualFocus: Bool {
        captureDevice?.isLockingFocusWithCustomLensPositionSupported ?? false
    }
    
    /// Tracks whether the current capture device is a front device.
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    /// Tracks whether the current capture device is a rear device.
    var isUsingRearCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return rearCaptureDevices.contains(captureDevice)
    }
    /// A method to add input frames to the preview stream for previewing.
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    /// A method to add captured photos to the user's library.
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    /// Tracks whether the preview is on or paused.
    var isPreviewPaused = false
    
    
    /// The stream of frames from the capture device, loaded asynchronously and returned as`CIImage`.
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    /// The stream of photos captured.
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    /// The DispatchQueue for the capture session.
    private let sessionQueue = DispatchQueue(label: "ProCam.SessionQueue")

    /// Initializes the capture device to the wide angle rear camera.
    override init() {
        super.init()
        captureDevice = rearCaptureDevices.first
    }
    
    
    typealias Lens = (label: String, zoomFactor: CGFloat)
    private var lenses = [Lens]()
    
    private(set) var currentLens = CurrentValueSubject<Lens?, Never>(nil)
    
    func updateLensOptions() {
        if let zoomFactors = multiLensDevices.first?.virtualDeviceSwitchOverVideoZoomFactors {
            if zoomFactors.isEmpty {
                lenses = [(label: "1", zoomFactor: 1)]
            } else {
                if captureDevice?.deviceType == .builtInDualCamera {
                    lenses = [(label: "1", zoomFactor: 1)]
                    let otherLenses = zoomFactors
                        .map { factor in
                            (label: "2", zoomFactor: CGFloat(factor.floatValue))
                        }
                    lenses.append(contentsOf: otherLenses)
                    
                } else {
                    lenses = [(label: "0.5", zoomFactor: 1)]
                    let otherLenses = zoomFactors
                        .map { factor in
                            (label: "\(factor.intValue/2)", zoomFactor: CGFloat(factor.floatValue))
                        }
                    lenses.append(contentsOf: otherLenses)
                }
            }
        }
    }
}

extension CameraService {
    /// Flips between front and rear cameras.
    func flipCaptureDevice() {
        if let captureDevice = captureDevice {
            if rearCaptureDevices.contains(captureDevice) {
                self.captureDevice = frontCaptureDevices.first
            } else {
                self.captureDevice = rearCaptureDevices.first
            }
        }
    }
    
    /// Switches between the available rear cameras.
    func switchRearCaptureDevice() {
        if let device = captureDevice,
           let deviceIndex = rearCaptureDevices.firstIndex(of: device),
           let lensIndex = lenses.firstIndex(where: { $0.label == currentLens.value?.label} ) {
            let nextDeviceIndex = (deviceIndex + 1) % rearCaptureDevices.count
            let nextLensIndex = (lensIndex + 1) % lenses.count
            self.captureDevice = rearCaptureDevices[nextDeviceIndex]
            currentLens.send(lenses[nextLensIndex])
        } else {
            self.captureDevice = rearCaptureDevices.first
        }
    }
    
    /// Sets the focus mode for the current device.
    /// Manual focus is only set for devices that support it.
    /// - Parameter mode: The focus mode to set the capture device to.
    func switchFocusMode(to mode: AVCaptureDevice.FocusMode) {
        // Make sure the focus mode is supported on the capture device.
        guard captureDevice?.isFocusModeSupported(mode) == true
        else { return }
        
        // lockForConfiguration is REQUIRED for exclusive access to the capture device's
        // configuration properties.
        try? captureDevice?.lockForConfiguration()
        
        // Set the capture device's focus mode to the passed in mode.
        captureDevice?.focusMode = mode
        
        // After performing changes, release the lock on the device's settings.
        captureDevice?.unlockForConfiguration()
        
    }
    
    /// Sets the lens position for manual focus if supported on the capture device.
    /// - Parameter position: The lens position to lock focus on.
    func setManualFocus(to position: Float) {
        // Make sure the capture device supports locked focus or exit.
        guard captureDevice?.isFocusModeSupported(.locked) == true
        else { return }
        try? captureDevice?.lockForConfiguration()
        captureDevice?.setFocusModeLocked(lensPosition: position)
        captureDevice?.unlockForConfiguration()
        
    }
    
    /// Configures the capture session, adding inputs and outputs for photos and video.
    func configureCaptureSession() throws {
        // Begin configuration
        captureSession.beginConfiguration()
        
        // Use `defer` to run code at the end of the function.
        // If configuration proceeds without errors, then commit.
        defer {
            captureSession.commitConfiguration()
        }
        
        // Check for the capture device
        guard let captureDevice = captureDevice
        else { return }
        
        // Check the input for the device.
        let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        
        // Create the photo output.
        let photoOutput = AVCapturePhotoOutput()
        // Set the capture session preset to `photo` which allows for hi res photo capture.
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        // Create the video output
        let videoOutput = AVCaptureVideoDataOutput()
        // Assign the video output delegate, which will handle the frames received from the capture device.
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "ProCam.VideoDataOutputQueue"))
  
        // Check if the capture session can add inputs and outputs.
        guard captureSession.canAddInput(deviceInput)
        else { return }
        guard captureSession.canAddOutput(photoOutput)
        else { return }
        guard captureSession.canAddOutput(videoOutput)
        else { return }
        
        // Add the device input, photo output and video output to the capture session.
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        // Assign the inputs and outputs.
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        // Update the video output connection to mirror output if using front camera.
        updateVideoOutputConnection()
        updateLensOptions()
        
        let lensToUse = lenses.first(where: { $0.label == "1"} )!
        currentLens.send(lensToUse)
        isCaptureSessionConfigured = true
        
        // Deferred block runs here.
    }
    
    /// Checks for authorization to use the device's camera.
    /// - Returns: A boolean inidcating whether the app is authorized to access the camera.
    private func isAuthorized() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            // Suspend the session queue
            sessionQueue.suspend()
            // Request authorization
            let isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            // Resume the session queue
            sessionQueue.resume()
            return isAuthorized
        case .denied:
            return false
        case .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    /// Updates the capture session for a capture device.
    /// Removes existing device inputs from the session and adds a new one for the given device.
    /// - Parameter captureDevice: The capture device to update the session with.
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        // Check if the session has been configured.
        guard isCaptureSessionConfigured
        else { return }
        
        // Begin configuration and commit at the end of the following code.
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // Remove device inputs from the session.
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        // Add a device input for the new capture device.
        if let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        // Update the video output connection to mirror output if using front camera.
        updateVideoOutputConnection()
    }
    
    /// Sets the video mirroring property for front camera use.
    private func updateVideoOutputConnection() {
        if let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    /// Captures a photo
    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) {
        sessionQueue.async { [ weak self] in
            guard let self  else { return }
            
            // Settings to use for the capture request.
            var photoSettings = AVCapturePhotoSettings()

            // Set the codec
            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            // Check for flash functionality
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? flashMode : .off
            
            // Set the pixel format
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            // Prioritize quality for capture
            photoSettings.photoQualityPrioritization = .quality
            
            // Set the orientation of the video connection for capture
            if let photoOutputVideoConnection = self.photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }
            
            // Capture and notify the delegate
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    /// Starts the capture session.
    func start() async {
        // Check for authorization.
        let authorized = await isAuthorized()
        guard authorized else {
            return
        }
        
        // Check if the session has already been configured and is not running.
        // In which case start running the session.
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                
                // On the session's dispatch queue, start running the session.
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            // Exit
            return
        }
        
        // If we are here, the session was not configured.
        sessionQueue.async { [self] in
            do {
                // Configure the capture session
                try self.configureCaptureSession()
                
                // Start runnig the session.
                self.captureSession.startRunning()
            } catch {
                
                // Handle the error if configuring fails.
                print(error.localizedDescription)
            }
        }
    }
    
    /// Ends the capture session.
    func stop() {
        // Make sure the session was configured or exit if not.
        guard isCaptureSessionConfigured else { return }
        
        // Stop the session if it is running.
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    /// Maps a device orientation to an `AVCaptureVideoOrientation`
    /// - Parameter deviceOrientation: The device orientation to map into an `AVCaptureVideoOrientation`
    /// - Returns: An `AVCaptureVideoOrientation` matching the given device orientation,
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait:
            return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeLeft
        default:
            return nil
        }
    }
}


extension CameraService: AVCapturePhotoCaptureDelegate {
    
    /// Delegate method to handle photo capture.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        // Send captured photo to the photo stream.
        addToPhotoStream?(photo)
    }
}


extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// The current device orientation.
    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.main.orientation
        }
        return orientation
    }
    
    /// Delegate method to handle capture output.
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Get the pixel buffer
        guard let pixelBuffer = sampleBuffer.imageBuffer
        else { return }
        
        // Set the video orientation for the current device orientation
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }

        // Add the frame to the preview stream
        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

fileprivate extension UIScreen {
    var orientation: UIDeviceOrientation {
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        if point == CGPoint.zero {
            return .portrait
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft
        } else {
            return .unknown
        }
    }
}



