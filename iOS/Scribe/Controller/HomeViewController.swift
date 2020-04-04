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
    
    @IBOutlet weak var scribeItButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var currentWorkingText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        currentWorkingText.textAlignment = .center
        
        scribeItButton.layer.shadowColor = UIColor.gray.cgColor
        scribeItButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        scribeItButton.layer.shadowRadius = 5
        scribeItButton.layer.shadowOpacity = 0.5
        
        pickerView.delegate = self
        let color1 = UIColor.white
        
        let colorGradient1 = Utility.hexStringToUIColor(hex: "#DAD4BD")
        let colorGradient2 = Utility.hexStringToUIColor(hex: "#DBD3BA")
        let color2 = Utility.hexStringToUIColor(hex: "#D0C8B0")
        
        let colors = [colorGradient1, colorGradient2, color2]
        
        //scribeItButton.applyGradient(colours: colors, locations: [0.0, 0.5, 1.0])

        pickerView.setValue(color2, forKey: "textColor")
        pickerView.setValue(color1, forKey: "backgroundColor")
        currentWorkingText.inputView = pickerView
        
        update()
        
        dismissPickerView()
    }
    
    @IBAction func scribeItPressed(_ sender: Any) {
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
                let usage = UsageMeasurementEntry()
                usage.UserID = Context.shared.userId!
                usage.Action = UsageMeasurementEntry.UsageMeasurementAction.Scribe.rawValue
                usage.DateStamp = Utility.printTimestamp()
                
                firstly {
                    ScribeAPI.shared.post(resourcePath: "usage", entity: usage)
                }.done { results in
                    print(results)
                    self.present(CreatePassageViewController(text: self.selectedText!, content: "", passage: nil, parentVC: nil), animated: true, completion: nil)
                }.catch { error in
                    print(error)
                }
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
        } else {
            self.errorMessageLabel.text = "Select or create a text first"
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
        
        let usage = UsageMeasurementEntry()
        usage.UserID = Context.shared.userId!
        usage.Action = UsageMeasurementEntry.UsageMeasurementAction.Scribe.rawValue
        usage.DateStamp = Utility.printTimestamp()
        
        firstly {
            ScribeAPI.shared.post(resourcePath: "usage", entity: usage)
        }.done { results in
            print(results)
            self.present(CreatePassageViewController(text: self.selectedText!, content: self.ocrText, passage: nil, parentVC: nil), animated: true, completion: nil)
        }.catch { error in
            print(error)
        }
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
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = texts[row].Name
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Futura-CondensedExtraBold", size: 26.0)!,NSAttributedString.Key.foregroundColor:UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
       return pickerLabel
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
                
                for text in results where text.Name == defaultText {
                    self.selectedText = text
                    self.currentWorkingText.text = defaultText
                    self.errorMessageLabel.text = nil
                }
                
            } else if results.count != 0 {
                self.currentWorkingText.text = results[0].Name
                self.selectedText = results[0]
                self.errorMessageLabel.text = nil
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
