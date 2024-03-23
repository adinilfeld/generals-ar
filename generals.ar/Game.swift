//
//  Game.swift
//  generals.ar
//
//  Created by Adin Ilfeld on 3/23/24.
//

import SwiftUI

import RealityKit
import ARKit
import Foundation

enum Color {
    case red
    case blue
    case gray
}

enum Direction {
    case up
    case down
    case left
    case right
}

func getNumModel(num : Int) -> Entity {
    return ModelEntity(mesh: .generateText(String(num), extrusionDepth: 0.005, font: .boldSystemFont(ofSize: 0.02), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping), materials: [blackMaterial])
}

let tileWidth : Float = 0.05

let redMaterial = SimpleMaterial(color: .red, isMetallic: false)
let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
let grayMaterial = SimpleMaterial(color: .gray, isMetallic: false)
let blackMaterial = SimpleMaterial(color: .black, isMetallic: false)
let redTowerMaterial = SimpleMaterial(color: .red, isMetallic: true)
let blueTowerMaterial = SimpleMaterial(color: .blue, isMetallic: true)
let grayTowerMaterial = SimpleMaterial(color: .gray, isMetallic: true)


class Tile: Entity, HasModel, HasCollision {
    var color: Color
    var direction: Direction?
    var i : Int = 0
    var j : Int = 0
    
    required init() {
        self.color = Color.gray
        super.init()
        
        self.model = ModelComponent(mesh: .generatePlane(width: tileWidth, depth: tileWidth), materials: [grayMaterial])
    }
    
    func setColor(color: Color) {
        self.color = color
        switch color {
        case Color.red:
            self.model?.materials = [redMaterial]
        case Color.blue:
            self.model?.materials = [blueMaterial]
        case Color.gray:
            self.model?.materials = [grayMaterial]
        }
    }
    
    func setDirection(dir: Direction?) {
        print(dir)
        // TODO
    }
}

class MountainTile: Tile {
    required init() {
        super.init()
    }
}

class TowerTile: Tile {
    var troopCount : Int
    
    required init() {
        self.troopCount = 0
        super.init()
        
        self.addChild(getNumModel(num: self.troopCount))
    }
    
    override func setColor(color: Color) {
        self.color = color
        switch color {
        case Color.red:
            self.model?.materials = [redTowerMaterial]
        case Color.blue:
            self.model?.materials = [blueTowerMaterial]
        case Color.gray:
            self.model?.materials = [grayTowerMaterial]
        }
    }

    func setTroopCount(newCount : Int) {
        self.troopCount = newCount
        self.removeChild(self.children[0])
        self.addChild(getNumModel(num: self.troopCount))
    }
}

class OpenTile: Tile {
    var troopCount : Int
    
    required init() {
        self.troopCount = 0
        super.init()
        
        self.addChild(getNumModel(num: self.troopCount))
    }
    
    func setTroopCount(newCount : Int) {
        self.troopCount = newCount
        self.removeChild(self.children[0])
        self.addChild(getNumModel(num: self.troopCount))
    }
}

let server = "TODO"

class Board {
    var board : [[Tile]] = [[]]
    var fromTile : Tile?  = nil
    
    required init() {
        self.updateBoard()
    }
    
    func updateBoard() {
        
    }
    
}
