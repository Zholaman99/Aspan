//
//  ViewController.swift
//  Aspan
//
//  Created by Zholaman Kassenov on 08.04.2024.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(hadleTap(recognizer:))))
    }
    
    // TEST: Setup methods
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }

    // TEST: Object Placement
    
    @objc
    func hadleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
       
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "Voxel_Dog", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failed - couldn't find surface.")
        }
    }
    
    func placeObject(name entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "Voxel_Dog" {
                placeObject(name: anchorName, for: anchor)
            }
        }
    }
}
