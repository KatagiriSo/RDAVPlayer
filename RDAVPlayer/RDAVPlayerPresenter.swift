//
//  RDAVPlayerPresenter.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/09/01.
//  Copyright © 2016年 rodhosSoft.
//  This software is released under the MIT License.
//

import Foundation


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
