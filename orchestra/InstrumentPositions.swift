//
//  PositionModel.swift
//  orchestra
//
//  Created by Jacqueline Guo on 4/30/25.
//
import SwiftUI
import simd

class InstrumentPositions: ObservableObject {
    @Published var positions: [String: SIMD3<Float>] = [:]
    @Published var targetPosition: SIMD3<Float> = .zero
    @Published var selectedInstrumentName: String = ""
}
