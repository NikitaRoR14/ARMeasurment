//
//  ViewController.swift
//  MeasurementApp
//
//  Created by Никита Порошин on 06.08.2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = .showFeaturePoints
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes.removeAll()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let result = hitTestResult.first{
                addDot(at:result)
            }
        }
    }
    func addDot(at hitResult:ARHitTestResult){
        let sphere = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        
        sphere.materials = [material]
        
        let sphereNode = SCNNode()
        
        sphereNode.geometry = sphere
        
        sphereNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        dotNodes.append(sphereNode)
        
        if dotNodes.count >= 2{
            calculate()
        }
        
    }
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let a = end.position.x - start.position.x
        
        let b = end.position.y - start.position.y
        
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        updateText(text:"\(String(format:"%.2f", abs(distance)*100 ) ) CM",at: end.position)
    }
    
    func updateText(text:String,at position:SCNVector3){
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.systemCyan
        
         textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: position.x-0.4, y: position.y, z: position.z+0.05)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
}
