//
//  Menu.swift
//  Tap to Sort
//
//  Created by Evan Chen on 7/1/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit

class Menu : SKScene{
    
    var playButton : Button!
    
    override func didMove(to view: SKView) {
        
        //assigning nodes
        playButton = self.childNode(withName: "PlayButton") as? Button
        
        
        
        //assigning handlers
        playButton.playAction = {
            //transit from menu to game
            self.view!.window!.rootViewController!.performSegue(withIdentifier: "MenuToGame", sender: self)
        }
        
        
    }
    
    
    
}
