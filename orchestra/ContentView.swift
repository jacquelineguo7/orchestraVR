//
//  ContentView.swift
//  orchestra
//
//  Created by Jacqueline Guo on 4/28/25.
//

import SwiftUI
import RealityKit
import simd

struct ContentView: View {
    
    @EnvironmentObject var instrumentPositions: InstrumentPositions
    @Environment(AppModel.self) var appModel
    @State private var immersiveActive = false
    

    var body: some View {
        VStack(spacing: 40) {
            if appModel.immersiveSpaceState == .closed {
                // Start screen
                Text("Welcome to String Quartet!")
                    .font(.largeTitle)
                Text("Explore the string quartet in immersive 3D. Tap Start to begin.")
                    .multilineTextAlignment(.center)
                ToggleImmersiveSpaceButton()

                    } else {
                        //        VStack (spacing: 120) {
                        //            ToggleImmersiveSpaceButton()
                        
                        HStack {
                            Button(action: {
                                instrumentPositions.selectedInstrumentName = "violin1_node"
                                //                    instrumentPositions.targetPosition = SIMD3<Float>(-140, 50, 72)
                                //                    print("Set violin1_node targetPosition")
                                if let pos = instrumentPositions.positions["violin1_node"] {
                                    instrumentPositions.targetPosition = pos
                                    print("Set targetPosition to \(pos)")
                                }
                                print("Violin 1 Node tapped!")
                            }) {
                                Text("Violin 1 Node")
                                    .font(.body)
                            }
                            
                            Button(action: {
                                instrumentPositions.selectedInstrumentName = "violin2_node"
                                //                    instrumentPositions.targetPosition = SIMD3<Float>(-80, 50, 15)
                                //                    print("Set violin2_node targetPosition")
                                if let pos = instrumentPositions.positions["violin2_node"] {
                                    instrumentPositions.targetPosition = pos
                                    print("Set targetPosition to \(pos)")
                                }
                                print("Violin 2 Node tapped!")
                                
                            }) {
                                Text("Violin 2 Node")
                                    .font(.body)
                            }
                            
                            Button(action: {
                                instrumentPositions.selectedInstrumentName = "viola_node"
                                //                    instrumentPositions.targetPosition = SIMD3<Float>(-23, 50, 12.5)
                                //                    print("Set viola_node targetPosition")
                                if let pos = instrumentPositions.positions["viola_node"] {
                                    instrumentPositions.targetPosition = pos
                                    print("Set targetPosition to \(pos)")
                                }
                                print("Viola Node tapped!")
                                
                            }) {
                                Text("Viola Node")
                                    .font(.body)
                            }
                            
                            Button(action: {
                                instrumentPositions.selectedInstrumentName = "cello_node"
                                //                    instrumentPositions.targetPosition = SIMD3<Float>(8, 50, 77)
                                //                    print("Set cello_node targetPosition")
                                if let pos = instrumentPositions.positions["cello_node"] {
                                    instrumentPositions.targetPosition = pos
                                    print("Set targetPosition to \(pos)")
                                }
                                print("Cello Node tapped!")
                                
                            }) {
                                Text("Cello Node")
                                    .font(.body)
                            }
                            
                            Button("Audience") {
                                // Set a test position (e.g., 2 meters forward)
                                instrumentPositions.selectedInstrumentName = "reset_node"
                                instrumentPositions.targetPosition = SIMD3<Float>(0, 0, -4)
                                print("Set targetPosition to \(instrumentPositions.targetPosition)")
                            }
                            
                        }
                    }
            
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
