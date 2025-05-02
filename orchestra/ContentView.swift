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
    

    var body: some View {
        VStack (spacing: 120) {
            ToggleImmersiveSpaceButton()
            
            HStack {
                Button(action: {
                    instrumentPositions.selectedInstrumentName = "violin1_node"
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
                    if let pos = instrumentPositions.positions["cello_node"] {
                        instrumentPositions.targetPosition = pos
                        print("Set targetPosition to \(pos)")
                    }
                    print("Cello Node tapped!")

                }) {
                    Text("Cello Node")
                    .font(.body)
                }
                
                Button("Reset position") {
                    // Set a test position (e.g., 2 meters forward)
                    instrumentPositions.selectedInstrumentName = "reset_node"
                    instrumentPositions.targetPosition = SIMD3<Float>(0, 0, -4)
                    print("Set targetPosition to \(instrumentPositions.targetPosition)")
                }

            }
            
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
