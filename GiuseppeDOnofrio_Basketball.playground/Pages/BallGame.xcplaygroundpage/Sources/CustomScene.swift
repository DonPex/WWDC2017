import Foundation
import SpriteKit
import AVFoundation

let dimScene = CGSize(width: 500, height: 700)
let dimGameOver = CGSize(width: 480, height: 500)
let physicFrame = CGRect(x: 0, y: 0, width: 500, height: 2500)
let ballCategory: UInt32 = 1
let detectorCategory: UInt32 = 2
let floorCategory: UInt32 = 3
let ringCategory: UInt32 = 5


public class CustomScene: SKScene, SKPhysicsContactDelegate {
    var ballTouched: Bool = false
    var isScoring: Bool = false
    var towardsLeft: Bool = false
    var gameEnded: Bool = false
    
    var prevTouchTimestamp: TimeInterval = 0.0
    var ballSpeed: Double = 0.0
    var score: Int = 0
    
    var bouncePlayer: AVAudioPlayer?
    var rimPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?
    
    var timerValue: Int = 0
    let gameOverWindow = SKShapeNode(rectOf: dimGameOver, cornerRadius: 10)
    let gameOverLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
    let restartButton = SKLabelNode(fontNamed: "MarkerFelt-Wide")

    let background = SKSpriteNode(imageNamed: "background.png")
    let backboard = SKSpriteNode(imageNamed: "backboard.png")
    let ring = SKSpriteNode(imageNamed: "Ring.png")
    let net = SKSpriteNode(imageNamed: "basket_net.png")
    let detector = SKSpriteNode(color: .clear, size: CGSize(width: 68, height: 5))
    let limitLine = SKSpriteNode(color: .white, size: CGSize(width: dimScene.width, height: 1))
    let ball = SKSpriteNode(imageNamed: "basketball.png")
    let scoreLabel = SKLabelNode(text: "SCORE: 0")
    let timerLabel = SKLabelNode(text: "Time left: 60")
    
    let sxExtreme = SKSpriteNode(color: .clear, size: CGSize(width: 3, height: 3))
    let dxExtreme = SKSpriteNode(color: .clear, size: CGSize(width: 3, height: 3))
    
    
    required public override init() {
        super.init(size: dimScene)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: physicFrame)
        self.physicsBody?.categoryBitMask = floorCategory
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        self.physicsWorld.speed = 5
        self.createScene()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTimer() {
        let wait = SKAction.wait(forDuration: 1)
        let block = SKAction.run({
            [unowned self] in
            
            if self.timerValue > 0{
                self.timerValue -= 1
                if self.timerValue < 10 {
                    self.timerLabel.fontColor = SKColor.red
                }
            }
            else{
                self.removeAction(forKey: "countdown")
                self.gameOver()
            }
        })
        
        let sequence = SKAction.sequence([wait,block])
        run(SKAction.repeatForever(sequence), withKey: "countdown")

    }
    
