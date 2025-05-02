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
                        print("Position of \(name) is \(nodeEntity.position)")
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
            
            // --- Visual Markers for Debugging ---

            // Helper function to add a colored sphere marker
            func addMarker(at position: SIMD3<Float>, color: UIColor, to content: RealityViewContent) {
                let mesh = MeshResource.generateSphere(radius: 0.05)
                let material = SimpleMaterial(color: color, isMetallic: false)
                let marker = ModelEntity(mesh: mesh, materials: [material])
                marker.position = position
                content.add(marker)
            }

            // 1. User origin (red)
            addMarker(at: [0, 0, 0], color: .red, to: content)

            // 2. Model origin (green)
            if let quartet = stringQuartet {
                addMarker(at: quartet.position, color: .green, to: content)
            }

            // 3. Each seat node (blue)
            let seatColors: [UIColor] = [.blue, .cyan, .magenta, .yellow, .orange, .purple, .brown, .systemTeal]
            let seatNames = Array(instrumentPositions.positions.keys)
            for (index, name) in seatNames.enumerated() {
                if let pos = instrumentPositions.positions[name], let quartet = stringQuartet {
                    let scaledPos = pos * quartet.scale
                    let worldPos = quartet.position + scaledPos + SIMD3<Float>(1.36, 0, -1.05)
                    let color = seatColors[index]
                    addMarker(at: worldPos, color: color, to: content)
                }
            }



        }
        .onChange(of: instrumentPositions.targetPosition) {
            let selectedName = instrumentPositions.selectedInstrumentName
            let originPoint = SIMD3<Float>(0, 0, 4)
            guard
                let quartet = stringQuartet,
                
                // 1. Get the local position of the seat
                var instrumentPos = instrumentPositions.positions[selectedName]
            else { return }

                // 2. Multiply the seat’s local position by the model’s scale (element-wise, for X, Y, Z)
                instrumentPos.x *= 0.08
                instrumentPos.y *= 0.08
                instrumentPos.z *= 0.08
            
                // 3. Set the model’s position to align the seat with the user’s head/eyes
                quartet.position = originPoint - instrumentPos

            print("Moved quartet by \(-instrumentPos) to bring \(selectedName) to the user's viewpoint (origin)")
        }

        

        
    }
    
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}

