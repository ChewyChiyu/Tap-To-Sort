//
//  HighscoreViewController.swift
//  Tap to Sort
//
//  Created by Evan Chen on 7/2/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class HighscoreViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