    public func createScene() {

        
        ball.name = "Ball"
        ball.size = CGSize(width: 60, height: 60)
        ball.position = CGPoint(x: self.size.width/2, y: ball.frame.size.height/2)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        ball.physicsBody?.restitution = 0.8
        ball.physicsBody?.friction = 0.5
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.collisionBitMask = 1
        ball.physicsBody?.contactTestBitMask = detectorCategory
        //scene.physicsWorld.body(in: CGRect(x: 0, y: 0, width: 400, height: 600))
        
        backboard.name = "BackboardNode"
        backboard.size = CGSize(width: 300, height: 187.5)
        backboard.position.x = self.frame.width/2
        backboard.position.y = self.frame.height - 200
//        backboard.setScale(CGFloat(1.5))
        
        ring.name = "BackboardNode"
        ring.size = CGSize(width: 104.25, height: 5.25)
        ring.position.x = self.frame.width/2
        ring.position.y = backboard.position.y - 78
        ring.zPosition = CGFloat(integerLiteral: 1)
//        ring.setScale(CGFloat(1.5))
        
        detector.name = "BackboardNode"
        detector.physicsBody = SKPhysicsBody(rectangleOf: detector.size)
        detector.physicsBody?.collisionBitMask = 0
        detector.physicsBody?.categoryBitMask = detectorCategory
        detector.physicsBody?.contactTestBitMask = ballCategory
        detector.physicsBody?.affectedByGravity = false
        detector.position = ring.position
        detector.zPosition = CGFloat(integerLiteral: 2)
        
        net.name = "BackboardNode"
        net.size = CGSize(width: 98.25, height: 74.25)
        net.position.x = self.frame.width/2
        net.position.y = ring.position.y - 37
        net.zPosition = CGFloat(integerLiteral: 1)
//        net.setScale(CGFloat(1.5))
        
        limitLine.position.x = self.frame.width/2
        limitLine.position.y = self.frame.height/2
        
        sxExtreme.name = "BackboardNode"
        sxExtreme.physicsBody = SKPhysicsBody(circleOfRadius: 1.5)
        sxExtreme.physicsBody?.isDynamic = false
        sxExtreme.physicsBody?.categoryBitMask = ringCategory
        sxExtreme.physicsBody?.contactTestBitMask = ballCategory
        sxExtreme.position.x = ring.position.x - ring.size.width/2
        sxExtreme.position.y = ring.position.y
        
        dxExtreme.name = "BackboardNode"
        dxExtreme.physicsBody = SKPhysicsBody(circleOfRadius: 1.5)
        dxExtreme.physicsBody?.isDynamic = false
        dxExtreme.physicsBody?.categoryBitMask = ringCategory
        dxExtreme.physicsBody?.contactTestBitMask = ballCategory
        dxExtreme.position.x = ring.position.x + ring.size.width/2
        dxExtreme.position.y = ring.position.y
        
        background.position.x = self.frame.size.width/2
        background.position.y = self.frame.size.height/2
        background.colorBlendFactor = 1
        background.color = .blue
        
        scoreLabel.name = "Score"
        scoreLabel.text = "SCORE: \(score)"
        scoreLabel.fontSize = 30
        scoreLabel.fontName = "MarkerFelt-Wide"
        scoreLabel.position.x = self.frame.width/2
        scoreLabel.position.y = backboard.position.y + backboard.frame.size.height/2 + 20
        
        timerLabel.name = "Timer"
        timerLabel.fontName = "MarkerFelt-Wide"
        timerLabel.fontColor = SKColor.white
        timerLabel.fontSize = 40
        timerLabel.position.x = self.frame.width/2
        timerLabel.position.y = self.frame.height - 50
        
        self.setTimer()
        self.timerValue = 15
        self.playSound("charge")
        self.addChild(background)
        self.addChild(backboard)
        self.addChild(ring)
        self.addChild(sxExtreme)
        self.addChild(dxExtreme)
        self.addChild(net)
        self.addChild(limitLine)
        self.addChild(detector)
        self.addChild(scoreLabel)
        self.addChild(timerLabel)
        self.addChild(ball)

    }

    func gameOver() {
        self.removeAllChildren()
        self.removeAllActions()
        self.gameEnded = true
        
        gameOverWindow.position.x = self.frame.width/2
        gameOverWindow.position.y = self.frame.height/2
        gameOverWindow.fillColor = SKColor.black
        
        gameOverLabel.text = "TIME UP! You have scored \(score) points"
        gameOverLabel.fontSize = 30
        gameOverLabel.position.x = gameOverWindow.position.x
        gameOverLabel.position.y = gameOverWindow.position.y + 50
        
        restartButton.text = "RESTART"
        restartButton.fontColor = UIColor.red
        restartButton.position.x = gameOverWindow.position.x
        restartButton.position.y = gameOverWindow.position.y - 50
        
        addChild(gameOverWindow)
        addChild(gameOverLabel)
        addChild(restartButton)

    }
    
