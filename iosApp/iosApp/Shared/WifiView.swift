import SwiftUI
import Shared

struct WifiView: View {
    @ObservedObject var viewModel: QRViewModel
    @State private var ssid: String = ""
    @State private var password: String = ""
    @State private var showingSaveAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("WiFi Network Name (SSID)", text: $ssid)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                
                SecureField("WiFi Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .padding(.horizontal)
                    .onChange(of: password) { _, _ in
                        viewModel.generateWifiQR(ssid: ssid, password: password)
                    }
                    .onChange(of: ssid) { _, _ in
                        viewModel.generateWifiQR(ssid: ssid, password: password)
                    }
                
                if !ssid.isEmpty && !password.isEmpty {
                    if let bitmap = viewModel.wifiQrState.bitmap {
                        if let uiImage = UIImage(data: Data(bitmap)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.white)
                                .padding()
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: saveImage) {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button(action: { showingShareSheet = true }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else if viewModel.wifiQrState.isLoading {
                        ProgressView()
                            .frame(height: 300)
                    }
                } else {
                    Text("Enter WiFi details to generate a QR code")
                        .foregroundStyle(.secondary)
                        .frame(height: 300)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("WiFi QR")
            .sheet(isPresented: $showingShareSheet) {
                if let bitmap = viewModel.wifiQrState.bitmap {
                    if let uiImage = UIImage(data: Data(bitmap)) {
                        ShareSheet(items: [uiImage])
                    }
                }
            }
            .alert("Saved!", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func saveImage() {
        if let bitmap = viewModel.wifiQrState.bitmap {
            let image = UIImage(data: Data(bitmap))
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                showingSaveAlert = true
            }
        }
    }
}