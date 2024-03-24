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
    let e = ModelEntity(mesh: .generateText(String(num), extrusionDepth: 0.005, font: .boldSystemFont(ofSize: 0.02), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping), materials: [blackMaterial])
    e.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [-1,0,0])
//    e.transform.translation.y = -tileWidth / 4
    return e
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
        self.generateCollisionShapes(recursive: true)
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
        self.setTroopCount(newCount: 0)
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
        let textEntity = getNumModel(num: self.troopCount)
        self.addChild(textEntity)
        textEntity.transform.translation.x -= tileWidth / 4;
        textEntity.transform.translation.z -= tileWidth / 4;
    }
}

class OpenTile: Tile {
    var troopCount : Int
    
    required init() {
        self.troopCount = 0
        super.init()
        
        self.addChild(getNumModel(num: self.troopCount))
        self.setTroopCount(newCount: 0)
    }
    
    func setTroopCount(newCount : Int) {
        self.troopCount = newCount
        self.removeChild(self.children[0])
        let textEntity = getNumModel(num: self.troopCount)
        self.addChild(textEntity)
        textEntity.transform.translation.x -= tileWidth / 4;
        textEntity.transform.translation.z -= tileWidth / 4;
    }
}

let serverURL = "http://127.0.0.1:8000"

class Board : Entity {
    var board : [[Tile]] = []
    var fromTile : (Int, Int)?  = nil
    
    required init() {
        super.init()
        self.updateBoard()
    }
    
    func updateBoard() {
        let url: URL = URL(string: serverURL + "/board")!
        print(url)
        var request1: URLRequest = URLRequest(url: url)

        request1.httpMethod = "GET"
        let queue:OperationQueue = OperationQueue()
    
        print("HERE")
        
        // TODO: remove this and uncomment below
        if board.count == 0 {
            self.defaultBoard()
        } else {
            print(board.count)
        }

//        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
//
//            do {
//                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
//                    print("ASynchronous\(jsonResult)")
//                    print(jsonResult["a"])
//                    print(jsonResult["b"])
//                    // TODO: read input and adjust
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        })
    }
    
    func defaultBoard() {
        let n = 7
        let m = 7
        for i in 0..<m {
            var row: [Tile] = []
            for j in 0..<n {
                var color = Color.red
                if (i + j) % 2 == 0 {
                    color = Color.blue
                }
                let tile = OpenTile()
                tile.i = i
                tile.j = j
                tile.setColor(color: color)
                
                
                // Offset tile to create grid
                tile.transform.translation.x = tileWidth * Float(m / 2 - i)
                tile.transform.translation.z = tileWidth * Float(n / 2 - j)
                
                self.addChild(tile)
                row.append(tile)
            }
            self.board.append(row)
        }

    }
    
    func shortestPath(s: (Int, Int), t: (Int,Int)) -> [[Int]] {
        let I = board.count
        let J = board[0].count
        func nbh(i: Int, j: Int) -> [(Int, Int)] {
            var out: [(Int, Int)] = []
            if i > 0 {
                out.append((i-1,j))
            }
            if i < I {
                out.append((i+1,j))
            }
            if j > 0 {
                out.append((i,j-1))
            }
            if j < J {
                out.append((i,j+1))
            }
            return out
        }
        
        var visited: [[Bool]] = []
        var last: [[(Int,Int)?]] = []
        for i in 0..<I {
            var row: [Bool] = []
            var row_last: [(Int,Int)?] = []
            for j in 0..<J {
                row.append(false)
                row_last.append(nil)
            }
            visited.append(row)
            last.append(row_last)
        }
        
        var q: [(Int, Int)] = [s]
        while q.count > 0 {
            let curr = q.popLast()!
            if visited[curr.0][curr.1] { continue }
            
            // finish BFS
            for p in nbh(curr.0, curr.1) {
            }
            }
            
            
            
        }
        
    }
    
    func updateMove(i: Int, j: Int) {
        if let (x,y) = self.fromTile {
            self.fromTile = nil
            let url: URL = URL(string: serverURL + "/move")!
            var request1: URLRequest = URLRequest(url: url)
            
            
            let encoder = JSONEncoder()
            request1.httpBody = try? encoder.encode(self.shortestPath(s: (i,j), t: (x,y)))
            
            
            print(self.shortestPath(s: (i,j), t: (x,y)))
            print(request1.httpBody)
            

            request1.httpMethod = "POST"
            let queue:OperationQueue = OperationQueue()
        
            print("HERE")

            NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in

                do {
                    self.updateBoard()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            })
            
        } else {
            self.fromTile = (i,j)
            return
        }
        
    }
    
}
