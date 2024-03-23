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

struct GameData {
  var dimensions: SIMD2<Int> = [4,4]
  var cardsFound: Int = 0
  var totalCards: Int {
    dimensions[0] * dimensions[1]
  }
}

class TapDetectorARView: ARView, ARSessionDelegate {
    /// Add the tap gesture recogniser
    func setupGestures() {
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      self.addGestureRecognizer(tap)
    }

    /// Handle taps on the screen, currently exclusively used for flipping cards
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
          hitEntity.randomScale()
        }
}

// randomScale is an example that gives feedback
extension Entity {
  func randomScale() {
    var newTransform = self.transform
    newTransform.scale = .init(
      repeating: Float.random(in: 0.5...1.5)
    )
    self.transform = newTransform
  }
}
