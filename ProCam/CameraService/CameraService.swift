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
    
    /// All capture devices
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified).devices
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
    
    /// Tracks whether the capture session is running
    var isRunning: Bool {
        captureSession.isRunning
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
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video,
                                                position: .back)
    }
    
}

extension CameraService {
    
    /// Configures the capture session, adding inputs and outputs for photos and video.
    func configureCaptureSession() throws {
        // Begin configuration
        captureSession.beginConfiguration()
        
        // Use `defer` to run code at the end of the function.
        // If configuration proceeds without errors, then commit.
        defer {
            captureSession.commitConfiguration()
        }
        
        // Check for a capture device
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
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        // Update the video output connection to mirror output if using front camera.
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        
        // Defer block runs here.
    }
    
    private func isAuthorized() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            sessionQueue.suspend()
            let isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
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
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured
        else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async { [ weak self] in
            guard let self  else { return }
            var photoSettings = AVCapturePhotoSettings()

            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .quality
            
            if let photoOutputVideoConnection = self.photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func start() async {
        let authorized = await isAuthorized()
        guard authorized else {
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            do {
                try self.configureCaptureSession()
                self.captureSession.startRunning()
            } catch {
                
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }
}


extension CameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        addToPhotoStream?(photo)
    }
}


extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.main.orientation
        }
        return orientation
    }
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = sampleBuffer.imageBuffer
        else { return }
        
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }

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