    func playSound(_ audioUrl: String) {
        let url = Bundle.main.url(forResource: audioUrl, withExtension: "mp3")!

        do {
            if audioUrl == "bounce" {
                bouncePlayer = try AVAudioPlayer(contentsOf: url)
                guard let bouncePlayer = bouncePlayer else { return }
                
                bouncePlayer.play()

            }
            else if audioUrl == "charge" {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                guard let musicPlayer = musicPlayer else { return }
                musicPlayer.play()
            }
            else {
                rimPlayer = try AVAudioPlayer(contentsOf: url)
                guard let rimPlayer = rimPlayer else { return }
                rimPlayer.play()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
//            self.enumerateChildNodes(withName: "Ball", using: { (node, stop) in
//                let ball = node as! SKSpriteNode
                let location = touch.location(in: self)
            if !gameEnded {
                if ball.contains(location) {
                    self.ballTouched = true
                    self.prevTouchTimestamp = touch.timestamp
                    ball.physicsBody?.affectedByGravity = false
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
                else if restartButton.contains(location) {
                    self.removeAllChildren()
                    self.removeAllActions()
                    self.score = 0
                    self.gameEnded = false
                    self.createScene()
            }
            
//            })
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
//            self.enumerateChildNodes(withName: "Ball", using: { (node, stop) in
//                let ball = node as! SKSpriteNode
            
                
                if self.ballTouched {
                    let location = touch.location(in: self)
                    if location.y > self.frame.height/2 {
                        self.touchesEnded(touches, with: event)
                        return
                    }
                    let prevLocation = touch.previousLocation(in: self)
                    let distanceBetweenLoc = self.calcDistance(a: location, b: prevLocation)
                    let timeInterval = (touch.timestamp - self.prevTouchTimestamp)
                    
                    self.ballSpeed = distanceBetweenLoc / (timeInterval*1000)
                    
                    if self.contains(location) {
                        ball.position.x = location.x
                        ball.position.y = location.y
                    }
                    
//                    print(self.ballSpeed)
                    
                    self.prevTouchTimestamp = touch.timestamp

                }
//            })
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ballTouched {
            ballTouched = false

            if let touch = touches.first {
//                self.enumerateChildNodes(withName: "Ball", using: { (node, stop) in
//                    let ball = node as! SKSpriteNode
                    let xDirection = touch.location(in: self).x - touch.previousLocation(in: self).x
                    let yDirection = touch.location(in: self).y - touch.previousLocation(in: self).y
                    
                    ball.physicsBody?.affectedByGravity = true
                    ball.physicsBody?.velocity = CGVector(dx: Double(xDirection) * self.ballSpeed, dy: Double(yDirection) * self.ballSpeed)

//            })
            }
        }
    }

    public override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if secondBody.categoryBitMask == ballCategory && firstBody.categoryBitMask == detectorCategory{
            if Float((secondBody.node?.position.y)!) > Float((firstBody.node?.position.y)!) {
                isScoring = true
            }
        }
    }
    
    public func didEnd(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == floorCategory || secondBody.categoryBitMask == floorCategory {  //play bounce audio effect
            self.playSound("bounce")
        }
            
        else if firstBody.categoryBitMask == ringCategory || secondBody.categoryBitMask == ringCategory {
            self.playSound("rim")
        }
        
        else if secondBody.categoryBitMask == ballCategory && firstBody.categoryBitMask == detectorCategory{
            if isScoring && Float((secondBody.node?.position.y)!) < Float((firstBody.node?.position.y)!) {  //point scored
                isScoring = false
                score += 1
//                self.enumerateChildNodes(withName: "Score", using: { (node, stop) in
//                    let scoreLabel = node as! SKLabelNode
                    scoreLabel.text = "SCORE: \(self.score)"
                    self.playSound("Swish")
//                })
            }
            else {  //the ball was entering in the net but something went wrong...
                isScoring = false
            }
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        self.moveBackboard()
//        self.enumerateChildNodes(withName: "Timer") { (node, stop) in
//            let timerLabel = node as! SKLabelNode
        timerLabel.text = "Time left: \(self.timerValue)"
    }
    

    func calcDistance(a: CGPoint, b: CGPoint) -> Double {
        var distance: Double = 0.0
        distance = sqrt( Double(pow((a.x - b.x), 2) + pow((a.y - b.y), 2)))
        return distance
    }
    
    func moveBackboard() {
        self.enumerateChildNodes(withName: "BackboardNode") { (bbnode, stop) in
            let backboard = bbnode as! SKSpriteNode
            
            if self.frame.width == backboard.position.x + backboard.frame.size.width/2 {
                self.towardsLeft = true
            }
            else if backboard.position.x - backboard.frame.size.width/2 == 0 {
                self.towardsLeft = false
            }
            
            if self.towardsLeft {
                backboard.position.x -= 1
            }
            else {
                backboard.position.x += 1
            }
        }
    }

}
