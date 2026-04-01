import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Saved QR Codes will appear here")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Saved")
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("BD QR Generator")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 0.7.0")
                    .foregroundStyle(.secondary)
                
                Text("A simple, no-login QR code generator for websites, WiFi, and contacts.\n\nNo account required. No data collection.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
        }
    }
}