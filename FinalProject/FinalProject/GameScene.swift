import SpriteKit
import SwiftUI

enum EnemyType: String, CaseIterable {
    case green="green_balloon"
    case orange="orange_balloon"
    case pink="pink_balloon"
}

enum Collision: UInt32 {
    case player = 1
    case enemy = 2
    case bullet = 4
    case border = 8
}

struct DifficultyProperties {
    var enemy: [EnemyType: EnemyProperties]
    var spawnRate: Double
}

struct EnemyProperties {
    var enemyHealth: Int
    var enemySpeed: CGFloat
}

let easyProperties = DifficultyProperties(
    enemy: [
    
        EnemyType.green: EnemyProperties(enemyHealth: 1, enemySpeed: 80),
        EnemyType.orange: EnemyProperties(enemyHealth: 1, enemySpeed: 60),
        EnemyType.pink: EnemyProperties(enemyHealth: 2, enemySpeed: 40)
    ],
    spawnRate: 2.5)


let mediumProperties = DifficultyProperties(
    enemy: [
    
        EnemyType.green: EnemyProperties(enemyHealth: 1, enemySpeed: 90),
        EnemyType.orange: EnemyProperties(enemyHealth: 2, enemySpeed: 70),
        EnemyType.pink: EnemyProperties(enemyHealth: 2, enemySpeed: 50)
    ],
    spawnRate: 2)


let hardProperties = DifficultyProperties(
    enemy: [
        EnemyType.green: EnemyProperties(enemyHealth: 2, enemySpeed: 100),
        EnemyType.orange: EnemyProperties(enemyHealth: 3, enemySpeed: 80),
        EnemyType.pink: EnemyProperties(enemyHealth: 4, enemySpeed: 60)
    ],
    spawnRate: 1.5)

var difficultyProperties: DifficultyProperties = easyProperties

class Enemy: SKSpriteNode {
    var health: Int
    var type: EnemyType
    
    init(type: EnemyType) {
        health = difficultyProperties.enemy[type]!.enemyHealth
        
        self.type = type
            
        let texture = SKTexture(imageNamed: type.rawValue)
        super.init(texture: texture, color: .white, size: texture.size())
    }
    
