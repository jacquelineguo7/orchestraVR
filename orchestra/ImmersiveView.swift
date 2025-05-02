//
//  ImmersiveView.swift
//  orchestra
//
//  Created by Jacqueline Guo on 4/28/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

func lookAtQuaternion(from: SIMD3<Float>, to: SIMD3<Float>, up: SIMD3<Float> = [0,1,0]) -> simd_quatf {
    let forward = normalize(to - from)
    let right = normalize(cross(up, forward))
    let correctedUp = cross(forward, right)
    let mat = float3x3(right, correctedUp, forward)
    return simd_quatf(mat)
}

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
                
                // Add the spheres code
                if let quartet = stringQuartet {
                    addMarker(to: quartet, color: .green)
                }
                
                let seatColors: [UIColor] = [.blue, .cyan, .magenta, .yellow, .orange, .purple, .brown, .systemTeal]
                let seatNames = Array(instrumentPositions.positions.keys)
                for (index, name) in seatNames.enumerated() {
                    if let quartet = stringQuartet,
                       let seatNode = quartet.findEntity(named: name) {
                        let color = seatColors[index % seatColors.count]
                        addMarker(to: seatNode, color: color)
                    }
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
            
            // Visual Marker in Scene
            func addMarker(to parent: Entity, color: UIColor) {
                let mesh = MeshResource.generateSphere(radius: 0.05)
                let material = SimpleMaterial(color: color, isMetallic: false)
                let marker = ModelEntity(mesh: mesh, materials: [material])
                marker.position = [0, 0, 0] // Local to parent
                parent.addChild(marker)
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
            
            // 1. Handle reset case first
                if selectedName == "reset_node" {
                    if let quartet = stringQuartet {
                        // Set to your default position, orientation, and scale
                        quartet.position = SIMD3<Float>(0, 0, -4)
                        quartet.orientation = simd_quatf() // Identity quaternion (no rotation)
                        // Optionally reset scale or other properties here
                        print("Quartet reset to default position and orientation.")
                    }
                    return
                }

                // 2. Proceed with normal seat selection logic
                guard
                    let quartet = stringQuartet,
                    let seatLocalOriginal = instrumentPositions.positions[selectedName]
                else {
                    return
                }

            // 1. Calculate centroid of all seat nodes
            let allPositions = Array(instrumentPositions.positions.values)
            let centroid: SIMD3<Float>
            if allPositions.isEmpty {
                centroid = .zero
            } else {
                centroid = allPositions.reduce(SIMD3<Float>(0,0,0), +) / Float(allPositions.count)
            }

            // 2. Center and scale the selected seat
            let seatLocal = seatLocalOriginal - centroid
            let scale = quartet.scale
            let scaledSeat = seatLocal * scale

            // 3. Project to XZ plane and calculate angle to negative Z axis
            let seatXZ = SIMD2<Float>(scaledSeat.x, scaledSeat.z)
            let angle = atan2(seatXZ.x, -seatXZ.y)

            // 4. Define correction angles for each seat (in radians)
            // Adjust these values based on your model's actual seat orientations
            let seatCorrectionAngles: [String: Float] = [
                "violin1_node": 0,           // Outer seat, facing forward
                "violin2_node": .pi / 2,           // Outer seat, facing forward
                "viola_node": -.pi / 2,                // Middle seat, needs +90°
                "cello_node": 0,     // Middle seat, needs -90°
            ]
            let correction = seatCorrectionAngles[selectedName] ?? 0

            // 5. Rotate model so seat faces user, including correction
            let rotation = simd_quatf(angle: -angle + correction, axis: [0,1,0])
            quartet.orientation = rotation

            // 6. Move model so seat is at origin (with offset)
            let rotatedSeat = rotation.act(scaledSeat)
            let alignmentOffset = SIMD3<Float>(1.36, 0, -1.05)
            let adjustedSeat = rotatedSeat
            quartet.position = -adjustedSeat

            print("Quartet rotated by \(-angle + correction) radians so \(selectedName) is in front of user and at origin.")
        }



        
        
        
    }
    
}
    


#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}

