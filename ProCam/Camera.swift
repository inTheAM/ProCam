//
//  Camera.swift
//  ProCam
//
//  Created by Ahmed Mgua on 20/11/22.
//

import AVFoundation
import SwiftUI

@MainActor
final class Camera: ObservableObject {
    private let service = CameraService()
    @Published private(set) var preview: Image?
    @Published private(set) var thumbnailImage: Image?
    @Published private(set) var flashMode = AVCaptureDevice.FlashMode.off
    @Published private(set) var isShowingGrid = false
    @Published private(set) var focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
    var isInManualfocus: Bool {
        focusMode == .locked
    }
    init() {
        Task {
            await handleCameraPreviews()
        }
        Task {
            await handleCameraPhotos()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = service.previewStream
            .map { $0.image }

        for await image in imageStream {
            preview = image
        }
    }
    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = service.photoStream
            .compactMap { await self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            Task {
                thumbnailImage = photoData.thumbnailImage
            }
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
    func start() async {
        await service.start()
    }
    
    func capture() {
        service.capturePhoto(flashMode: flashMode)
    }
    
    func flipCamera() {
        service.flipCaptureDevice()
    }
    
    func switchRearCamera() {
        service.switchRearCaptureDevice()
    }
    
    func toggleFlashMode() {
        flashMode = flashMode == .on ? .off : .on
    }
    
    func toggleGrid() {
        isShowingGrid.toggle()
    }
    
    func toggleFocusMode() {
        focusMode = focusMode == .continuousAutoFocus ? .locked : .continuousAutoFocus
        service.switchFocusMode(to: focusMode)
    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}
fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
