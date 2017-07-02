//
//  Menu.swift
//  Tap to Sort
//
//  Created by Evan Chen on 7/1/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
class Menu : SKScene{
    
    var playButton : Button!
    var highscoreButton: Button!
    
    override func didMove(to view: SKView) {
        
        //assigning nodes
        playButton = self.childNode(withName: "PlayButton") as? Button
        highscoreButton = self.childNode(withName: "HighscoreButton") as? Button
        
        
        //assigning handlers
        playButton.playAction = {
            //transit from menu to game
            let newRootViewController = self.view?.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "GameViewController")
            UIApplication.shared.keyWindow!.replaceRootViewControllerWith(newRootViewController!, animated: true, completion: nil)
            
        }
        
        highscoreButton.playAction = {
            //transit from game to highscore view
            let newRootViewController = self.view?.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "HighscoreViewController")
            UIApplication.shared.keyWindow!.replaceRootViewControllerWith(newRootViewController!, animated: true, completion: nil)
        }
        
    }
    
    
    
}

