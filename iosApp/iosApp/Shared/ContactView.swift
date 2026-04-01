import SwiftUI
import Shared

struct ContactView: View {
    @ObservedObject var viewModel: QRViewModel
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var showingSaveAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                
                TextField("Phone Number", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                    .onChange(of: name) { _, _ in
                        viewModel.generateContactQR(name: name, phone: phone, email: email)
                    }
                    .onChange(of: phone) { _, _ in
                        viewModel.generateContactQR(name: name, phone: phone, email: email)
                    }
                    .onChange(of: email) { _, _ in
                        viewModel.generateContactQR(name: name, phone: phone, email: email)
                    }
                
                if !name.isEmpty && (!phone.isEmpty || !email.isEmpty) {
                    if let bitmap = viewModel.contactQrState.bitmap {
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
                    } else if viewModel.contactQrState.isLoading {
                        ProgressView()
                            .frame(height: 300)
                    }
                } else {
                    Text("Enter contact details to generate a QR code")
                        .foregroundStyle(.secondary)
                        .frame(height: 300)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Contact QR")
            .sheet(isPresented: $showingShareSheet) {
                if let bitmap = viewModel.contactQrState.bitmap {
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
        if let bitmap = viewModel.contactQrState.bitmap {
            let image = UIImage(data: Data(bitmap))
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                showingSaveAlert = true
            }
        }
    }
}