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
import DequeModule
//import Alamofire

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
    e.transform.rotation = simd_quatf(angle: .pi / 2, axis: [-1,0,0])
    e.name = "nummodel"
    return e
}

func getTextWidth(text: Entity) -> Float {
    let bounds = text.visualBounds(relativeTo: nil).extents
    return bounds[0]
}

let tileWidth : Float = 0.05
let gapSize : Float = 0.02 // The percent of the tile width that should be margin (not colored)

let redMaterial = SimpleMaterial(color: .red, isMetallic: false)
let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
let grayMaterial = SimpleMaterial(color: .gray, isMetallic: false)
let whiteMaterial = SimpleMaterial(color: .white, isMetallic: false)
let blackMaterial = SimpleMaterial(color: .black, isMetallic: false)


class Tile: Entity, HasModel, HasCollision {
    var color: Color
    var direction: Direction?
    var i : Int = 0
    var j : Int = 0
    var selected: Bool
    
    required init() {
        self.color = Color.gray
        self.selected = false
        super.init()
        
        self.model = ModelComponent(mesh: .generatePlane(width: (1-gapSize) * tileWidth, depth: (1-gapSize) * tileWidth), materials: [grayMaterial])
        self.generateCollisionShapes(recursive: true)
        self.setColor(color: self.color)
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
        if let unwrappedDir = dir {
            var arrow : String
            var rightOffset : Float
            var upOffset : Float
            switch unwrappedDir {
            case Direction.up:
                arrow = "↑"
                rightOffset = -0.008
                upOffset = 0.012
            case Direction.right:
                arrow = "→"
                rightOffset = 0.015
                upOffset = -0.01
            case Direction.down:
                arrow = "↓"
                rightOffset = -0.008
                upOffset = -0.036
            case Direction.left:
                arrow = "←";
                rightOffset = -0.035
                upOffset = -0.01
            }
            
            let arrowEntity = ModelEntity(mesh: .generateText(arrow, extrusionDepth: 0.005, font: .boldSystemFont(ofSize: 0.02), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping), materials: [blackMaterial])
            arrowEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [-1,0,0])
            arrowEntity.transform.translation.x += rightOffset
            arrowEntity.transform.translation.z -= upOffset
            self.addChild(arrowEntity)
        }
    }
    
    func setSelected(setSelected: Bool) {
        if setSelected && !self.selected {
            self.transform.scale *= 0.8
            self.selected = true
        } else if !setSelected && self.selected {
            self.transform.scale /= 0.8
            self.selected = false
        }
    }
}

class MountainTile: Tile {
    required init() {
        super.init()
    
        if let mountainEntity = try? Entity.loadModel(named: "mountainpeak") {
            // smaller_mountain is better scaled, but is a lighter shade of gray
//        if let mountainEntity = try? Entity.loadModel(named: "smaller_mountain") {
            mountainEntity.scale *= 2.2
            mountainEntity.scale.y *= 3
//            mountainEntity.model?.materials = [grayMaterial] // Turns smaller mountain gray, but has some weird flickering
            self.addChild(mountainEntity)
        } else {
            // Unable to load mountain model
            print("ERROR: unable to load mountain model")
        }
    }
}

class TowerTile: Tile {
    var troopCount : Int
    
    required init() {
        self.troopCount = 0
        super.init()
        
        self.addChild(getNumModel(num: self.troopCount))
        
        self.setTroopCount(newCount: 0)
        self.setColor(color: self.color)
        
        if let towerEntity = try? Entity.load(named: "tower") {
            towerEntity.scale *= 0.12
            self.addChild(towerEntity)
        } else {
            print("ERROR: unable to load tower model")
        }
    }
    
    // TODO: possibly add this back if we want to change the color of the tower model
//    override func setColor(color: Color) {
//        self.color = color
//        switch color {
//        case Color.red:
//            self.model?.materials = [redTowerMaterial]
//        case Color.blue:
//            self.model?.materials = [blueTowerMaterial]
//        case Color.gray:
//            self.model?.materials = [grayTowerMaterial]
//        }
//    }

