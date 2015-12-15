//
//  GameScene.swift
//  LD34
//
//  Created by Nikolay Petrov on 12/12/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol PositionRandomGenerator {
    func nextPosition() -> Int
}

@available(OSX 10.11, *)
class ShuffledRandomGenerator: PositionRandomGenerator {
    let positionGenerator: GKShuffledDistribution = GKShuffledDistribution(forDieWithSideCount: 10)
    
    func nextPosition() -> Int {
        return positionGenerator.nextInt()
    }
}

class BasicRandomGenerator: PositionRandomGenerator {
    func nextPosition() -> Int {
        return (abs(random()) % 10) + 1
    }
}

class GameScene: SKScene {
    var game: Game!
    
    var beeTexuture: SKTexture!
    var beeRevTexuture: SKTexture!
    var beeFlyTexuture: SKTexture!
    var beeFlyRevTexuture: SKTexture!
    
    var beeNode: SKSpriteNode!
    var flowerNodes: [SKSpriteNode] = []
    var pointsNode: SKLabelNode!
    
    var points: Double = 0
    var currentSpeed: CGFloat = 50
    
    var positionRandomGenerator: PositionRandomGenerator!
    
    override func didMoveToView(view: SKView) {
        if #available(OSX 10.11, *) {
            positionRandomGenerator = ShuffledRandomGenerator()
        } else {
            positionRandomGenerator = BasicRandomGenerator()
        }
        
        physicsWorld.contactDelegate = self
        
        beeTexuture = SKTexture(imageNamed: "Bee")
        beeRevTexuture = SKTexture(imageNamed: "BeeRev")
        beeFlyTexuture = SKTexture(imageNamed: "BeeFly")
        beeFlyRevTexuture = SKTexture(imageNamed: "BeeFlyRev")
        
        beeNode = childNodeWithName("Bee") as! SKSpriteNode
        pointsNode = childNodeWithName("Points") as! SKLabelNode
        
        let waitGen = SKAction.sequence([SKAction.waitForDuration(3), SKAction.runBlock(generateFloweNode)])
        let waitGen3 = SKAction.repeatAction(waitGen, count: 5)
        let waitGenInc = SKAction.sequence([waitGen3, SKAction.runBlock(increaseSpeed)])
        runAction(SKAction.repeatActionForever(waitGenInc))
        
        generateFloweNode()
    }
    
    override func willMoveFromView(view: SKView) {
        removeAllActions()
    }
    
    func generateFloweNode() {
        let xpos = CGFloat(positionRandomGenerator.nextPosition() * 120)
        
        let flowerNode = SKSpriteNode(imageNamed: "Flower")
        flowerNode.name = "Flower"
        flowerNode.zPosition = 3
        flowerNode.position = CGPointMake(xpos, -20)
        
        let stalkNode = SKSpriteNode(imageNamed: "Stalk")
        stalkNode.position = CGPointMake(0, -50)
        flowerNode.addChild(stalkNode)
        
        let flowerPhysics = SKPhysicsBody(rectangleOfSize: CGSizeMake(flowerNode.size.width / 2, 10), center: CGPoint(x: 0.5, y: -15))
        flowerPhysics.affectedByGravity = false
        flowerPhysics.allowsRotation = false
        
        flowerPhysics.velocity = CGVectorMake(0, currentSpeed)
        flowerPhysics.mass = 10000
        flowerPhysics.friction = 1.0
        flowerPhysics.restitution = 0
        
        flowerPhysics.categoryBitMask = 4
        flowerPhysics.collisionBitMask = 2
        flowerPhysics.contactTestBitMask = 10
        
        flowerNode.physicsBody = flowerPhysics
        
        addChild(flowerNode)
        flowerNodes.append(flowerNode)
    }
    
    func increaseSpeed() {
        currentSpeed += 10
    }

    var leftPressed = false
    var rightPressed = false
    var upPressed = false
    
    #if os(OSX)
    override func keyDown(theEvent: NSEvent) {
        let velocity = beeNode.physicsBody!.velocity

        switch theEvent.keyCode {
        case 123:
            if !leftPressed && velocity.dx > -350 {
                beeNode.physicsBody!.applyImpulse(CGVectorMake(-40, 10))
                beeNode.runAction(SKAction.playSoundFileNamed("SideJumpSound.wav", waitForCompletion: false))
            }
            leftPressed = true
        case 124:
            if !rightPressed && velocity.dx < 350 {
                beeNode.physicsBody!.applyImpulse(CGVectorMake(40, 10))
                beeNode.runAction(SKAction.playSoundFileNamed("SideJumpSound.wav", waitForCompletion: false))
            }
            rightPressed = true
        case 126:
            if !upPressed && velocity.dy < 250 {
                beeNode.physicsBody!.applyImpulse(CGVectorMake(0, 100))
                beeNode.runAction(SKAction.playSoundFileNamed("JumpSound.wav", waitForCompletion: false))
            }
            upPressed = true
        default:
            print("???: \(theEvent.keyCode)")
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        switch theEvent.keyCode {
        case 123:
            leftPressed = false
        case 124:
            rightPressed = false
        case 126:
            upPressed = false
        default:
            print("???")
        }
    }
    #endif
    
    var lastTime: CFTimeInterval!
    override func update(currentTime: CFTimeInterval) {
        for node in flowerNodes {
            node.physicsBody!.velocity = CGVectorMake(0, currentSpeed)
        }
        
        if beeOnFlower > 0 {
            points += currentTime - lastTime
        }
        
        lastTime = currentTime
    }
    
    var beeOnFlower = 0
    
    override func didFinishUpdate() {
        pointsNode.text = "\(actualScore())"
        
        if beeOnFlower == 0 {
            if beeNode.physicsBody!.velocity.dx >= 0 {
                beeNode.texture = beeFlyTexuture
            } else {
                beeNode.texture = beeFlyRevTexuture
            }
        }
    }
    
    private func actualScore() -> Int {
        return Int(points * 10)
    }
    
    var boundaryNames = ["TopBoundary", "LeftBoundary", "RightBoundary", "BottomBoundary"]
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {
            return
        }
        
        guard let nodeB = contact.bodyB.node else {
            return
        }
        
        if nodeA.name == "TopBoundary" && nodeB.name == "Flower" {
            nodeB.removeFromParent()
            flowerNodes.removeAtIndex(flowerNodes.indexOf(nodeB as! SKSpriteNode)!)
        } else if nodeA.name == "Bee" && nodeB.name == "Flower" {
            if beeOnFlower == 0 {
                if beeNode.texture == beeFlyTexuture {
                    beeNode.texture = beeTexuture
                } else {
                    beeNode.texture = beeRevTexuture
                }
            }
            
            beeOnFlower += 1
            nodeB.runAction(SKAction.playSoundFileNamed("HitSound.wav", waitForCompletion: false))
        } else if (boundaryNames.contains(nodeA.name!) && nodeB.name == "Bee") ||
            (nodeA.name == "Bee" && boundaryNames.contains(nodeB.name!)) {
            game.gameOver(actualScore())
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {
            return
        }
        
        guard let nodeB = contact.bodyB.node else {
            return
        }
        
        if nodeA.name == "Bee" && nodeB.name == "Flower" {
            beeOnFlower -= 1
            if beeOnFlower == 0 {
                if beeNode.physicsBody!.velocity.dx >= 0 {
                    beeNode.texture = beeFlyTexuture
                } else {
                    beeNode.texture = beeFlyRevTexuture
                }
            }
        }
    }
}

