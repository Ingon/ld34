//
//  EndScene.swift
//  LD34
//
//  Created by Nikolay Petrov on 12/13/15.
//
//

import Foundation
import SpriteKit

class EndScene: SKScene {
    var game: Game!
    
    var scoreNode: SKLabelNode!
    var moveInTime = NSDate()
    
    override func didMoveToView(view: SKView) {
        runAction(SKAction.playSoundFileNamed("DieSound.wav", waitForCompletion: false))
        
        scoreNode = childNodeWithName("FinalScore") as! SKLabelNode
        scoreNode.text = "Score: \(game.lastScore!)"
        
        moveInTime = NSDate()
    }
    
    #if os(OSX)
    override func keyDown(theEvent: NSEvent) {
        startInteraction()
    }
    #else
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        startInteraction()
    }
    #endif
    
    func startInteraction() {
        if NSDate().timeIntervalSinceDate(moveInTime) > 1 {
            game.playGame()
        }
    }
}
