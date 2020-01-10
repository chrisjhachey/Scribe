//
//  ViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-01.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import MicroBlink
import RealmSwift

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MBBarcodeOverlayViewControllerDelegate {
    let realm = try! Realm()
    var texts: Results<Text>?
    var selectedText: String?
    
    var rawParser: MBRawParser?
    var parserGroupProcessor: MBParserGroupProcessor?
    var blinkInputRecognizer: MBBlinkInputRecognizer?
    
    @IBOutlet weak var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        texts = realm.objects(Text.self)
        
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    
    @IBAction func scribeItPressed(_ sender: UIButton) {
        print("Scribe It Pushed: \(selectedText!)")
        
        MBMicroblinkSDK.sharedInstance().setLicenseKey(Context.shared.blinkLicenseKey)
        
        let settings = MBBarcodeOverlaySettings()
        rawParser = MBRawParser()
        parserGroupProcessor = MBParserGroupProcessor(parsers: [rawParser!])
        blinkInputRecognizer = MBBlinkInputRecognizer(processors: [parserGroupProcessor!])
        
        let recognizerList = [self.blinkInputRecognizer!]
        let recognizerCollection : MBRecognizerCollection = MBRecognizerCollection(recognizers: recognizerList)
        
        /** Create your overlay view controller */
        let barcodeOverlayViewController : MBBarcodeOverlayViewController = MBBarcodeOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
        
        /** Create recognizer view controller with wanted overlay view controller */
        let recognizerRunneViewController : UIViewController = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: barcodeOverlayViewController)
        
        /** Present the recognizer runner view controller. You can use other presentation methods as well (instead of presentViewController) */
        present(recognizerRunneViewController, animated: true, completion: nil)
    }
    
    func barcodeOverlayViewControllerDidFinishScanning(_ barcodeOverlayViewController: MBBarcodeOverlayViewController, state: MBRecognizerResultState) {

        // this is done on background thread
        // check for valid state
        if state == MBRecognizerResultState.valid {

            // first, pause scanning until we process all the results
            barcodeOverlayViewController.recognizerRunnerViewController?.pauseScanning()

            DispatchQueue.main.async(execute: {() -> Void in
                // All UI interaction needs to be done on main thread
            })
        }
    }

    func barcodeOverlayViewControllerDidTapClose(_ barcodeOverlayViewController: MBBarcodeOverlayViewController) {
        // Your action on cancel
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return texts![row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return texts!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedText = texts![row].name
    }
    
    func textsUpdated() {
        texts = realm.objects(Text.self)
        picker.reloadAllComponents()
    }
}
