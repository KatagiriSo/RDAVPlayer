//
//  ViewController.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/08/10.
//  Copyright © 2016年 rodhosSoft.
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
    }
    
    
    private func setup() {
        let mvc = RDAVPlayer()
        mvc.view.frame = self.view.bounds
        mvc.view.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(mvc.view)
        self.addChildViewController(mvc)
    }
    
}

