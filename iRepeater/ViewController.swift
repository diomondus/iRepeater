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
    
    let audioService = AudioService()
    
    var currentFile: [[String: Any]] = //[]
    [ // test data
        ["orig": "wink", "trans":"тест1", "addinfo":"eg1"],
        ["orig": "(at) lodge", "trans":"тест2", "addinfo":"eg2"],
        ["orig": "clarify (for)", "trans":"тест3", "addinfo":"eg3"],
        ["orig": "brass wink", "trans":"тест4", "addinfo":"eg4"],
    ]
    var position = -1
    var isDirect = true

    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var origText: UITextField!
    @IBOutlet weak var transText: UITextField!
    @IBOutlet weak var addInfo: UITextView!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var switchDirectionButton: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBAction func chooseFileOnTap(_ sender: Any) {
//        print("choose")
        presentFilePicker()
    }
    
    @IBAction func onNext(_ sender: Any) {
        if (currentFile.isEmpty) {
            return
        }
        if (position == currentFile.count - 1) {
            position = -1
            progressBar.progress = 0
            currentFile.shuffle()
        }
        position += 1
        progressBar.progress += 1.0 / Float(currentFile.count)
        if (position > 0) {
            audioService.playSentence(currentFile[position - 1]["orig"] as! String)
        }
        onTerm()
    }
    
    @IBAction func onPrev(_ sender: Any) {
        if (currentFile.isEmpty) {
            return
        }
        if (position <= 0) {
            position = currentFile.count
            progressBar.progress = 1
            currentFile.shuffle()
        }
        position -= 1
        progressBar.progress -= 1.0 / Float(currentFile.count)
        if (position < currentFile.count - 1) {
            audioService.playSentence(currentFile[position + 1]["orig"] as! String)
        }
        onTerm()
    }
    
    fileprivate func onTerm() {
//        print("count \(count)")
//        print("direction: \(isDirect ? "straight": "reversed")")
        let term = currentFile[position]
        if (isDirect) {
            let orig = term["orig"] as! String
            origText.text = orig
            transText.text = ""
        } else {
            let trans = term["trans"] as! String
            origText.text = ""
            transText.text = trans
        }
        addInfo.text = ""
    }
    
    @IBAction func switchLang(_ sender: Any) {
        isDirect = !isDirect
        if (isDirect) {
            switchDirectionButton.setTitle("EN→RU", for: .normal)
        } else {
            switchDirectionButton.setTitle("RU→EN", for: .normal)
        }
    }
    
    @IBAction func show(_ sender: Any) {
        if (currentFile.isEmpty) {
            return
        }
        let term = currentFile[position]
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
                jsonStringToJSON(fileContents, url)
            }
        } catch {
            // Handle any errors that occur while reading the file
            print("Error reading file: \(error.localizedDescription)")
        }
    }
    
    func jsonStringToJSON(_ jsonString: String, _ fileURL: URL) {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                // Process the JSON object
//                let isValid = JSONSerialization.isValidJSONObject(json)
//                print(isValid)
                if let jsonObject = json as? [[String: Any]] {
                    // Access the JSON properties as needed
                    currentFile = jsonObject.shuffled()
//                    print("JSON object:\n\(jsonObject)")
                    stateLabel.text = String(fileURL.lastPathComponent.prefix(10))
                    progressBar.progress = 0
                }
            } catch {
                // Handle any errors that occur during JSON serialization
                print("Error converting JSON string to JSON object: \(error.localizedDescription)")
            }
        }
    }
    
//    func downloadFileFromURL(url:NSURL){
//        var downloadTask:URLSessionDownloadTask
//        downloadTask = URLSession.shared.downloadTask(with: url as URL, completionHandler: { [weak self](URL, response, error) -> Void in
//            self?.play(url: URL!)
//        })
//        downloadTask.resume()
//    }
//
//    func play(url: URL) {
//        print("playing \(url)")
//        do {
//            let player = try AVAudioPlayer(contentsOf: url)
//            player.prepareToPlay()
//            player.volume = 1.0
//            player.play()
//        } catch let error as NSError {
//            //self.player = nil
//            print(error.localizedDescription)
//        } catch {
//            print("AVAudioPlayer init failed")
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTouchOverlay()
    }
    
    func setupTouchOverlay() {
        // Create a transparent view with the same frame as the disabled text field
        let touchOverlayView = UIView(frame: origText.frame)
        view.addSubview(touchOverlayView)

        // Add a tap gesture recognizer to the overlay view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        touchOverlayView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//        print("Touched the disabled text field overlay")
        if (origText.text != nil && !origText.text!.isEmpty) {
            audioService.playSentence(origText.text!)
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }
        // Access the selected file URL and perform the desired operations
//        print("Selected File URL: \(fileURL)")
        if (fileURL.pathExtension == "json") {
            readFile(at: fileURL)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle the cancellation of the file picker
        print("File picker was cancelled")
    }
    
}
