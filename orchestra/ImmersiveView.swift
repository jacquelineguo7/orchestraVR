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

    var body: some View {
        
        RealityView { content in
            
            @State var currentIndex: Int = 0
            class InstrumentPositions: ObservableObject {
                @Published var positions: [String: SIMD3<Float>] = [:]
            }
            
//            let box = ModelEntity(mesh: .generateBox(size: 0.1))
//                        content.add(box)
//            
//                    box.spatialAudio = SpatialAudioComponent(gain: 0)
//                    box.spatialAudio?.directivity = .beam(focus: 0)
//                        
//                        do {
//                            // Try loading a basic audio file (make sure it's in your bundle)
//                            let resource = try AudioFileResource.load(named: "violin1_node.wav", configuration: .init(shouldLoop: true))
//                            // Play the audio (not spatial, just basic playback)
//                            box.playAudio(resource)
//                            print("Audio playback started!")
//                        } catch {
//                            print("Error loading or playing audio: \(error.localizedDescription)")
//                        }
            
            
            let instrumentPositions = InstrumentPositions()

//            // Load initial String Quartet 3D Model
            if let stringQuartet = try? await Entity(named: "quartet", in: .main) {
                stringQuartet.position = [0, 0, -4] // 2m in front of camera
                stringQuartet.scale = [0.08, 0.08, 0.08]
                content.add(stringQuartet)
                print("Loaded quartet")
                
                do {
                    let resource = try AudioFileResource.load(named: "violin1_node.wav", configuration: .init(shouldLoop: true))
                    stringQuartet.playAudio(resource)
                    print("Playing audio")
                } catch {
                    print("Error loading audio.")
                }
                
                let nodeNames = ["violin1_node", "violin2_node", "viola_node", "cello_node"]
                var instrumentNodes: [String: InstrumentNode] = [:]
                var positionNodes: [SIMD3<Float>] = []
                
                for name in nodeNames {
                    if let nodeEntity = stringQuartet.findEntity(named: name) {
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
                            
                            
                            // Try delaying audio
                            // nodeEntity.playAudio(resource)
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
            
                
            
            
            
            
//            if let stringQuartet = try? await ModelEntity(named: "quartet", in: .main) {
//                content.add(stringQuartet)
//                let nodeNames = ["violin1_node", "violin2_node", "viola_node", "cello_node"]
//                for name in nodeNames {
//                    if let nodeEntity = stringQuartet.findEntity(named: name) {
//                        let position = nodeEntity.position(relativeTo: nil)
//                        let audioEntity = ModelEntity()
//                        audioEntity.position = position
//                        audioEntity.spatialAudio = SpatialAudioComponent(gain: 0)
//                        // Optionally: audioEntity.model = nil // keep invisible
//                        do {
//                            let resource = try AudioFileResource.load(named: "\(name).wav", configuration: .init(shouldLoop: true))
//                            audioEntity.playAudio(resource)
//                        } catch {
//                            print("Error loading audio for \(name): \(error.localizedDescription)")
//                        }
//                        content.add(audioEntity)
//                    }
//                }
//            }
            
            // Add a 2D panel as a floating overlay
//            let panel = ModelEntity(mesh: .generatePlane(width: 0.5, height: 0.3))
//            panel.position = [0, 1.13, -0.5] // Adjust position as needed
//            content.add(panel)

        }
        .onChange(of: instrumentPositions.targetPosition) { newPosition in
                    // Update your camera entity’s position here
                    cameraEntity.position = newPosition
                }
//        .overlay {
//            .annotation(position: SIMD3<Float>(x: 0, y: 1.2, z: -1))
//                // SwiftUI content for the 2D panel
//                VStack {
//                    Text("2D Overlay Panel")
//                    Button("Click Me") { /* action */ }
//                }
//                .frame(width: 400, height: 240)
//                .background(.ultraThinMaterial)
//                .cornerRadius(16)
//                
//            }

    }
        

}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}

