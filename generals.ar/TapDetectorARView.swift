//
//  TapDetectorARView.swift
//  generals.ar
//
//  Created by Adin Ilfeld on 3/23/24.
//

import SwiftUI

import RealityKit
import ARKit
import Combine

class TapDetectorARView: ARView, ARSessionDelegate {
    var board: Board? = nil
    /// Add the tap gesture recogniser
    func setupGestures() {
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      self.addGestureRecognizer(tap)
    }

    /// Tap logic goes here
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("TAPPED")
        guard let touchInView = sender?.location(in: self) else {
            print("not in view")
            return
        }
        guard let hitEntity = self.entity(
            at: touchInView
        ) else {
            // no entity was hit
            print("no entity hit")
            return
        }
        if let e = hitEntity as? Tile {
            board?.updateMove(i:e.i, j:e.j)
        }
    }
}
