//
//  GameViewController.swift
//  Tap to Sort
//
//  Created by Evan Chen on 7/1/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit


enum gameState{
    case isPlaying, isPaused, isLaunched, isEnded
}
class GameViewController: UIViewController {
    
    var gameView : SCNView!
    var gameScene : SCNScene!
    
    
    //score and score label
    
    var score = 0{
        didSet{
            //update label
            if let label = scoreLabel{
                label.text = String(score)
            }
        }
    }
    //score label
    var scoreLabel: SKLabelNode!
    
    //overlay bar
    var overLayBar : SKSpriteNode!
    
    //Timer for spawning in game objects
    var spawnTimer: Timer!
    
    //Timer to handle hardness of game
    var levelTimer : Timer!
    let maxLevel = 100
    var currentLevel = 0{
        //handle level hardness over here
        didSet{
            if(currentLevel%10==0 && currentLevel<maxLevel){
                //increase gravity/ speed
                gameScene.physicsWorld.gravity = SCNVector3(0, gameScene.physicsWorld.gravity.y*1.1,0)
            }
            if(currentLevel%20==0 && currentLevel<maxLevel){
                //increase shapes
                spawnLimit+=1
            }
        }
    }
    
    //Number of blocks to spawn at a time
    var spawnLimit = 1 // default is one
    
    //initial gravity, increase for difficulity
    var initialGravity = SCNVector3(0,-0.1,0)
    