    func setTroopCount(newCount : Int) {
        self.troopCount = newCount
        if let oldNumber = findEntity(named: "nummodel") {
            self.removeChild(oldNumber)
        } else {
            print("failed to identify old number")
        }
        let textEntity = getNumModel(num: self.troopCount)
        self.addChild(textEntity)
        textEntity.transform.translation.x -= getTextWidth(text: textEntity) / 2;
        textEntity.transform.translation.z += tileWidth / 2;
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
        if let oldNumber = findEntity(named: "nummodel") {
            self.removeChild(oldNumber)
        } else {
            print("failed to identify old number")
        }
        let textEntity = getNumModel(num: self.troopCount)
        self.addChild(textEntity)
        textEntity.transform.translation.x -= getTextWidth(text: textEntity) / 2;
        textEntity.transform.translation.z += tileWidth / 4;
    }
}

struct ResponseData : Decodable {
    var board: [[String]]
}

//let serverURL = "http://10.150.83.102:8000"
//let serverURL = "http://67.176.159.214:8000"
let serverURL = "http://10.150.17.140:8000"

class Board : Entity {
    var board : [[Tile]] = []
    var fromTile : (Int, Int)?  = nil
    var playerid: Int
    var player: Color = Color.red
    
    required init() {
        self.playerid = Int.random(in: 1..<2_000_000_000)
        super.init()
//        self.defaultBoard()
        self.updateBoard()
     
    }
    
