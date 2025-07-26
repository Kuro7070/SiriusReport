//
//  SaveAnimationView.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import SwiftUI

struct SaveAnimationView: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            VStack {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .scaleEffect(isVisible ? 1 : 0.5)
                    .animation(.spring(), value: isVisible)

                Text("Report gespeichert")
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 10)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}
