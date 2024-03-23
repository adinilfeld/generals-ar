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

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let red = SimpleMaterial(color: .red, isMetallic: false)
        let blue = SimpleMaterial(color: .blue, isMetallic: false)
        let model = ModelEntity(mesh: mesh, materials: [material])
//        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)
        
        let n = 4
        let m = 3
        for i in 0..<m {
            for j in 0..<n {
                var m = red
                if (i + j) % 2 == 0 {
                    m = blue
                }
                let model = ModelEntity(mesh: mesh, materials: [m])
                model.transform.translation.x = 0.1 * Float(i)
                model.transform.translation.z = 0.1 * Float(j)
                anchor.children.append(model)
            }
            
        }
        // Create a cube model
//        let model2 = ModelEntity(mesh: mesh, materials: [material])
//        model2.transform.translation.y = 0.15
//        anchor.children.append(model2)

        

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
