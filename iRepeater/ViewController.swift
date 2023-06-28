//
//  ViewController.swift
//  iRepeater
//
//  Created by Dmitry on 26.06.23.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

class ViewController: UIViewController {
    
    var currentFile: [[String: Any]] = []
    var count = -1
    var isDirect = true

    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var origText: UITextField!
    @IBOutlet weak var transText: UITextField!
    @IBOutlet weak var addInfo: UITextView!
    @IBOutlet weak var chooseBtn: UIButton!
    
    @IBAction func chooseFileOnTap(_ sender: Any) {
//        print("choose")
        presentFilePicker()
    }
    
    fileprivate func onTerm() {
        let term = currentFile[count]
        if (isDirect) {
            origText.text = term["orig"] as? String
            transText.text = ""
        } else {
            origText.text = ""
            transText.text = term["trans"] as? String
        }
        addInfo.text = ""
    }
    
    @IBAction func onNext(_ sender: Any) {
        if (currentFile.isEmpty) {
            return
        }
        if (count == currentFile.count) {
            count = -1
        }
        count += 1
        onTerm()
    }
    
    @IBAction func onPrev(_ sender: Any) {
        if (currentFile.isEmpty) {
            return
        }
        if (count == -1) {
            count = currentFile.count - 1
        }
        count -= 1
        onTerm()
    }
   
    @IBAction func switchLang(_ sender: Any) {
        isDirect = !isDirect
        if (isDirect) {
            stateLabel.text = "Eng -> Rus"
        } else {
            stateLabel.text = "Rus -> Eng"
        }
    }
    
    @IBAction func show(_ sender: Any) {
        if (currentFile.isEmpty) {
            return
        }
        let term = currentFile[count]
        if (!isDirect) {
            origText.text = term["orig"] as? String
        } else {
            transText.text = term["trans"] as? String
        }
        addInfo.text = term["addinfo"] as? String
    }
    
    func presentFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func readFile(at url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            // Process the file data
            if let fileContents = String(data: fileData, encoding: .utf8) {
                // Use the file contents as needed
//                print("File contents:\n\(fileContents)")
                jsonStringToJSON(fileContents)
            }
        } catch {
            // Handle any errors that occur while reading the file
            print("Error reading file: \(error.localizedDescription)")
        }
    }
    
    func jsonStringToJSON(_ jsonString: String) {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                // Process the JSON object
//                let isValid = JSONSerialization.isValidJSONObject(json)
//                print(isValid)
                if let jsonObject = json as? [[String: Any]] {
                    // Access the JSON properties as needed
                    currentFile = jsonObject
//                    print("JSON object:\n\(jsonObject)")
                }
            } catch {
                // Handle any errors that occur during JSON serialization
                print("Error converting JSON string to JSON object: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        print("Repeater!")
    }
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }
        // Access the selected file URL and perform the desired operations
//        print("Selected File URL: \(fileURL)")
        readFile(at: fileURL)
        let name: String = String(fileURL.lastPathComponent.prefix(10))
//        chooseBtn.titleLabel?.text = name
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle the cancellation of the file picker
        print("File picker was cancelled")
    }
    
}
