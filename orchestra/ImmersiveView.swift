//
//  ImmersiveView.swift
//  orchestra
//
//  Created by Jacqueline Guo on 4/28/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @EnvironmentObject var instrumentPositions: InstrumentPositions
    @State private var cameraEntity: PerspectiveCamera?
    @State private var stringQuartet: Entity?

    var body: some View {
        RealityView { content in


// Load initial String Quartet 3D Model
            if let loadedQuartet = try? await Entity(named: "quartet", in: .main) {
                stringQuartet = loadedQuartet
                loadedQuartet.position = [0, 0, -4] // 2m in front of camera
                loadedQuartet.scale = [0.08, 0.08, 0.08]
                content.add(loadedQuartet)
                print("Loaded quartet")
                
                if let foundCamera = loadedQuartet.findEntity(named: "Camera") as? PerspectiveCamera {
                    cameraEntity = foundCamera
                    print("Camera entity found and stored")
                } else if let foundCamera = content.entities.first(where: { $0 is PerspectiveCamera }) as? PerspectiveCamera {
                    cameraEntity = foundCamera
                }
                
                do {
                    let resource = try AudioFileResource.load(named: "violin1_node.wav", configuration: .init(shouldLoop: true))
                    loadedQuartet.playAudio(resource)
                    print("Playing audio")
                } catch {
                    print("Error loading audio.")
                }
                
                let nodeNames = ["violin1_node", "violin2_node", "viola_node", "cello_node"]
                var instrumentNodes: [String: InstrumentNode] = [:]
                var positionNodes: [SIMD3<Float>] = []
                
                for name in nodeNames {
                    if let nodeEntity = loadedQuartet.findEntity(named: name) {
                        print("Found node: \(name)")
                        let node = InstrumentNode(
                            entity: nodeEntity,
                            position: nodeEntity.position,
                            audioFile: "\(name).wav"
                        )
                        instrumentPositions.positions[name] = nodeEntity.position
                        instrumentNodes[name] = node
                        positionNodes.append(node.position)
                        
                        nodeEntity.spatialAudio = SpatialAudioComponent(gain: 0)
                        nodeEntity.spatialAudio?.directivity = .beam(focus: 1)
                        
                        do {
                            let resource = try AudioFileResource.load(named: "\(name).wav", configuration: .init(shouldLoop: true))
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                nodeEntity.playAudio(resource)
                            }
                            print("Playing audio for \(name)")
                        } catch {
                            print("Error loading audio for \(name): \(error.localizedDescription)")
                        }
                    }
                    else {
                        print("Node not found: \(name)")
                    }
                }
            } else {
                print("Failed to load quartet")
            }
        }
        .onChange(of: instrumentPositions.targetPosition) {
            // Use instrumentPositions.targetPosition directly
            cameraEntity?.position = instrumentPositions.targetPosition
            print("targetPosition changed to \(instrumentPositions.targetPosition)")
        }
        
    }
    
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}

