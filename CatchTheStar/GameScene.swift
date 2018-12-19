//
//  GameScene.swift
//  CatchTheStar
//
//  Created by TA Trung Thanh on 19/12/2018.
//  Copyright © 2018 TA Trung Thanh. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene:  SKScene, SKPhysicsContactDelegate {
    weak var viewController: GameViewController!
    weak var gameOverView: GameOverView!
    
    var isGameOver = false
    
    var cmMngr : CMMotionManager!
    
    var gameArea: CGRect
    var gameScore = 0
    
    var gameTimer = TimeInterval()
    var gameInt = 20

    let timeLabel = SKLabelNode(fontNamed: "Avenir-Black")
    let scoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
    
    var timeStone = 0.0
    
    let etoile = SKSpriteNode(imageNamed: "Etoile")
    let bille = SKSpriteNode(imageNamed: "Bille")
    let backGround = SKSpriteNode(imageNamed: "Fond1")
    let themeSound = SKAction.playSoundFileNamed("midnight-ride-01a.mp3", waitForCompletion: false)
    let gameoverSound = SKAction.playSoundFileNamed("son-etoile.mp3", waitForCompletion: false)
    let hitwallSound = SKAction.playSoundFileNamed("son.mp3", waitForCompletion: false)
    let pointSound = SKAction.playSoundFileNamed("squeeze-toy-1.mp3", waitForCompletion: false)
    
    struct physicsCategories{
        static let None: UInt32 = 0
        static let Etoile: UInt32 = 0b1 //1
        static let Bille: UInt32 = 0b10 //2
        static let Wall: UInt32 = 0b100 //4
    }
    
    override init(size: CGSize) {
        gameArea = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gameTimer = 0
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //this function will run as soon as the screen load up
    override func didMove(to view: SKView) {
        //to handle contact
        self.physicsWorld.contactDelegate = self
        
        //set the background in the depth (it must be the lowest in the stack)
        backGround.size = self.size
        backGround.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backGround.zPosition = 0
        self.addChild(backGround)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        scoreLabel.position = CGPoint(x: self.size.width*0.95, y: self.size.height*0.95)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        timeLabel.fontSize = 100
        timeLabel.fontColor = SKColor.white
        timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        timeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        timeLabel.position = CGPoint(x: self.size.width/2 - 30, y: self.size.height*0.95)
        timeLabel.zPosition = 100
        self.addChild(timeLabel)
        
        bille.setScale(3)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        startNewLevel()
        
        
        cmMngr = CMMotionManager()
        cmMngr.startAccelerometerUpdates()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //contact hold the informations about 2 body contact to each other
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }//after this, the body with lower categoryBitMask asign to body1
        
        //etoile hit bille
        if body1.categoryBitMask == physicsCategories.Etoile && body2.categoryBitMask == physicsCategories.Bille {//if player hit asterroide
            //delete bille
            body2.node?.removeFromParent()
            addScore()
            spawnBille()
        }
    }
    
    
    func startNewLevel() {
        gameTimer = 20
        if self.action(forKey: "newLevel") != nil {
            self.removeAction(forKey: "newLevel")
        }
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        etoile.removeFromParent()
        spawnEtoile()
        spawnBille()
        gameScore = 0
        scoreLabel.text = "Score: \(gameScore)"
        let end = SKAction.run(endGame)
        let waitToCountDown = SKAction.wait(forDuration: gameTimer)
        let endSequence = SKAction.sequence([themeSound, waitToCountDown, end])
        self.run(endSequence, withKey: "newLevel")
        startCountDown()
    }
    
    
    func startCountDown() {
        if self.action(forKey: "countDonw") != nil {
            self.removeAction(forKey: "countDonw")
        }
        let wait1 = SKAction.wait(forDuration: 1)
        let update = SKAction.run(updateClock)
        let updateClockSequence = SKAction.sequence([wait1, update])
        self.run(SKAction.repeat(updateClockSequence, count: gameInt))
    }
    
    func updateClock() {
        gameInt -= 1
        timeLabel.text = String(gameInt)
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
    }
    
    
    func spawnEtoile() {
        etoile.setScale(1.8)
        etoile.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        etoile.zPosition = 2
        etoile.physicsBody = SKPhysicsBody(rectangleOf: etoile.size)
        etoile.physicsBody!.affectedByGravity = true
        etoile.physicsBody!.categoryBitMask = physicsCategories.Etoile
        etoile.physicsBody!.collisionBitMask = physicsCategories.None //Ignore all other objects
        etoile.physicsBody!.contactTestBitMask = physicsCategories.Bille | physicsCategories.Wall//Only contact with bille
        //Assign spaceship to the right category (to make it interact with only the right object)
        self.addChild(etoile)
    }
    
    
    func spawnBille() {
        //start at a random in the top and move to a random point at the bottom
        let randomXStart = Float.random(in: Float(gameArea.minX) ... Float(gameArea.maxX))
        let randomYStart = Float.random(in: Float(gameArea.minY) ... Float(gameArea.maxY))
        let startPoint = CGPoint(x: CGFloat(randomXStart), y: CGFloat(randomYStart))
        //NSLog(asteroidString)
        bille.position = startPoint
        bille.zPosition = 2
        bille.physicsBody = SKPhysicsBody(circleOfRadius: bille.size.width/2)
        bille.physicsBody!.affectedByGravity = false
        bille.physicsBody!.categoryBitMask = physicsCategories.Bille
        bille.physicsBody!.collisionBitMask = physicsCategories.None //Ignore all other objects
        bille.physicsBody!.contactTestBitMask = physicsCategories.Etoile //only colide with Etoile
        self.addChild(bille)
        
        //make it spin!
        let randomInt = Int.random(in: -1 ... 1)
        bille.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi * Double(randomInt)), duration: 1)))
    }
    
    func endGame() {
        etoile.removeFromParent()
        bille.removeFromParent()
        //stop the game
        if self.action(forKey: "newLevel") != nil {
            self.removeAction(forKey: "newLevel")
            //stop catching motion
            cmMngr.stopAccelerometerUpdates()
        }
        viewController.gameOverView?.isHidden = false
    }
    
    //handle movement of etoile
    @objc func updatePosition(_ currentTime: TimeInterval) {
        if let accelerometerData = cmMngr.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        if let accelerometerData = cmMngr.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        if etoile.position.x > gameArea.maxX - etoile.size.width/2 - 20{
            etoile.position.x = gameArea.maxX - etoile.size.width/2 - 20
        }
        if etoile.position.x < gameArea.minX + etoile.size.width/2 + 20{
            etoile.position.x = gameArea.minX + etoile.size.width/2 + 20
        }
        
        if etoile.position.y > gameArea.maxY - etoile.size.height/2 - 30{
            etoile.position.y = gameArea.maxY - etoile.size.height/2 - 30
        }
        if etoile.position.y < gameArea.minY + etoile.size.height/2 + 30{
            etoile.position.y = gameArea.minY + etoile.size.height/2 + 30
        }
    }
}
