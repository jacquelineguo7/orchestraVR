//
//  orchestraApp.swift
//  orchestra
//
//  Created by Jacqueline Guo on 4/28/25.
//

import SwiftUI
import simd

@main
struct orchestraApp: App {

    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()
    @StateObject var instrumentPositions = InstrumentPositions()

    var body: some Scene {
        WindowGroup {
            if avPlayerViewModel.isPlaying {
                AVPlayerView(viewModel: avPlayerViewModel)
            } else {
                ContentView()
                    .environmentObject(instrumentPositions)
                    .environment(appModel)
            }
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environmentObject(instrumentPositions)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                    avPlayerViewModel.play()
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    avPlayerViewModel.reset()
                }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
