//
//  ContentView.swift
//  generals.ar
//
//  Created by Jack Nugent on 3/23/24.
//

import SwiftUI
import RealityKit

class Button3D : Entity, HasModel, HasCollision {
    required init() {
        super.init()
        
        self.model = ModelComponent(mesh: .generatePlane(width: (1-gapSize) * tileWidth, depth: (1-gapSize) * tileWidth), materials: [redMaterial])
        self.numModel = getNumModel(num: <#T##Int#>)
        self.generateCollisionShapes(recursive: true)
    }

}

struct ContentView : View {
    var board: Board
    
    init(board: Board) {
        self.board = board
    }
    
    var body: some View {
        ARViewContainer(board: board).edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    var board: Board
    init(board: Board) {
        self.board = board
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = TapDetectorARView(frame: .zero)
        arView.setupGestures()
        
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        
//        var button = UIButton()
//        button.setTitle("Reset", for: .normal)
        
        arView.board = board
        
        anchor.children.append(board)
        
        // Add reset button
        

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
    }
        
    func updateUIView(_ uiView: ARView, context: Context) {}
}
