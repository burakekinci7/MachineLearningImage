//
//  ViewController.swift
//  MachineLearningImage
//
//  Created by Ramazan Burak Ekinci on 26.11.2023.
//
// https://developer.apple.com/machine-learning/models/
// Download the MobileNetV2 from the link above

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            understandImage(image: ciImage)
        }
    }
    
    func understandImage(image: CIImage){
        //1 - request
        
        
        label.text = "Finding..."
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model) { vnReqest, error in
                if let results = vnReqest.results as? [VNClassificationObservation]{
                    if results.count > 0{
                        let topResult = results.first
                        DispatchQueue.main.async {
                            let confidantial = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidantial * 100 ) / 100
                            self.label.text = "\(rounded) it's \(topResult!.identifier)"
                        }
                        
                    }
                }
            }
            
            //2 - hadler
            let handler = VNImageRequestHandler(ciImage: image)
            //asyncron process
            DispatchQueue.global(qos: .userInitiated).async {
                do{
                    try handler.perform([request])
                }catch{
                    print("Eoorr. Hnalder ")
                }
            }
        }
    }
    
}

