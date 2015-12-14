//
//  StartScene.swift
//  LD34
//
//  Created by Nikolay Petrov on 12/13/15.
//
//

import SpriteKit

class StartScene: SKScene {
    var game: Game!
    
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
        game.playGame()
    }
}