    func updateBoard() {
        print("UPDATING BOARD")
        var url = URLComponents(string: serverURL + "/board")!
        
        print(url)
        
        url.queryItems = [
            URLQueryItem(name: "playerid", value: String(self.playerid))
        ]
        
        var request1: URLRequest = URLRequest(url: url.url!)
        print(url.url!)

        request1.httpMethod = "GET"
        let queue:OperationQueue = OperationQueue()

        let encoder = JSONEncoder()
        request1.httpBody = try? encoder.encode(["playerid": self.playerid])
        request1.httpBody = try? JSONSerialization.data(withJSONObject: ["playerid": self.playerid])
    
        print("HERE")
        
        // TODO: remove this and uncomment below
//        if board.count == 0 {
//            self.defaultBoard()
//        } else {
//            print(board.count)
//        }
//        self.updateBoardFromJson_(board: DefaultBoard)

        
//        NSURLConnection.sendSynchronousRequest(request1, returning: <#T##AutoreleasingUnsafeMutablePointer<URLResponse?>?#>)
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
            if data != nil {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
//                        print("ASynchronous\(jsonResult)")
                        // TODO: read input and adjust
                        print("GOT RESULT")
                        
//                        self.updateBoardFromJson(data: jsonResult)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                            print(jsonResult)
                            let json = self.Deserialize(data: jsonResult)
                            self.updateBoardFromJson_(board: json)

//                            var material = SimpleMaterial()
//                            material.baseColor = try! .texture(.load(named: "tex.png"))
//                            
//                            var comp: ModelComponent = model.components[ModelComponent.self]!
//                            comp.materials = [material]
//                            model.components.set(comp)
                        }
//                        let json = self.Deserialize(data: jsonResult)
//                        self.updateBoardFromJson_(board: json)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else {
                print("NO DATA RECEIVED")
            }
        })
    }
    
    func Deserialize(data: NSDictionary) -> [[(Int, String, Int)]]{
        var board_out: [[(Int, String, Int)]] = []
        let board_data = data["board"]!
        if let board_data = board_data as? [AnyObject] {
//            var i = 0;
//            var j = 0;
            var c = 0
            var curr_row: [(Int, String, Int)] = []
            var curr_tuple = (0, "", 0)
            for item in board_data {
                let tuple_i = c % 3
//                j = (c / 3) % 10
//                i = (c / 3) / 10
                
                if tuple_i == 0 {curr_tuple.0 = (item as? Int)!}
                if tuple_i == 1 {curr_tuple.1 = (item as? String)!}
                if tuple_i == 2 {
                    curr_tuple.2 = (item as? Int)!
                    if curr_row.count == 10 {
                        board_out.append(curr_row)
                        curr_row = []
                    }
                    curr_row.append(curr_tuple)
                }
                c += 1
            }
            
            board_out.append(curr_row)
            
            assert(c == 300)
        }
        return board_out
    }
    
    // TODO: have to hook this function up to updateBoardFromJson (to use the move list returned by server)
    func setArrows(moveQueue: [(Tile, Direction)]) {
        for (tile, dir) in moveQueue {
            tile.setDirection(dir: dir)
        }
    }
    
    func updateBoardFromJson(data: NSDictionary) {
        var board_out: [[(Int, String, Int)]] = []
        let board_data = data["board"]!
        if let board_data = board_data as? [[[AnyObject]]] {
            // Iterate through the key-value pairs of the dictionary
//            for (key, board) in data {
//                print("Key: \(key)")

                // Iterate through the inner array
            for r in board_data {
                var row: [(Int, String, Int)] = []
                for square in r {
                    var s: String = ""
                    var m: Int = 0
                    var n: Int = 0
                    var first = false
                    
                    for element in square {
                        if let stringElement = element as? String {
                            s = stringElement
                        } else if let intElement = element as? Int {
                            if first {
                                m = intElement
                                first = false
                            } else {
                                n = intElement
                            }
                        } else if let doubleElement = element as? Double {
                        } else {
                            print(element)
                            print(square)
                        }
                    }
                    row.append((m,s,n))
                }
                board_out.append(row)
            }
        } else {
            print("Error: The data is not in the expected format.")
            print(board_data)
        }
        
        self.updateBoardFromJson_(board: board_out)
    }
    
    func updateBoardFromJson_(board: [[(Int, String, Int)]]) {
        print("READING BOARD")
//        let board = data["board"]!
        let init_board: Bool = self.board.count == 0
        let m = board.count
        let n = m
        print("board rows", self.board.count, "init board", init_board)
        print("HEREHERE i:0,j:1", board[0][1])
//        print(type(of:board))
//        if let board = board as? [[(Any, String, Int)]] {
            var i = 0
            for row in board {
                var tile_row: [Tile] = []
                var j = 0
                for square in row {
                    var color = Color.gray
                    let c = square.0
                    if c == 1 { color = Color.blue}
                    if c == 2 { color = Color.red }
                    
//                    var color = Color.gray
//                    if square.0 == 1 {
//                        color = Color.blue
//                    } else if square.0 == 2 {
//                        color = Color.red
//                    }
                    if square.1 == "⛰" {
                        if init_board {
                            let t = MountainTile()
                            t.i = i
                            t.j = j
                            t.setColor(color: color)
                            tile_row.append(t)
                            self.addChild(t)
                            // Offset tile to create grid
                            t.transform.translation.x = tileWidth * Float(m / 2 - i)
                            t.transform.translation.z = tileWidth * Float(n / 2 - j)

                            print("ADDED CHILD")
                        }
                    } else if (square.1 == "⌂") || (square.1 == "♔") || (square.1 == "♛") {
                        if init_board {
                            let t = TowerTile()
                            t.i = i
                            t.j = j
                            t.setColor(color: color)
                            t.setTroopCount(newCount: square.2)
                            tile_row.append(t)
                            self.addChild(t)
                            // Offset tile to create grid
                            t.transform.translation.x = tileWidth * Float(m / 2 - i)
                            t.transform.translation.z = tileWidth * Float(n / 2 - j)

                            print("ADDED CHILD")
                        } else {
                            if let t = self.board[i][j] as? TowerTile {
                                t.setColor(color: color)
                                t.setTroopCount(newCount: square.2)
                                print("SET TROOP COUNT TOWER", t.troopCount)
                            } else {
                                print("FAILED TO GET TOWER TILE")
                            }
                        }
                    } else if square.1 == "-" {
                        if init_board {
                            print("ADDING TILE")
                            let t = OpenTile()
                            t.i = i
                            t.j = j
                            t.setColor(color: color)
                            t.setTroopCount(newCount: square.2)
                            tile_row.append(t)
                            self.addChild(t)
                            // Offset tile to create grid
                            t.transform.translation.x = tileWidth * Float(m / 2 - i)
                            t.transform.translation.z = tileWidth * Float(n / 2 - j)

                            print("ADDED CHILD")
                        } else {
                            if let t = self.board[i][j] as? OpenTile {
                                t.setColor(color: color)
                                t.setTroopCount(newCount: square.2)
//                                print("SET TROOP COUNT")
                            }
//                            var t : TowerTile = self.board[i][j]
                        }
                    } else {
                        assert(false)
                    }
                    j += 1
                }
                if init_board{
                    assert(tile_row.count == 10)
                    self.board.append(tile_row)
                }
                i += 1
            }
        assert(self.board.count == 10)
    }
    
    func defaultBoard() {
        let n = 10
        let m = 10
        for i in 0..<m {
            var row: [Tile] = []
            for j in 0..<n {
                func getTower(n: Int, color: Color) -> Tile {
                    let tile: TowerTile = TowerTile()
                    tile.setTroopCount(newCount: n)
                    tile.setColor(color: color)
                    
                    return tile
                }
                func getOpen(n: Int) -> Tile {
                    let tile: OpenTile = OpenTile()
                    tile.setTroopCount(newCount: n)
                    
                    return tile
                }
                let tile: Tile
                if (i == 2 && j == 2) {
                    tile = getTower(n: 30, color: .blue)
                } else if (i == 7 && j == 7) {
                    tile = getTower(n: 30, color: .red)
//                } else if (i == 3 && j == 4) {
//                    tile = MountainTile()
                } else if (i == j) {
                  tile = MountainTile()
                } else {
                    tile = getOpen(n: 0)
                }
                tile.i = i
                tile.j = j
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
            if i < I-1 {
                out.append((i+1,j))
            }
            if j > 0 {
                out.append((i,j-1))
            }
            if j < J-1 {
                out.append((i,j+1))
            }
            return out
        }
        
        var visited: [[Bool]] = []
        var last: [[(Int,Int)?]] = []
        for _ in 0..<I {
            var row: [Bool] = []
            var row_last: [(Int,Int)?] = []
            for _ in 0..<J {
                row.append(false)
                row_last.append(nil)
            }
            visited.append(row)
            last.append(row_last)
        }
        
        visited[s.0][s.1] = true
        
        var q: Deque = [s]
        while q.count > 0 {
            let curr = q.popFirst()!
            
            if curr == t {
                // TODO get path
                var path: [[Int]] = []
                var p2 = curr
                var p1 = last[curr.0][curr.1]!
                while p1 != s {
                    path.append([p1.0,p1.1,p2.0,p2.1])
                    
                    p2 = p1
                    p1 = last[p1.0][p1.1]!
                }
                path.append([p1.0,p1.1,p2.0,p2.1])

                return path
            }
            
            for p in nbh(i:curr.0, j:curr.1) {
                if !visited[p.0][p.1] {
                    q.append(p)
                    visited[p.0][p.1] = true
                    last[p.0][p.1] = curr
                }
            }
            
        }
        return []
    }
    
    func updateMove(i: Int, j: Int) {
        // Check if a fromTile had already been selected;
        // if so, we make a new move and send it to the backend.
        if let (x,y) = self.fromTile {
            self.board[x][y].setSelected(setSelected: false)
            self.fromTile = nil
            
            // If user taps same square twice, deselect it but do nothing else
            if x == i && y == j {
                return
            }
            
            let url: URL = URL(string: serverURL + "/move")!
            var request1: URLRequest = URLRequest(url: url)
            
            
            let encoder = JSONEncoder()
//            request1.httpBody = try? encoder.encode(["moves": self.shortestPath(s: (i,j), t: (x,y))])
            request1.httpBody = try? JSONSerialization.data(withJSONObject: ["playerid": self.playerid, "moves": self.shortestPath(s: (i,j), t: (x,y))])

            
            
            print(self.shortestPath(s: (i,j), t: (x,y)))
            print(request1.httpBody)
            
            request1.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request1.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            

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
            
        } else if self.board[i][j] is OpenTile || self.board[i][j] is TowerTile {
            // Don't set the tile as selected if it's a mountain.
            // Right now, the player is able to select a tile not owned by them.
            // however, when the second tile is selected, the backend will reject the move, so it all works out.
            self.fromTile = (i,j)
            self.board[i][j].setSelected(setSelected: true)
            return
        }
        
    }
    
    func resetBoard() {
        // TODO: send a restart request to the server
    }
}

//let DefaultBoard: [[(Int, String, Int)]] = [
//    "board": [
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⌂",
//                20
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⌂",
//                20
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "⌂",
//                20
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⌂",
//                20
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⌂",
//                20
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                1,
//                "♛",
//                1
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                2,
//                "♛",
//                1
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ],
//        [
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "⛰",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "-",
//                0
//            ],
//            [
//                -1,
//                "⌂",
//                20
//            ],
//            [
//                -1,
//                "-",
//                0
//            ]
//        ]
//    ]
//]
