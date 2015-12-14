//
//  Game.swift
//  LD34
//
//  Created by Nikolay Petrov on 12/12/15.
//
//

import Foundation
import SpriteKit
import GameplayKit

class Game {
    let gameView: SKView
    
    var startScene: StartScene!
    var playScene: GameScene!
    var endScene: EndScene!
    
    var lastScore: Int?
    
    init(gameView: SKView) {
        self.gameView = gameView
        
        startScene = StartScene(fileNamed: "StartScene")
        startScene.game = self
        
        endScene = EndScene(fileNamed: "EndScene")
        endScene.game = self

        startGame()
    }
    
    private func presentScene(scene: SKScene) {
        scene.scaleMode = .AspectFit
        gameView.presentScene(scene)
    }
    
    func startGame() {
        presentScene(startScene)
    }
    
    func playGame() {
        playScene = GameScene(fileNamed: "GameScene")
        playScene.game = self
        presentScene(playScene)
    }
    
    func gameOver(score: Int) {
        lastScore = score
        presentScene(endScene)
    
        playScene = nil
    }
}
