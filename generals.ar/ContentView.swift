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
        
        let arView = ARView(frame: .zero)

        let tileMesh = MeshResource.generatePlane(width: 0.1, height: 0.1)
        
        // Materials
        let red = SimpleMaterial(color: .red, isMetallic: false)
        let blue = SimpleMaterial(color: .blue, isMetallic: false)

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        
        let n = 4
        let m = 3
        for i in 0..<m {
            for j in 0..<n {
                var m = red
                if (i + j) % 2 == 0 {
                    m = blue
                }
                let model = ModelEntity(mesh: tileMesh, materials: [m])
                
                // Apply rotation to lay the tile flat on the surface
                model.transform.rotation = simd_quatf(angle: .pi / 2, axis: [-1, 0, 0])

                // Offset tile to create grid
                model.transform.translation.x = 0.1 * Float(i)
                model.transform.translation.z = 0.1 * Float(j)
                anchor.children.append(model)
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
