//
//  AudioService.swift
//  iRepeater
//
//  Created by Dmitry on 16.07.23.
//

import Foundation
import AVFoundation

class AudioService {
    
    private let audioCache = AudioCacheManager()
    
    func playSentence(_ orig: String) {
        orig.split(separator: " ")
            .filter { word in word.count > 2 && !word.contains("(") && !word.contains(")") }
            .map { word in URL(string: getPronunciationServiceUrl(word: String(word)))!}
            .forEach { url in playAudioFromURL(url: url)}
    }
    
    func playAudioFromURL(url: URL) {
//        print(url)
        DispatchQueue.global().async {
            self.audioCache.getOrDownload(from: url) { localUrl in
                guard let localUrl = localUrl else {
                    print("Failed to download audio")
                    return
                }
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: localUrl)
//                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    sleep(2) // yebanie pidarasi iz epol
                } catch {
                    print("Error playing audio: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getPronunciationServiceUrl(word: String) -> String {
//        print(word)
        return "https://ssl.gstatic.com/dictionary/static/pronunciation/2022-03-02/audio/\(word.prefix(2))/\(word)_en_us_1.mp3"
    }
}

class AudioCacheManager {

    private let fileManager = FileManager.default
    
    func getOrDownload(from url: URL, completion: @escaping (URL?) -> Void) {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let localUrl = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        
        if fileManager.fileExists(atPath: localUrl.path) {
            completion(localUrl)
//            print("Аудио уже закешировано")
        } else {
//            print("Загрузка аудио")
            let task = URLSession.shared.downloadTask(with: url) { (tempUrl, response, error) in
                guard let tempUrl = tempUrl, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    try self.fileManager.moveItem(at: tempUrl, to: localUrl)
                    completion(localUrl)
                } catch {
                    print("Ошибка при перемещении файла: \(error)")
                    completion(nil)
                }
            }
            task.resume()
        }
    }
}
