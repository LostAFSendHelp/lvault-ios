//
//  CameraPermissionView.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/9/25.
//

import SwiftUI
import AVFoundation

// MARK: - Camera Permission Handler
struct CameraPermissionView: View {
    @State private var showingPermissionAlert = false
    @State private var permissionStatus: AVAuthorizationStatus = .notDetermined
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    var body: some View {
        Text("")
            .onAppear {
                checkCameraPermission()
            }
            .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    openSettings()
                }
                Button("Cancel", role: .cancel) {
                    onPermissionDenied()
                }
            } message: {
                Text("This app needs camera access to scan receipts. Please enable camera access in Settings.")
            }
    }
    
    private func checkCameraPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch permissionStatus {
        case .authorized:
            onPermissionGranted()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.onPermissionGranted()
                    } else {
                        self.showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionAlert = true
        @unknown default:
            showingPermissionAlert = true
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        onPermissionDenied()
    }
}
