//
//  AudioService.swift
//  iRepeater
//
//  Created by Dmitry on 16.07.23.
//

import Foundation
import AVFoundation

class AudioService {
    
    func playSentence(_ orig: String) {
        orig.split(separator: " ")
            .filter { word in word.count > 2 && !word.contains("(") && !word.contains(")") }
            .map { word in URL(string: getPronunciationServiceUrl(word: String(word)))!}
            .forEach { url in playAudioFromURL(url: url)}
    }
    
    func playAudioFromURL(url: URL) {
//        print(url)
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let player = try AVAudioPlayer(data: data)
                player.play()
                sleep(2) // yebanie pidarasi iz epol
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }
    }
    
    func getPronunciationServiceUrl(word: String) -> String {
//        print(word)
        return "https://ssl.gstatic.com/dictionary/static/pronunciation/2022-03-02/audio/\(word.prefix(2))/\(word)_en_us_1.mp3"
    }
}
