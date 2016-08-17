//
//  MinimumPlayer.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/08/10.
//  Copyright © 2016年 rodhosSoft.
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php

import Foundation
import AVFoundation
import UIKit



protocol RDAVPlayerAPI {
    func setupPlayer(url:NSURL)
    func play()
    func seek(value:Float)
}

protocol RDAVPlayerViewAPI {
    func setup()
    func updatePlay()
    func updatePause()
    func updateSeekValue()
}


enum RDAVPlayerPresenterEvent {
    case NotifyPlayButtonPushed
    case NotifySeekValueChanged(value:Float)
}


protocol  RDAVPlayerEventReceiver {
    func notify(event:RDAVPlayerPresenterEvent)
}


// State manager
class RDAVPlayerPresenter : RDAVPlayerEventReceiver {
    let playerControl : RDAVPlayerAPI = RDAVPlayer.shareInstance
    let playerView : RDAVPlayerViewAPI
    
    let sampleURL = NSBundle.mainBundle().URLForResource("samplemovie", withExtension: "mov")!
    
    init(view:RDAVPlayerViewAPI){
        playerView = view
        setup()
    }
    
    func setup() {
        playerControl.setupPlayer(sampleURL)
        playerView.setup()
    }
    
    func notify(event:RDAVPlayerPresenterEvent) {
        switch event {
        case .NotifyPlayButtonPushed:
            playerControl.play()
        case .NotifySeekValueChanged(value: let value):
            playerControl.seek(value)
        }
    }
    
}

/// control to AVPlayer
class RDAVPlayer : NSObject, RDAVPlayerAPI {
    
    var playerLayer:AVPlayerLayer!
    var player:AVPlayer! {
        didSet(oldplayer) {
            if let o = oldplayer {
                o.removeObserver(self, forKeyPath: "status")
                o.removeObserver(self, forKeyPath: "rate")
            }
            
            self.player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
            self.player.addObserver(self, forKeyPath: "rate", options: .New, context: nil)

        }
    }
    
    var boundTimeObserverToken : AnyObject?
    var periodTimeObserverToken : AnyObject?
    
    static let shareInstance:RDAVPlayer = RDAVPlayer()
    
    override init() {
        super.init()
        setupObserver()
    }
    
    func setupObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RDAVPlayer.notify(_:)), name: AVPlayerItemTimeJumpedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RDAVPlayer.notify(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RDAVPlayer.notify(_:)), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RDAVPlayer.notify(_:)), name: AVPlayerItemPlaybackStalledNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RDAVPlayer.notify(_:)), name: AVPlayerItemNewAccessLogEntryNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RDAVPlayer.notify(_:)), name: AVPlayerItemNewErrorLogEntryNotification, object: nil)
        // AVPlayerItemFailedToPlayToEndTimeErrorKey

    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        print("observeValueForKeyPath:\(keyPath) ofObject \(object) change:\(change), context:\(context)")
        
        guard let key:String = keyPath else {
            return
        }
        
        switch key {
        case "status":
            print("status = \(self.player.status.rawValue)")
        case "rate":
            print("rate = \(self.player.rate)")
        default:
            break
        }
    }
    
    func notify(notification:NSNotification)->() {
        print("\(notification.name)")
    }
    
    
    func setTimeObserver() -> Bool {
        
        let periodblock = {(time:CMTime) in
            CMTimeShow(time)
        }
        
        let boundaryBlock = {() in
            print("end")
        }
        
        self.periodTimeObserverToken =  player.addPeriodicTimeObserverForInterval(CMTimeMake(100, 100),
                                                                                  queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                                  usingBlock: periodblock)
        
        let duration = self.player.currentItem!.duration
        
        func getTime(percent:Float64)->NSValue {
            let t =  CMTimeMultiplyByFloat64(duration, percent)
            let v = NSValue(CMTime:t)
            return v
        }
        
        let times = [getTime(0), getTime(0.5), getTime(1)]
        
        self.boundTimeObserverToken =  player.addBoundaryTimeObserverForTimes(times,
                                                                              queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                              usingBlock:boundaryBlock)
        
        return true
    }
    

    
    func play() {
        player.play()
    }
    
    func seek(value:Float) {
        
        guard value >= 0 && value < 1 else {
            return
        }
        
        let duration_ : CMTime? = self.player.currentItem!.duration
        guard let duration : CMTime = duration_ else {
            return
        }
        
        let time : CMTime = CMTimeMultiplyByFloat64(duration, Float64(value))
        let t10 : CMTime = CMTimeMake(10, 1)
        
        
        player.seekToTime(time, toleranceBefore: t10, toleranceAfter: t10, completionHandler: { isS in
            print("seekTo\(isS)")
        })
    }
    
    
    
    func setupPlayer(url:NSURL) {
        let item = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    
    func removeTimeObserver() {
        if let ob = self.periodTimeObserverToken {
            self.player.removeTimeObserver(ob)
        }
        if let ob = self.boundTimeObserverToken {
            self.player.removeTimeObserver(ob)
        }
    }
    
    func removeObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
}

