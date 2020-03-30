//
//  HTMLUtility.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-08.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

public class Utility {
    
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    public static func getExportString() -> Promise<String> {
        var exportString = ""
        var texts = [Text]()
        var passages = [Passage]()
        var textsAndPassages = [Int: [Passage]]()
        
        guard let userId = Context.shared.userId else {
            fatalError("No user id found in session!")
        }
        
        return Promise { seal in
            
            firstly { () -> Promise<[Text]> in
                ScribeAPI.shared.get(resourcePath: "text/\(userId)")
            }.then { results -> Promise<[[Passage]]> in
                texts = results
                var textGenerator = texts.makeIterator()
                let generator = AnyIterator<Promise<[Passage]>> {
                    guard let text = textGenerator.next() else {
                        return nil
                    }
                    
                    return ScribeAPI.shared.get(resourcePath: "\(text.ID)/passage/\(text.UserID)")
                }
                
                return when(fulfilled: generator, concurrently: 5)
            }.done { results in
                for passageArray in results {
                    passages.append(contentsOf: passageArray)
                }
                
                for text in texts {
                    var myPassages = [Passage]()
                    for passage in passages where passage.TextID == text.ID {
                        myPassages.append(passage)
                    }
                    
                    textsAndPassages[text.ID] = myPassages
                }
                
                for text in texts {
                    exportString += "\(text.Name)\n\n\n"
                    
                    for passage in textsAndPassages[text.ID]! {
                        exportString += "\(passage.Content)\n\n"
                    }
                    
                    exportString += "\n"
                }
                
                seal.fulfill(exportString)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    public static func getPassageView(text: Text, passages: [Passage]) -> NSMutableAttributedString {
        let formattedPassages = NSMutableAttributedString()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let boldFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), .paragraphStyle: paragraph]
        let normalFontAttributes = [NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPSMT", size: 12)!]
        
        let textTitle = NSMutableAttributedString(string: "\(text.Name)\n", attributes: boldFontAttributes)
        formattedPassages.append(textTitle)
        
        if let edition = text.Edition {
            let textEdition = NSMutableAttributedString(string: "\(edition)\n\n\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Cochin-Italic", size: 16) as Any, .paragraphStyle: paragraph])
            formattedPassages.append(textEdition)
        }
        
        for passage in passages {
            let passageString = NSMutableAttributedString(string: "\"\(passage.Content)\"  ", attributes: normalFontAttributes)
            
            if passage.PageNumber != "" {
                let pageNumberString = NSMutableAttributedString(string: " (p\(passage.PageNumber!))   ", attributes: [NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPSMT", size: 9)!])
                passageString.append(pageNumberString)
            }
            
            let editImage = NSTextAttachment()
            editImage.image = UIImage(named: "feather (7)")
            let editImageString = NSAttributedString(attachment: editImage)
            passageString.append(editImageString)
            passageString.append(NSAttributedString(string: "\n\n"))

            if let imageRange = passageString.string.range(of: editImageString.string) {
                let index = passageString.string.index(before: imageRange.upperBound)
                let upperRange = NSRange(index..., in: passageString.string)
                passageString.addAttribute(NSAttributedString.Key.passageIdentifier, value: passage.ID, range: upperRange)
            }

            formattedPassages.append(passageString)
        }
        
        
        
        return formattedPassages
    }
    
    func doThing() {
        print("Thing done")
    }
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @objc func addNote(sender: UIButton!) {
      print("Button tapped??")
    }
    
    // Access the Apps documents directory
    public static func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        print(paths[0].absoluteString)
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    public static func printTimestamp() -> String {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
      
        return timestamp
    }
    
    

    // Google Drive functions
    
    // Create a folder
    public static func createGoogleDriveFolder(name: String, service: GTLRDriveService, completion: @escaping (String) -> Void) {
        
        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name
        
        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        service.executeQuery(query) { (_, file, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folder = file as! GTLRDrive_File
            completion(folder.identifier!)
        }
    }
    
    // Get a folder
    public static func getGoogleDriveFolderID(name: String, service: GTLRDriveService, user: GIDGoogleUser, completion: @escaping (String?) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()

        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"
        
        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
            
        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
                                     
            let folderList = result as! GTLRDrive_FileList

            // For brevity, assumes only one folder is returned.
            completion(folderList.files?.first?.identifier)
        }
    }
    
    // Upload a file
    public static func uploadGoogleDriveFile(name: String, folderID: String, fileURL: URL, mimeType: String, service: GTLRDriveService, controller: UIAlertController, progressBar: UIProgressView) {
        
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]
        
        // Optionally, GTLRUploadParameters can also be created with a Data object.
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        service.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
            
            let progress = Float(totalBytesUploaded)/Float(totalBytesExpectedToUpload)
            
            DispatchQueue.main.async {
                progressBar.setProgress(progress, animated: true)
            }
            
            controller.message = "\(String(Int(round(100 * (Double(totalBytesUploaded)/Double(totalBytesExpectedToUpload)))))) %"
        }
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                controller.message = "Something went wrong. Please try again later."
                fatalError(error!.localizedDescription)
            }
            
            controller.message = "Success!"
        }
    }
}

// Used to resize the text image to within a max dimension while retaining aspect ratio
extension UIImage {
    
    func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    
        if size.width > size.height {
            scaledSize.height = size.height / size.width * scaledSize.width
        } else {
            scaledSize.width = size.width / size.height * scaledSize.height
        }
    
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return scaledImage
    }
}

// Custom attribute for NSAttributedString used to listen for button clicks on passages
extension NSAttributedString.Key {
    static let passageIdentifier = NSAttributedString.Key(rawValue: "MyCustomAttribute")
}

// Used to add options to buttons in Storyboard!
@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
