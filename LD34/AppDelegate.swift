//
//  AppDelegate.swift
//  LD34
//
//  Created by Nikolay Petrov on 12/12/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//


import Cocoa
import SpriteKit
import GameplayKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    var game: Game!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        skView!.showsDrawCount = true
//        skView!.showsFPS = true
//        skView!.showsFields = true
//        skView!.showsNodeCount = true
//        skView!.showsQuadCount = true

//        skView!.showsPhysics = true
        game = Game(gameView: skView!)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
