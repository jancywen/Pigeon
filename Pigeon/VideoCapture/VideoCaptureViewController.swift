//
//  VideoCaptureViewController.swift
//  Pigeon
//
//  Created by captain on 2021/3/29.
//

import UIKit
import AVFoundation

class VideoCaptureViewController: UIViewController {

    
    var captureDeviceInput: AVCaptureDeviceInput!
    var captureVideoDataOutput: AVCaptureVideoDataOutput!
    var captureSession: AVCaptureSession!
    var captureConnection: AVCaptureConnection?
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    
    var isCapturing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // 初始化摄像头
        let cameras = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front).devices
        
        guard let camera = cameras.first else {
            return
        }
        
        // Input
        guard let input = try? AVCaptureDeviceInput.init(device: camera) else {
            return
        }
        
        
        // Output
        let output = AVCaptureVideoDataOutput()
        // YUV
        output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(integerLiteral: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange))]
        
        let outputQueue = DispatchQueue(label: "ACVideoCaptureOutputQueue")
        output.setSampleBufferDelegate(self, queue: outputQueue)
        

        // session
        let session = AVCaptureSession()
        //不使用应用的实例，避免被异常挂断
        session.usesApplicationAudioSession = false
        // 添加输入设备到会话
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // 添加输出设备到会话
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // 设置分辨率
        if session.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720) {
            session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        
        // 获取连接并设置视频方向为竖屏方向
        let connection = output.connection(with: AVMediaType.video)
        connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        // 前置镜像
        if camera.position == AVCaptureDevice.Position.front && connection?.isVideoMirroringSupported ?? false {
            connection?.automaticallyAdjustsVideoMirroring = true
        }

        //获取预览Layer并设置视频方向，
        let previewLayer = AVCaptureVideoPreviewLayer(layer: session)
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        captureDeviceInput = input
        captureVideoDataOutput = output
        captureSession = session
        captureConnection = connection
        captureVideoPreviewLayer = previewLayer
        
        
    }

    // 开始采集
    @discardableResult
    func startCapture() -> Bool {
        if self.isCapturing { return false }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus != .authorized {
            return false
        }
        
        self.captureSession.startRunning()
        self.isCapturing = true
        return true
    }
    
    // 结束采集
    func stopCapture() {
        self.captureSession.stopRunning()
        self.isCapturing = false
    }

    @IBAction func startCaptureAction(_ sender: Any) {
        startCapture()
    }
    @IBAction func stopCaptureAction(_ sender: Any) {
        stopCapture()
    }
    
}

extension VideoCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // 摄像头采集的数据回调
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    }
}
