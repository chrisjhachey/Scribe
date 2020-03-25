//
//  ViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-01.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import PromiseKit
import MobileCoreServices
import RealmSwift
import TesseractOCR
import CropViewController

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, CropViewControllerDelegate {
    let realm = try! Realm()
    var texts = [Text]()
    var selectedText: Text?
    var ocrText: String = ""
    let pickerView = UIPickerView()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var currentWorkingText: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        pickerView.delegate = self
        let color1 = UIColor.brown
        let color2 = Utility.hexStringToUIColor(hex: "#D0C8B0")

        pickerView.setValue(color1, forKey: "textColor")
        pickerView.setValue(color2, forKey: "backgroundColor")
        currentWorkingText.inputView = pickerView
        
        update()
        
        dismissPickerView()
    }
    
    @IBAction func scribeItPressed(_ sender: UIButton) {
        
        if let selectedText = selectedText {
            
            // Creates an action sheet that will appear at the bottom of the screen
            let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image", message: nil, preferredStyle: .actionSheet)

            // If the device has a camera, add a Take Photo button to the action sheet
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraButton = UIAlertAction(title: "Take Photo", style: .default) { alert -> Void in
                    
                    self.activityIndicator.startAnimating()                    // Reveals the View Controller's activity indicator
                    let imagePicker = UIImagePickerController()                // Creates an image picker
                    imagePicker.delegate = self                                // Assigns the current View Controller as the image picker's delegate
                    imagePicker.sourceType = .camera                           // Tells the image picker to present as a camera interface to the user
                    imagePicker.mediaTypes = [kUTTypeImage as String]          // Limits the image picker's media type to still images
                    
                    self.present(imagePicker, animated: true, completion: {    // Displays the image picker (as camera)
                        self.activityIndicator.stopAnimating()                 // Hides the activity indicator
                    })
                }
                    
                imagePickerActionSheet.addAction(cameraButton)
            }

            // Adds a Choose Existing button to the action sheet
            let libraryButton = UIAlertAction(title: "Choose Existing", style: .default) { alert -> Void in
                    
                self.activityIndicator.startAnimating()
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary                       // Tells the image picker to present as photo library
                imagePicker.mediaTypes = [kUTTypeImage as String]
                    
                self.present(imagePicker, animated: true, completion: {
                    self.activityIndicator.stopAnimating()
                })
            }
                
            imagePickerActionSheet.addAction(libraryButton)
            
            let customPassageButton = UIAlertAction(title: "Custom Passage", style: .default) { alert -> Void in
                
                self.present(CreatePassageViewController(text: selectedText, content: ""), animated: true, completion: nil)
            }
            
            imagePickerActionSheet.addAction(customPassageButton)

            // What to do when UIAlertController is canceled
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { alert -> Void in
                imagePickerActionSheet.dismiss(animated: true, completion: nil)
            }
                
            imagePickerActionSheet.addAction(cancelButton)

            // Present the alert
            present(imagePickerActionSheet, animated: true)
                
            defaults.set(selectedText.Name, forKey: "workingText")       // Set user default for current working text
        }
    }
            
    // Tesseract Image Recognition
    func performImageRecognition(_ image: UIImage) {
                
        let scaledImage = image.scaledImage(1000) ?? image

        if let tesseract = G8Tesseract(language: "eng+fra") {      // Attempt to initialize Tesseract
            tesseract.engineMode = .tesseractCubeCombined          // One of three engine modes, slowest but most accurate
            tesseract.pageSegmentationMode = .auto                 // Tells Tesseract it may expect multiple paragraphs
            tesseract.image = scaledImage                          // Assign the Tesseract image to the picked image
            tesseract.recognize()                                  // Perform OCR
                
            print(tesseract.recognizedText ?? "")
                    
            ocrText = tesseract.recognizedText!
                
                // Remove line breaks form the String
                while let rangeToReplace = ocrText.range(of: "\n") {
                    ocrText.replaceSubrange(rangeToReplace, with: " ")
                }
            }
                
            activityIndicator.stopAnimating()
            print("OCR Complete!!!!!")
            self.present(CreatePassageViewController(text: selectedText!, content: ocrText), animated: true, completion: nil)
    }
    
    // Fires when cropping is complete
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.performImageRecognition(image)
    }
    
    // Fires when cropping is canceled
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return texts.count // number of dropdown items
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return texts[row].Name // dropdown item
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedText = texts[row] // selected item
        currentWorkingText.text = selectedText?.Name
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        currentWorkingText.inputAccessoryView = toolBar
    }
    
    @objc func action() {
          view.endEditing(true)
    }
    
    @IBAction func menuButton(_ sender: Any) {
        print("Menu pushed!")
        HamburgerMenu().triggerSideMenu()
    }
    public func update() {
        
        firstly { () -> Promise<[Text]> in
            ScribeAPI.shared.get(resourcePath: "text/\(Context.shared.userId!)")
        }.done { results in
            self.texts = results
            
            if let defaultText = self.defaults.string(forKey: "workingText") {
                self.currentWorkingText.text = defaultText
            } else if results.count != 0 {
                self.currentWorkingText.text = results[0].Name
                self.selectedText = results[0]
            }
            
            self.pickerView.reloadAllComponents()
        }.catch { error in
            print(error)
        }
    }
}

// This is the delegate functionality for UIImagePickerController
extension HomeViewController: UIImagePickerControllerDelegate {
    // Function that fires when a photo is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    guard let selectedPhoto = info[.originalImage] as? UIImage else {      // Checks to ensure there is an image value
        dismiss(animated: true)
        return
    }

    activityIndicator.startAnimating()
        
    dismiss(animated: true) {
        let cropViewController = CropViewController(image: selectedPhoto)
        cropViewController.delegate = self
        
        self.present(cropViewController, animated: true, completion: nil)
    }
  }
}