    required init(coder: NSCoder) {
        fatalError("blah")
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    let players = [0: SKSpriteNode(imageNamed: "green_player"), 1: SKSpriteNode(imageNamed: "blue_player"), 2: SKSpriteNode(imageNamed: "red_player")]
    let bullets = [0: "green_laser", 1: "blue_laser", 2: "red_laser"]
    
    let analog_base = SKSpriteNode(imageNamed: "analog_base")
    let analog_button = SKSpriteNode(imageNamed: "analog_button")
        
    var player = SKSpriteNode(imageNamed: "green_player")
    var colorEncoding = 0
    var playerVelocity: CGFloat = 0.12
    var playerDx: CGFloat = 0
    var playerDy: CGFloat = 0
    
    var lastShotTime = Date()
    var isAnalogButtonActive = false
    var timer = Timer()
    
    @Published var score = 0
    @Published var numberOfLives = 5
    @Published var isGameOver = false
    
    override func didMove(to view: SKView) {        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = Collision.border.rawValue
        self.physicsBody?.collisionBitMask = Collision.player.rawValue
        
        initializeScene()
    }
    
    func newGame() {
        clearScene()
        initializeScene()
    }
    
    func clearScene() {
        timer.invalidate()
        score = 0
        isAnalogButtonActive = false
        removeAllChildren()
    }
    
    func endGame() {
        timer.invalidate()
        
        for child in children {
            if child.name == "player" || child.name == "enemy" || child.name == "bullet" {
                child.removeFromParent()
            }
        }
        
        isGameOver = true
    }
    
    func initializeScene() {
        setDifficulty()
        initializePlayer()
        setBackgroundImage()
        createJoyStick()
        
        timer = Timer.scheduledTimer(timeInterval: difficultyProperties.spawnRate, target: self, selector: #selector(spawnEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func spawnEnemy() {
        let enemyTypes = EnemyType.allCases
        let type = enemyTypes.randomElement()!
        let startLeft = [true, false].randomElement()!
        let curvedPath = [true, false].randomElement()!
        
        let enemy = Enemy(type: type)
        enemy.name = "enemy"
        enemy.size = CGSize(width: 60, height: 70)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.categoryBitMask = Collision.enemy.rawValue
        enemy.physicsBody?.collisionBitMask = Collision.player.rawValue | Collision.bullet.rawValue
        enemy.physicsBody?.contactTestBitMask = Collision.player.rawValue | Collision.bullet.rawValue
        
        var posX = frame.minX - enemy.size.width / 2
        let posY = CGFloat.random(in: (enemy.size.height / 2)...(frame.size.height - enemy.size.height / 2))
        
        if !startLeft {
            posX = frame.maxX + enemy.size.width / 2
        }
        
        enemy.position = CGPoint(x: posX, y: posY)
                
        var actions = [SKAction]()
        
        let path = UIBezierPath()
        path.move(to: enemy.position)
        
        if curvedPath {
            var p1 = CGPoint(x: position.x, y: position.y + 300)
            var endPoint = CGPoint(x: frame.maxX + 400, y: posY)
            
            if !startLeft {
                p1 = CGPoint(x: position.x, y: position.y - 400)
                endPoint = CGPoint(x: frame.minX - 500, y: 0)
            }
                        
            path.addQuadCurve(to: endPoint, controlPoint: p1)
            
            let action = SKAction.follow(path.cgPath, speed: difficultyProperties.enemy[type]!.enemySpeed)
            actions.append(action)
            
        } else {            
            var endPoint = CGPoint(x: frame.maxX + 200, y: posY)
            
            if !startLeft {
                endPoint = CGPoint(x: frame.minX - 200, y: posY)
            }
            
            path.addQuadCurve(to: endPoint, controlPoint: endPoint)
            
            let action = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: difficultyProperties.enemy[type]!.enemySpeed)
            actions.append(action)
        }
        
        actions.append(SKAction.removeFromParent())
        let seq = SKAction.sequence(actions)
        
        enemy.run(seq)
 
        addChild(enemy)
    }
    
    func setDifficulty() {
        let difficulty = UserDefaults.standard.string(forKey: "Difficulty")
        
        if difficulty == "Easy" {
            difficultyProperties = easyProperties
        } else if difficulty == "Medium" {
            difficultyProperties = mediumProperties
        } else {
            difficultyProperties = hardProperties
        }
    }
    
    func createJoyStick() {
        analog_base.position = CGPoint(x: 50, y: 50)
        analog_button.position = analog_base.position
                
        analog_base.size = CGSize(width: 75, height: 75)
        analog_button.size = CGSize(width: 30, height: 30)
        
        addChild(analog_base)
        addChild(analog_button)
    }
    
    func initializePlayer() {
        let encoding = UserDefaults.standard.integer(forKey: "Color")
        let p = players[encoding]!
        
        player = p
        player.name = "player"
        colorEncoding = encoding
        
        player.size = CGSize(width: 65, height: 45)
        player.position = CGPoint(x: frame.midX, y: frame.midY)
                
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = Collision.player.rawValue
        player.physicsBody?.collisionBitMask = Collision.enemy.rawValue | Collision.border.rawValue
        player.physicsBody?.contactTestBitMask = Collision.enemy.rawValue
        
        player.physicsBody?.isDynamic = false
                
        addChild(player)
    }
    
    func setBackgroundImage() {
        let background = SKSpriteNode(imageNamed: "sunset_background")
        
        background.position = CGPoint(x: self.size.width / 2, y: self.size.width / 2)
        background.size = self.size
        background.zPosition = -1
                
        addChild(background)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
                        
            if analog_button.frame.contains(location) {
                isAnalogButtonActive = true
                
                playerDx = 0
                playerDy = 0
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        for touch in touches {
            
            if !isAnalogButtonActive {
                continue
            }
            
            let location = touch.location(in: self)
            
            let diff = CGVector(dx: location.x - analog_base.position.x, dy: location.y - analog_base.position.y)
            let angle = CGFloat(atan2(diff.dy, diff.dx))
                        
            let maxButtonMovement = analog_base.size.height / 2
            
            let rad = (CGFloat(90) * .pi) / 180
            
            let dx = sin(angle - rad) * CGFloat(maxButtonMovement)
            let dy = cos(angle - rad) * CGFloat(maxButtonMovement)
            
            if (analog_base.frame.contains(location)) {
                analog_button.position = location
            } else {
                analog_button.position = CGPoint(x: analog_base.position.x - dx, y: analog_base.position.y + dy)
            }
            
            playerDx = diff.dx
            playerDy = diff.dy
            
            player.zRotation = angle - rad - (CGFloat(270) * .pi) / 180
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        if isAnalogButtonActive {
            analog_button.position = analog_base.position
            
            let move = SKAction.move(to: analog_base.position, duration: 1.5)
            move.timingMode = SKActionTimingMode.easeInEaseOut
            analog_button.run(move)
            
            isAnalogButtonActive = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
        if isAnalogButtonActive {
            let dx = playerDx * playerVelocity
            let dy = playerDy * playerVelocity
            
            if (player.position.x + dx < self.frame.minX) {
                player.position.x = self.frame.minX
            } else if (player.position.x + dx > self.frame.maxX) {
                player.position.x = self.frame.maxX
            } else {
                player.position.x += playerDx * playerVelocity
            }
            
            if (player.position.y + dy < self.frame.minY) {
                player.position.y = self.frame.minY
            } else if (player.position.y + dy > self.frame.maxY) {
                player.position.y = self.frame.maxY
            } else {
                player.position.y += playerDy * playerVelocity
            }
            
            
            let currentTime = Date()
            
            if currentTime.timeIntervalSinceReferenceDate - lastShotTime.timeIntervalSinceReferenceDate > 0.2 {
                let bullet = SKSpriteNode(imageNamed: bullets[colorEncoding]!)
                
                bullet.name = "bullet"
                bullet.size = CGSize(width: 15, height: 5)
                bullet.zPosition = -1
                bullet.position = player.position
                bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bullet.size.width, height: bullet.size.height))
                bullet.physicsBody?.affectedByGravity = false
                bullet.physicsBody?.categoryBitMask = Collision.bullet.rawValue
                bullet.physicsBody?.collisionBitMask = Collision.enemy.rawValue
                bullet.physicsBody?.contactTestBitMask = Collision.enemy.rawValue
                
                bullet.zRotation = player.zRotation
                
                playBulletSound()
                
                let travelDistance = frame.size.width
                let action = SKAction.move(to: CGPoint(x: travelDistance * cos(bullet.zRotation) + bullet.position.x,
                                                       y: travelDistance * sin(bullet.zRotation) + bullet.position.y), duration: 0.5)
                
                let seq = SKAction.sequence([action, .removeFromParent()])
                bullet.run(seq)
                
                lastShotTime = currentTime
                
                addChild(bullet)
            }
        }
    }
    
    func playBulletSound() {
        let sound = SKAction.playSoundFileNamed(Sound.laser.rawValue, waitForCompletion: false)
        playSound(sound: sound)
    }
    
    func playHitmarkerSound() {
        let sound = SKAction.playSoundFileNamed(Sound.hitmarker.rawValue, waitForCompletion: false)
        playSound(sound: sound)
    }
    
    func playExplosionSound() {
        let sound = SKAction.playSoundFileNamed(Sound.explosion.rawValue, waitForCompletion: false)
        playSound(sound: sound)
    }
    
    func playSound(sound: SKAction) {
        if !SceneMute.muted && !isGameOver {
            run(sound)
        }
    }
    
    func getColorFromEnemy(type: EnemyType) -> UIColor {
        switch type {
        case .green:
            return UIColor.green
        case .orange:
            return UIColor.orange
        case .pink:
            return UIColor.systemPink
        }
    }
    
    func updateScore(type: EnemyType) {
        switch type {
        case .green:
            score += 5
        case .orange:
            score += 50
        case .pink:
            score += 100
        }
    }
    
    func createExplosion(enemy: Enemy) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = enemy.position
        explosion.particleColor = getColorFromEnemy(type: enemy.type)
        addChild(explosion)
        
        playExplosionSound()
        
        run(SKAction.wait(forDuration: 1.5)) {
            explosion.removeFromParent()
        }
    }
    
    func createHitmarker(bullet: SKNode) {
        let hitmarker = SKSpriteNode(imageNamed: "hitmarker")
        hitmarker.size = CGSize(width: 25, height: 25)
        hitmarker.position = bullet.position
        let action = SKAction.fadeOut(withDuration: 0.2)
        let seq = SKAction.sequence([action, .removeFromParent()])
        
        hitmarker.run(seq)
        playHitmarkerSound()
        
        addChild(hitmarker)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        

        if (nodeA.physicsBody!.categoryBitMask | nodeB.physicsBody!.categoryBitMask) == (Collision.bullet.rawValue | Collision.enemy.rawValue) {
            var enemy: Enemy
            var bullet: SKNode
            
            if nodeA is Enemy {
                enemy = nodeA as! Enemy
                bullet = nodeB
            } else {
                enemy = nodeB as! Enemy
                bullet = nodeA
            }
        
            enemy.health -= 1
            
            if enemy.health == 0 {
                createExplosion(enemy: enemy)

                enemy.removeFromParent()
                bullet.removeFromParent()
                
                updateScore(type: enemy.type)
            }
            
            createHitmarker(bullet: bullet)
        }
        
        if (nodeA.physicsBody!.categoryBitMask | nodeB.physicsBody!.categoryBitMask) == (Collision.player.rawValue | Collision.enemy.rawValue) {
            numberOfLives -= 1
            
            var enemy: Enemy
            
            if nodeA is Enemy {
                enemy = nodeA as! Enemy
            
            } else {
                enemy = nodeB as! Enemy
            }
            
            createExplosion(enemy: enemy)
            enemy.removeFromParent()
            
            if numberOfLives == 0 {
                endGame()
            }
        }
    }
}
