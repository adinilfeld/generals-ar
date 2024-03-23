//
//  ContentView.swift
//  generals.ar
//
//  Created by Jack Nugent on 3/23/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = TapDetectorARView(frame: .zero)
        arView.setupGestures()

        let tileWidth : Float = 0.05
        let tileMesh = MeshResource.generatePlane(width: tileWidth, height: tileWidth)
        
        // Materials
        let red = SimpleMaterial(color: .red, isMetallic: false)
        let blue = SimpleMaterial(color: .blue, isMetallic: false)
        let black = SimpleMaterial(color: .black, isMetallic: false)

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        
        let n = 7
        let m = 7
        for i in 0..<m {
            for j in 0..<n {
                var color = red
                if (i + j) % 2 == 0 {
                    color = blue
                }
                let tileEntity = TappableEntity(model: ModelComponent(mesh: tileMesh, materials: [color]))
                
                // Create a number and fix it to the tile
                let textEntity = ModelEntity(mesh: .generateText(String(i), extrusionDepth: 0.005, font: .boldSystemFont(ofSize: 0.02), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping), materials: [black])
                tileEntity.addChild(textEntity)
                
                // Center the number within the tile
                // TODO: center this better
                textEntity.transform.translation.x -= tileWidth / 4;
                textEntity.transform.translation.y -= tileWidth / 4;
                
                // Apply rotation to lay the tile flat on the surface
                tileEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [-1, 0, 0])

                // Offset tile to create grid
                tileEntity.transform.translation.x = tileWidth * Float(m / 2 - i)
                tileEntity.transform.translation.z = tileWidth * Float(n / 2 - j)
                
                anchor.children.append(tileEntity)
            }
        }

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    ContentView()
}
