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
    
    private let sessionQueue = DispatchQueue(label: "ProCam.SessionQueue")

    override init() {
        super.init()
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video,
                                                position: .back)
    }
    
}

extension CameraService {
    
    func configureCaptureSession() throws {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        guard let captureDevice = captureDevice
        else { return }
        let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        let photoOutput = AVCapturePhotoOutput()
                        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "ProCam.VideoDataOutputQueue"))
  
        guard captureSession.canAddInput(deviceInput)
        else { return }
        guard captureSession.canAddOutput(photoOutput)
        else { return }
        guard captureSession.canAddOutput(videoOutput)
        else { return }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
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