    var state : gameState = .isLaunched{
        didSet{
            // handle game state events
            switch(state){
            case .isLaunched:
                //loading in overlay
                loadInOverlay()
                //animate overlay
                overLayBar.run(SKAction.moveBy(x: 0, y: -100, duration: 1))
                break
            case .isPlaying:
                //starting spawn timer
                spawnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnBlocks), userInfo: nil, repeats: true)
                //starting level timer
                levelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleLevel), userInfo: nil, repeats: true)
                
                break
            case .isEnded:
                //animate end sequence
                //first move score label off screen
                
                //stopping timers
                levelTimer.invalidate()
                spawnTimer.invalidate()
                
                overLayBar.run(SKAction.move(to: CGPoint(x:0,y:500), duration: 1), completion: {
                    
                    //apply reset menu overlay
                    let resetMenu = SKScene(fileNamed: "RestartMenuOverlay.sks")
                    self.gameView.overlaySKScene = resetMenu
                    self.gameView.overlaySKScene?.isUserInteractionEnabled = true // user interaction needed
                    
                    //assign nodes to var
                    let reset = resetMenu?.childNode(withName: "RestartMenu")
                    let resetLabel = reset?.childNode(withName: "Score") as? SKLabelNode
                    let resetButton = reset?.childNode(withName: "ResetButton") as? Button
                    let exitButton = reset?.childNode(withName: "ExitButton") as? Button
                    let highscoreLabel = reset?.childNode(withName: "Highscore") as! SKLabelNode
                    let highscoreButton  = reset?.childNode(withName: "HighscoreButton") as? Button
                    
                    //apply current score on resetLabel
                    resetLabel?.text = String(self.score)
                    
                    
                    //highscore config retreive from user defaults and compare / assign
                    //manage highscores
                    if let s = UserDefaults.standard.value(forKey: "highscore") {
                        if(self.score > (s as? Int)!){
                            UserDefaults.standard.set(self.score, forKey: "highscore")
                        }
                    } else {
                        //user default does not exist yet so set highscore to current rounds score
                        UserDefaults.standard.set(self.score, forKey: "highscore")
                        
                    }
                    //get highscore again and place on highscore label
                    let highscore = (UserDefaults.standard.value(forKey: "highscore") as? Int)!
                    highscoreLabel.text = String(highscore)
                    
                    
                    
                    //animate resetMenuOverlay
                    reset?.run(SKAction.move(to: CGPoint(x:0,y:0), duration: 1), completion: {
                        //reset button action
                        resetButton?.playAction = {
                            //move reset menu off screen
                            reset?.run(SKAction.move(to: CGPoint(x:0,y:500), duration: 1), completion: {
                                //restarting scores
                                self.score = 0
                                self.currentLevel = 0
                                //clearing all red and blue nodes on screen
                                for child in self.gameScene.rootNode.childNodes{
                                    if(child.geometry?.name == "RED" || child.geometry?.name == "BLUE" ){
                                        child.removeFromParentNode()
                                    }
                                }
                                //reseting game state
                                self.state =  .isLaunched
                            })
                        }
                        //exit button action
                        exitButton?.playAction = {
                            //move to menu view controller
                            let newRootViewController = self.view?.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "MenuViewController")
                            UIApplication.shared.keyWindow!.replaceRootViewControllerWith(newRootViewController!, animated: true, completion: nil)
                        }
                        //highscore button action
                        highscoreButton?.playAction = {
                            //transit from game to highscore view
                            let newRootViewController = self.view?.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "HighscoreViewController")
                            UIApplication.shared.keyWindow!.replaceRootViewControllerWith(newRootViewController!, animated: true, completion: nil)
                        }
                        
                    })
                })
                
                break
            case .isPaused:
                break
            }
        }
    }
    
    //load in overlay
    func loadInOverlay(){
        //get overlay for game, Sprite Kit
        let overLay = SKScene(fileNamed: "GamePlayOverlay.sks")
        //apply overLay on gameScene
        gameView.overlaySKScene = overLay
        //turn off user interaction
        gameView.overlaySKScene?.isUserInteractionEnabled = false
        //assign nodes from overlay to self
        overLayBar = (overLay?.childNode(withName: "OverlayBar") as? SKSpriteNode)!
        scoreLabel = (overLayBar?.childNode(withName: "Score") as? SKLabelNode)!
    }
    
    //method that increment level of game
    func handleLevel(){
        currentLevel+=1
    }
    
    //method that spawns in the game objects, linked with a timer
    func spawnBlocks(){
        
        // spawning in 1 - limit blocks
        
        for _ in 1...spawnLimit{
            var shape : SCNGeometry? = nil
            //switch arc random for a random shape
            switch(arc4random_uniform(6)){
            case 0:
                //box shape
                shape = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                break
            case 1:
                //cone shape
                shape = SCNCone(topRadius: 1, bottomRadius: 0, height: 1)
                break
            case 2:
                shape = SCNPyramid(width: 1, height: 1, length: 1)
                break
            case 3:
                shape = SCNSphere(radius: 0.5)
                break
            case 4:
                shape = SCNCapsule(capRadius: 0.5, height: 1)
                break
            case 5:
                shape = SCNCylinder(radius: 0.5, height: 2)
            default:
                break
            }
            
            //custom material
            let material = SCNMaterial()
            
            //assigning color / name to ndoe
            switch(arc4random_uniform(4)){   // 1 in 4 chance of red
            case 0:
                //red color
                shape?.materials.first?.diffuse.contents = UIColor(colorLiteralRed: 249/255, green: 101/255, blue: 94/255, alpha: 1)
                shape?.name = "RED"
                //custom red material
                material.diffuse.contents = UIImage(named: "RedMaterial.png")
                break
            default:
                //blue color
                shape?.materials.first?.diffuse.contents = UIColor(colorLiteralRed: 94/255, green: 178/255, blue: 249/255, alpha: 1)
                shape?.name = "BLUE"
                material.diffuse.contents = UIImage(named: "BlueMaterial.png")
                break
            }
            
            //applying custom material over shape geometry
            shape?.firstMaterial = material
            
            
            //assigning geometry to a node
            let shapeNode = SCNNode(geometry: shape)
            
            //assigning position to node, start at y = 10
            shapeNode.position = SCNVector3(Int(arc4random_uniform(5)),5+Int(arc4random_uniform(5)),0)
            
            //assigning physicsBody to node
            shapeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: shapeNode.geometry!, options: nil))
            shapeNode.physicsBody?.isAffectedByGravity = true
            
            //assiging node to scene
            gameScene.rootNode.addChildNode(shapeNode)
            
            //apply torque, duration: as long as object renders
            shapeNode.physicsBody?.applyForce(SCNVector3(0,-0.2,0), at: SCNVector3((shapeNode.position.x+shapeNode.scale.x*0.2),shapeNode.position.y, -(shapeNode.position.z+shapeNode.scale.z*0.4)), asImpulse: true)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load in view and scene
        gameView = self.view as? SCNView
        gameScene = SCNScene(named: "MapAlpha.scn")
        
        //set parameters for view
        //gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.showsStatistics = true
        gameView.isPlaying = true
        
        //attach game scene to view
        gameView.scene = gameScene
        
        //set the background color
        gameScene.background.contents = UIColor(colorLiteralRed: 251/255, green: 255/255, blue: 229/255, alpha: 1)
        
        //changing the speed of physicsWorld
        gameScene.physicsWorld.gravity = initialGravity
        
        
        //assigning physics to the walls
        let rightWallBlue = gameScene.rootNode.childNode(withName: "blueWallRight", recursively: true)
        let leftWallBlue = gameScene.rootNode.childNode(withName: "blueWallLeft", recursively: true)
        let rightWallRed = gameScene.rootNode.childNode(withName: "redWallRight", recursively: true)
        let leftWallRed = gameScene.rootNode.childNode(withName: "redWallLeft", recursively: true)
        
        rightWallBlue?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 100, length: 100, chamferRadius: 0)  , options: nil))
        
        leftWallBlue?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 100, length: 100, chamferRadius: 0)  , options: nil))
        
        //applying custom material to walls
        let materialRed = SCNMaterial()
        materialRed.diffuse.contents = UIImage(named: "RedMaterial")
        rightWallRed?.geometry?.materials = [materialRed]
        leftWallRed?.geometry?.materials = [materialRed]
        
        let materialBlue = SCNMaterial()
        materialBlue.diffuse.contents = UIImage(named: "BlueMaterial")
        rightWallBlue?.geometry?.materials = [materialBlue]
        leftWallBlue?.geometry?.materials = [materialBlue]
        
        
        
        
        //handle render , self
        gameView.delegate = self
        
        //setting game state to launch
        state = .isLaunched
        
    }
    
    
    
    //handling touches in game
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if gameState is launched then transit to play
        if(state == .isLaunched){
            state = .isPlaying
        }
        // if gameState is playing then apply impulse if touched block
        if(state == .isPlaying){
            //hit test
            let nodeTouched = gameView.hitTest((touches.first?.location(in: gameView))!, options: nil).first
            nodeTouched?.node.physicsBody?.applyForce(SCNVector3(0,0,-4), asImpulse: true)
            
            //lose / point handle
            if(nodeTouched?.node.geometry?.name == "RED"){
                //Yes sort correct, increment score
                score+=1
            }
            if(nodeTouched?.node.geometry?.name == "BLUE"){
                //No sort incorrect, lose
                state = .isEnded
            }
            
        }
        
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
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
    
}


extension GameViewController : SCNSceneRendererDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //handle despawn / lose / score here
        
        //Looping through all the nodes current in the gameScene
        for child in gameScene.rootNode.childNodes{
            
            //handle despawn
            if(child.geometry?.name == "RED" || child.geometry?.name == "BLUE"){
                //BLUE SECTOR of map
                if(child.presentation.position.y <= -6 && child.presentation.position.z >= -5){
                    
                    //If RED falls in BLUE SECTOR -> LOSE
                    
                    if(child.geometry?.name=="RED"){
                        state = .isEnded
                    }
                    
                    //bottom of camera position
                    //despawning if any child is less than y -6
                    child.removeFromParentNode()
                }
                //RED SECTOR of map
                if(child.presentation.position.y <= -50 && child.presentation.position.z <= -30){
                    
                    //If BLUE falls in RED SECTOR -> LOSE
                    
                    if(child.geometry?.name=="BLUE"){
                        state = .isEnded
                    }
                    //bottom of camera position
                    //despawning if any child is less than y -50
                    child.removeFromParentNode()
                }
                
            }
            
            
            
            
        }
    }
}
