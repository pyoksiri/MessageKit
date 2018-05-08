//
//  AudioManager.swift
//  MessageKit
//
//  Created by Phanuwat Yoksiri on 7/5/2561 BE.
//  Copyright © 2561 MessageKit. All rights reserved.
//

import UIKit
import AVFoundation

public let kLibraryPath = NSHomeDirectory() + "/Library/Caches"
public let kContentFolderName = "/Contents/"
public let kContentPath = kLibraryPath + kContentFolderName

class AudioManager: NSObject {
    static let shared = AudioManager()
    var audioPlayer: AVAudioPlayer!
    var messageId: String!
    var label: UILabel!
    var timer: Timer!
    
    func start(with url: URL, label: UILabel, messageId: String) {
        self.label = label
        if let currentId = self.messageId {
            if currentId == messageId {
                if let audioPlayer = audioPlayer {
                    if audioPlayer.isPlaying {
                        pause()
                    }
                    else {
                        resume()
                    }
                }
                return
            }
            else {
                stop()
            }
        }
        self.messageId = messageId
        
        let contentPath = kContentPath.appending(messageId + ".caf")
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if !fileManager.fileExists(atPath: kContentPath, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: kContentPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                self.failed()
                print("catch error",error.localizedDescription)
            }
        }
        
        if fileManager.fileExists(atPath: contentPath) {
            playAudio(with: URL.init(fileURLWithPath: contentPath))
        }
        else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: "loading")
            DownloadManager.shared.getDataFromUrl(url: url) { (data, response, error) in
                if (error == nil) {
                    do {
                        print(contentPath)
                        try data?.write(to: URL.init(fileURLWithPath: contentPath))
                        self.playAudio(with: URL.init(fileURLWithPath: contentPath))
                    }
                    catch {
                        self.failed()
                        print("catch error",error.localizedDescription)
                    }
                }
                else {
                    self.failed()
                }
            }
        }
    }
    
    func playAudio(with url: URL) {
        do {
            audioPlayer = try AVAudioPlayer.init(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.play()
            updateTimeDuration()
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimeDuration), userInfo: nil, repeats: true)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: "play")
        }
        catch {

        }
    }
    
    func pause() {
        audioPlayer.pause()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: "pause")
    }
    
    func resume() {
        audioPlayer.play()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: "play")
    }
    
    func failed() {
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
            self.audioPlayer = nil
        }
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: "failed")
        self.messageId = nil
    }
    
    func stop() {
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
            self.audioPlayer = nil
        }
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: "stop")
        self.messageId = nil
    }
    
    @objc func updateTimeDuration() {
        let time = audioPlayer.duration - audioPlayer.currentTime
        let minute = lroundf(Float(time)) / 60
        let seconds = lroundf(Float(time)) % 60;
        DispatchQueue.main.async {
            self.label.text = String(format: "%02zd:%02zd", minute, seconds)
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
