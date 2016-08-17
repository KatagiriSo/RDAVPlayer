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
class RDAVPlayer : RDAVPlayerAPI {
    
    var playerLayer:AVPlayerLayer!
    var player:AVPlayer!
    
    static let shareInstance:RDAVPlayer = RDAVPlayer()
    
    init() {
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
}

