//
//  RDPlayerView.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/09/01.
//  Copyright © 2016年 rodhosSoft. 
//  This software is released under the MIT License.
//

import UIKit

class RDPlayerView : UIView, RDAVPlayerViewAPI
{
    @IBOutlet weak var consol: UITextView!
    @IBOutlet weak var controllerView: UIView!
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
    
    func updateSeekValue()
    {
        print("updateSeekValue")
    }
}
