//
//  AuthorizedCheck.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/20.
//

import UIKit
import AVFoundation
import Photos

class AuthorizedCheck: NSObject {

    static func isMicrophoneAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return status == .authorized
    }
    
    static func isMicrophoneAuthorizationDetermined() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return status != .notDetermined
    }
    
    static func isMicrophoneNotDeterminedOrAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return status == .notDetermined || status == .authorized
    }
    
    static func isCameraAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .authorized
    }
    
    static func isCameraAuthorizationDetermined() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return status != .notDetermined
    }
    
    static func isCameraNotDeterminedOrAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .notDetermined || status == .authorized
    }
    
    static func isPhotoAuthorized() -> Bool {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status == .authorized
    }
    
    static func isPhotoAuthorizationDetermined() -> Bool {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status != .notDetermined
    }
    
    // MARK: - Action
    static func takeCameraAuthorityStatus(completion: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard let completion = completion else { return }
            completion(granted)
        }
    }
    
    static func takeMicPhoneAuthorityStatus(completion: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            guard let completion = completion else { return }
            completion(granted)
        }
    }
    
    static func showMicrophoneUnauthorizedAlert(_ viewController: UIViewController) {
        let title: String = ZGLocalizedString("room_page_mic_cant_open")
        let message: String = ZGLocalizedString("room_page_grant_mic_permission")
        showAlert(title, message, viewController) {
            openAppSettings()
        }
    }
    
    static func showCameraUnauthorizedAlert(_ viewController: UIViewController) {
        // TODO: - need add localized string
        let title: String = ""
        let message: String = ""
        showAlert(title, message, viewController) {
            openAppSettings()
        }
    }
    
    static func showPhotoUnauthorizedAlert(_ viewController: UIViewController) {
        // TODO: - need add localized string
        let title: String = ""
        let message: String = ""
        showAlert(title, message, viewController) {
            openAppSettings()
        }
    }
    
    private static func showAlert(_ title: String,
                                  _ message: String,
                                  _ viewController: UIViewController,
                                  okCompletion: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: ZGLocalizedString("room_page_cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: ZGLocalizedString("room_page_go_to_settings"), style: .default) { action in
            okCompletion()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
