//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import SpriteKit


let frame = CGRect(x: 0, y: 0, width: 500, height: 700)
let container = SKView(frame: frame)
let scene = CustomScene()

container.presentScene(scene)
PlaygroundPage.current.liveView = container
