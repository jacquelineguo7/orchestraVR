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
    
    @EnvironmentObject var positionModel: InstrumentPositions
    

    var body: some View {
        VStack (spacing: 120) {
            ToggleImmersiveSpaceButton()
            
            HStack {
                Button(action: {
                    if let pos = positionModel.positions["violin1_node"] {
                        positionModel.targetPosition = pos
                    }
                    print("Violin 1 Node tapped!")
                }) {
                    Text("Violin 1 Node")
                    .font(.body)
                }
                
                Button(action: {
                    
                    if let pos = positionModel.positions["violin2_node"] {
                        positionModel.targetPosition = pos
                    }
                    print("Violin 2 Node tapped!")

                }) {
                    Text("Violin 2 Node")
                    .font(.body)
                }
                
                Button(action: {
                    if let pos = positionModel.positions["viola_node"] {
                        positionModel.targetPosition = pos
                    }
                    print("Viola Node tapped!")

                }) {
                    Text("Viola Node")
                    .font(.body)
                }
                
                Button(action: {
                    
                    if let pos = positionModel.positions["cello_node"] {
                        positionModel.targetPosition = pos
                    }
                    print("Cello Node tapped!")

                }) {
                    Text("Cello Node")
                    .font(.body)
                }
            }
            
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
