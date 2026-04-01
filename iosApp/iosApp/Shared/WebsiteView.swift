import SwiftUI
import Shared

struct WebsiteView: View {
    @ObservedObject var viewModel: QRViewModel
    @State private var url: String = "https://authorbdmurphy.com"
    @State private var showingSaveAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Enter website URL", text: $url)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .onChange(of: url) { _, newValue in
                        viewModel.generateWebsiteQR(url: newValue)
                    }
                    .padding(.horizontal)
                
                if let bitmap = viewModel.websiteQrState.bitmap {
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
                } else if viewModel.websiteQrState.isLoading {
                    ProgressView()
                        .frame(height: 300)
                } else {
                    Text("Enter a URL to generate a QR code")
                        .foregroundStyle(.secondary)
                        .frame(height: 300)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Website QR")
            .sheet(isPresented: $showingShareSheet) {
                if let bitmap = viewModel.websiteQrState.bitmap {
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
        if let bitmap = viewModel.websiteQrState.bitmap {
            let image = UIImage(data: Data(bitmap))
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                showingSaveAlert = true
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}