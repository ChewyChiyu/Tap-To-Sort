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

enum gameState{
    case isPlaying, isPaused, isLaunched, isEnded
}
class GameViewController: UIViewController {
    
    var gameView : SCNView!
    var gameScene : SCNScene!
    
    
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
                break
            case .isPlaying:
                //starting spawn timer
                spawnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnBlocks), userInfo: nil, repeats: true)
                //starting level timer
                levelTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(handleLevel), userInfo: nil, repeats: true)
                break
            case .isEnded:
                break
            case .isPaused:
                break
            }
        }
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
                shape = SCNTorus(ringRadius: 1, pipeRadius: 0.5)
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
            
            
            //assigning color / name to ndoe
            switch(arc4random_uniform(2)){
            case 0:
                //red color
                shape?.materials.first?.diffuse.contents = UIColor(colorLiteralRed: 249/255, green: 101/255, blue: 94/255, alpha: 1)
                shape?.name = "RED"
                break
            case 1:
                //blue color
                shape?.materials.first?.diffuse.contents = UIColor(colorLiteralRed: 94/255, green: 178/255, blue: 249/255, alpha: 1)
                shape?.name = "BLUE"
                break
            default:
                break
            }
            
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
        let rightWall = gameScene.rootNode.childNode(withName: "wallRight", recursively: true)
        let leftWall = gameScene.rootNode.childNode(withName: "wallLeft", recursively: true)
        
        rightWall?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 100, length: 100, chamferRadius: 0)  , options: nil))
        
        leftWall?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 100, length: 100, chamferRadius: 0)  , options: nil))
        
        
        //handle tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gameView.addGestureRecognizer(tapGesture)
        
        //handle render , self
        gameView.delegate = self
    }
    
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
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
            nodeTouched?.node.physicsBody?.applyForce(SCNVector3(0,0,-10), asImpulse: true)
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
        
        for child in gameScene.rootNode.childNodes{
            
            //handle despawn
            if(child.geometry?.name == "RED" || child.geometry?.name == "BLUE"){
                //BLUE SECTOR of map
                if(child.presentation.position.y <= -6 && child.presentation.position.z >= -10){
                    //bottom of camera position
                    //despawning if any child is less than y -10
                    child.removeFromParentNode()
                    print(time)
                }
                //RED SECTOR of map
                
                
            }
            
            //handle lose
            
            
        }
        
        
        
        
    }
}
