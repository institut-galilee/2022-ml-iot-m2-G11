

//
//  ViewController.swift
//  Projet
//
//  Created by HAJAR FAHSI on 18/01/2022.
//
//@available(macOS 14.8.1, *)


import UIKit
import AVKit
import AVFoundation
import Vision

class ViewController: UIViewController {

    // Var declaration
    @IBOutlet weak var PhoneRole: UITextField!
    @IBOutlet weak var Appname: UIToolbar!
    var kaynareponse : Bool = false
    //let client = Client(host: "172.20.10.2", port: UInt16(9011))
    // CoreMotion
    
                        /* Handling the shaking  */
    
    override var canBecomeFirstResponder: Bool {
          get {
              return true
          }
      }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
         if motion == .motionShake {
             print(" The phone is shaking ")
         }
     }

     /* Hand button */
    
    @IBAction func HandButton(_ sender: UIButton) {
        self.becomeFirstResponder()
    }
    
    
    //main function
    override func viewDidLoad() {

        super.viewDidLoad()

    }
}


class ImageViewController: UIViewController ,AVCaptureVideoDataOutputSampleBufferDelegate  {

        let client = Client(host: "172.20.10.2", port: UInt16(9013))
        var objectRecognizer = ObjectRecognizer()
        var isRecognizing = false
    
        override var prefersStatusBarHidden: Bool {
            return true
        }
        @IBOutlet weak var BelowView: UIView!
        
        @IBOutlet weak var ImageIdentifier: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client.start()
        //camera
        let captureSession = AVCaptureSession()

        client.send(data: "Camera started".data(using: .utf8)!)
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
       
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
 
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
 

        objectRecognizer.recognize(fromPixelBuffer: pixelBuffer) { objects in
            DispatchQueue.main.async { [self] in
                client.send(data: "Camera is working".data(using: .utf8)!)
                if (objectRecognizer.fraud == true) {
                    client.send(data: "Fraud".data(using: .utf8)!)
                }
            }
            
    
    }

    
    
}

}
    

