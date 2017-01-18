//
//  GameScene.swift
//  PokèFlap
//
//  Created by Ryan Soltes on 1/19/16.
//  Copyright (c) 2016 WookieApps. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate
{
    // ALL VARIABLES FOR GAME
    var logo = SKSpriteNode()
    var playButton = SKSpriteNode()
    var bg = SKSpriteNode();
    var bird = SKSpriteNode();
    var score = 0
    var scoreLabel = SKLabelNode()
    var pipe1 = SKSpriteNode();
    var pipe2 = SKSpriteNode();
    var gameOverLabel = SKSpriteNode()
    var highscore: Int = 0
    var highscoreLabel = SKLabelNode()
    var movingObjects = SKSpriteNode()
    var labelObjects = SKSpriteNode()
    var LabelContainer = SKSpriteNode()
    var gameOver = false
    var player: AVAudioPlayer = AVAudioPlayer()
    enum ColliderType: UInt32
    {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    override func didMoveToView(view: SKView)
    {
        // SETS UP TITLE SCREEN BEFORE SCREEN IS TAPPED
        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        self.addChild(labelObjects)
        self.addChild(LabelContainer)
        makeBG()
        makeGround()
        makeMusic()
        makeBird()
        makeLogo()
        makePlayButton()
        bird.alpha = 0
        bird.physicsBody!.dynamic = false
        
        // CREATES CURRENT SCORE LABEL
        labelObjects.alpha = 100
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 90
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-120)
        scoreLabel.zPosition = 6
        scoreLabel.alpha = 0
        addChild(scoreLabel)
        
        // CREATES HIGHSCORE LABEL
        highscoreLabel.fontName = "Helvetica-Bold"
        highscoreLabel.fontSize = 30
        highscoreLabel.text = "Highscore: \(highscore)"
        highscoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-40)
        highscoreLabel.zPosition = 9
        highscoreLabel.alpha = 0
        addChild(highscoreLabel)
        
        // TIMER FOR PIPE SPAWN
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
    }
    
    func makeLogo()
    {
        // CREATES POKEFLAP IMAGE
        let logoTexture = SKTexture(imageNamed: "pokeflap2.png")
        logo = SKSpriteNode(texture: logoTexture)
        logo.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
        logo.zPosition = 5
        labelObjects.addChild(logo)
    }
    
    func makePlayButton()
    {
        // CREATES TAP TO PLAY IMAGE
        let logoTexture2 = SKTexture(imageNamed: "play2.png")
        playButton = SKSpriteNode(texture: logoTexture2)
        playButton.name = "playButton"
        playButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-50)
        playButton.zPosition = 6
        labelObjects.addChild(playButton)
    }

    func makeBG()
    {
        // BACKGROUND
        let bgTexture = SKTexture(imageNamed: "background.png")
        let moveBG = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBG = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBGForever = SKAction.repeatActionForever(SKAction.sequence([moveBG, replaceBG]))
        
        for var i: CGFloat = 0; i < 3; i++
        {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            bg.zPosition = 1
            bg.runAction(moveBGForever)
            movingObjects.addChild(bg)
        }
    }

    func makeGround()
    {
        // GROUND
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 0.05))
        ground.physicsBody!.dynamic = false
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        addChild(ground)
    }
    
    func makeBird()
    {
        // BIRD
        let birdTexture = SKTexture(imageNamed: "pidgey1.png")
        let birdTexture2 = SKTexture(imageNamed: "pidgey2.png")
        let animation = SKAction.animateWithTextures([birdTexture,birdTexture2] , timePerFrame: 0.06)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture);
        bird.position = CGPoint(x: CGRectGetMidX(self.frame)-10, y: CGRectGetMidY(self.frame))
        bird.zPosition = 2
        bird.runAction(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.dynamic = true
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        movingObjects.addChild(bird)
    }
    
    func makePipes()
    {
        // PIPES
        let gapHeight = bird.size.height*3
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        let movePipes = SKAction.moveByX(-frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveRemovePipes = SKAction.sequence([movePipes,removePipes])
        
        // PIPE 1
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.zPosition = 2
        pipe1.runAction(moveRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe1.physicsBody!.dynamic = false
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        movingObjects.addChild(pipe1)
        
        //PIPE 2
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeTexture2.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.zPosition = 3
        pipe2.runAction(moveRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture2.size())
        pipe2.physicsBody!.dynamic = false
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        movingObjects.addChild(pipe2)
        
        // GAP
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.zPosition = 4
        gap.runAction(moveRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody!.dynamic = false
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        movingObjects.addChild(gap)
    }
    
    func makeGO()
    {
        // CREATES GAMEOVER IMAGE
        let logoTexture = SKTexture(imageNamed: "gameover.png")
        gameOverLabel = SKSpriteNode(texture: logoTexture)
        gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+25)
        gameOverLabel.zPosition = 7
        LabelContainer.addChild(gameOverLabel)
        
    }

    func getHighscore()
    {
        // SETS HIGHSCORE
        if score > highscore
        {
            highscore = score
            highscoreLabel.text = String("Highscore: \(highscore)")
            print(highscore)
        }
    }
    
    func makeMusic()
    {
        // BACKGROUND MUSIC
        let audioPath = NSBundle.mainBundle().pathForResource("pokemon", ofType: "mp3")!
        do
        {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
            player.numberOfLoops = -1
            player.play()
        }
        catch
        {
            //IT WILL ALWAYS WORK
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        // HANDLES CONTACT WITH OBJECTS
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
        {
            score++
            scoreLabel.text = String(score)
        }
        else
        {
            // STOPS BG BRINGS UP GAMEOVER MESSAGE
            if gameOver == false
            {
                gameOver = true
                self.speed = 0
                makeGO()
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        labelObjects.alpha = 0
        
        if gameOver == false
        {
            // WHEN YOU TOUCH THE SCREEN
            // AND YOU DO NOT HIT GROUND OR PIPE
            scoreLabel.alpha = 100
            highscoreLabel.alpha = 100
            bird.alpha = 100
            bird.physicsBody!.dynamic = true
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 100))
        }
        else
        {
            // WHEN YOU HIT THE GROUND OR A PIPE
            getHighscore()
            score = 0
            scoreLabel.text = "0"
            bird.position = CGPointMake(CGRectGetMidX(self.frame)-10, CGRectGetMidY(self.frame))
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            movingObjects.removeAllChildren()
            makeBG()
            makeBird()
            self.speed = 1
            gameOver = false
            LabelContainer.removeAllChildren()
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
    }
}