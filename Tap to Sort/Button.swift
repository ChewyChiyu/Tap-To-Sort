//
//  Button.swift
//  Tap to Sort
//
//  Created by Evan Chen on 7/1/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit

enum ButtonStates{
    case sleep ,  active
}


class Button : SKSpriteNode {
    
    var alreadyPressed: Bool =  false
    
    var buttonState : ButtonStates = .sleep{
        didSet{
            if(buttonState == ButtonStates.sleep){
                self.alpha = 1
            }
            if(buttonState == ButtonStates.active){
                self.alpha = 0.7
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonState = .active
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonState = .sleep
        if(!alreadyPressed){
            playAction()
            alreadyPressed = true
        }
    }
    var playAction: () -> Void = {}
    
}
