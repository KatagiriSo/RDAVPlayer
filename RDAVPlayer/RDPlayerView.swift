//
//  RDPlayerView.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/09/01.
//  Copyright © 2016年 rodhosSoft. 
//  This software is released under the MIT License.
//

import UIKit
import AVFoundation

class RDControllerView : UIView {
    @IBOutlet weak var slider : UISlider!
}

class RDPlayerView : UIView, RDAVPlayerViewAPI
{
    @IBOutlet weak var consol: UITextView!
    @IBOutlet weak var controllerView: RDControllerView!
    @IBOutlet weak var screenView: UIView!
    
    func setup()
    {
        
    }
    
    func updatePlay()
    {
        print("updatePlay")
    }
    
    func updatePause()
    {
        print("updatePause")
    }
    
    func updateSeekValue(item:AVPlayerItem)
    {
        let time = item.currentTime().seconds
        let duration = item.duration.seconds
        let percent = time / duration
        dispatch_async(dispatch_get_main_queue(), {
            self.controllerView.slider.value = Float(percent)
            print("updateSeekValue")
        })
    }
}
