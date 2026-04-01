import UIKit
import AVFoundation
import CoreImage.CIFilterBuiltins
import PhotosUI
import ContactsUI

class ViewController: UIViewController {
    
    private let logoImageView = UIImageView()
    private let segmentedControl = UISegmentedControl(items: ["Website", "WiFi", "Contact", "Saved"])
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let urlTextField = UITextField()
    private let ssidTextField = UITextField()
    private let passwordTextField = UITextField()
    private let nameTextField = UITextField()
    private let phoneTextField = UITextField()
    private let emailTextField = UITextField()
    private let qrImageView = UIImageView()
    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let savedCollectionView: UICollectionView
    
    private var currentMode = 0
    private var savedImages: [UIImage] = []
    private var savedImageAssets: [PHAsset] = []
    private var isSelectionMode = false
    private var selectedIndexes: Set<Int> = []
    private let editButton = UIBarButtonItem(title: "Select", style: .plain, target: nil, action: nil)
    private let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: nil, action: nil)
    private let shareButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: nil, action: nil)
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        savedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentMode == 3 {
            loadSavedPhotos()
        } else {
            generateQR()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "BD QR Generator"
        
        let logoImage = UIImage(named: "App_icon_QRGen.png")
        logoImageView.image = logoImage
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let titleLabel = UILabel()
        titleLabel.text = "BD QR Generator"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.sizeToFit()
        
        let titleStack = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center
        titleStack.frame = CGRect(x: 0, y: 0, width: titleLabel.frame.width + 40, height: 30)
        
        navigationItem.titleView = titleStack
        
        editButton.target = self
        editButton.action = #selector(toggleSelectionMode)
        navigationItem.rightBarButtonItem = editButton
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupWebsiteMode()
        setupWifiMode()
        setupContactMode()
        setupSavedMode()
        
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.backgroundColor = .white
        qrImageView.layer.borderWidth = 1
        qrImageView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.addSubview(qrImageView)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.38, green: 0, blue: 0.93, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        contentView.addSubview(saveButton)
        
        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = UIColor(red: 0.38, green: 0, blue: 0.93, alpha: 1.0)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.layer.cornerRadius = 8
        shareButton.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        contentView.addSubview(shareButton)
        
        updateMode()
        
        urlTextField.text = "https://authorbdmurphy.com"
        generateQR()
    }
    
    private func setupWebsiteMode() {
        urlTextField.placeholder = "Enter website URL"
        urlTextField.borderStyle = .roundedRect
        urlTextField.keyboardType = .URL
        urlTextField.autocapitalizationType = .none
        urlTextField.autocorrectionType = .no
        urlTextField.addTarget(self, action: #selector(generateQR), for: .editingChanged)
        urlTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        contentView.addSubview(urlTextField)
    }
    
    private func setupWifiMode() {
        ssidTextField.placeholder = "WiFi Network Name (SSID)"
        ssidTextField.borderStyle = .roundedRect
        ssidTextField.addTarget(self, action: #selector(generateQR), for: .editingChanged)
        contentView.addSubview(ssidTextField)
        
        passwordTextField.placeholder = "WiFi Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.addTarget(self, action: #selector(generateQR), for: .editingChanged)
        contentView.addSubview(passwordTextField)
    }
    
    private func setupContactMode() {
        nameTextField.placeholder = "Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.addTarget(self, action: #selector(generateQR), for: .editingChanged)
        contentView.addSubview(nameTextField)
        
        phoneTextField.placeholder = "Phone Number"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        phoneTextField.addTarget(self, action: #selector(generateQR), for: .editingChanged)
        contentView.addSubview(phoneTextField)
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.addTarget(self, action: #selector(generateQR), for: .editingChanged)
        contentView.addSubview(emailTextField)
        
        let contactButton = UIButton(type: .system)
        contactButton.setTitle("Select Contact", for: .normal)
        contactButton.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        contactButton.backgroundColor = UIColor(red: 0.38, green: 0, blue: 0.93, alpha: 1.0)
        contactButton.setTitleColor(.white, for: .normal)
        contactButton.tintColor = .white
        contactButton.layer.cornerRadius = 8
        contactButton.addTarget(self, action: #selector(selectContact), for: .touchUpInside)
        contactButton.tag = 100
        contentView.addSubview(contactButton)
    }
    
    private func setupSavedMode() {
        savedCollectionView.backgroundColor = .systemBackground
        savedCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SavedCell")
        savedCollectionView.dataSource = self
        savedCollectionView.delegate = self
        savedCollectionView.isHidden = true
        contentView.addSubview(savedCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navBarHeight = (navigationController?.navigationBar.frame.maxY ?? 44)
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 44
        let totalTop = navBarHeight + statusBarHeight
        
        segmentedControl.frame = CGRect(x: 20, y: totalTop + 10, width: view.frame.width - 40, height: 35)
        
        let scrollY = segmentedControl.frame.maxY + 10
        let availableHeight = view.frame.height - scrollY
        scrollView.frame = CGRect(x: 0, y: scrollY, width: view.frame.width, height: availableHeight)
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight)
        
        let textFieldWidth = view.frame.width - 40
        let padding: CGFloat = 20
        let buttonHeight: CGFloat = 40
        var y: CGFloat = 20
        
        switch currentMode {
        case 0:
            urlTextField.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
            y += buttonHeight + 15
        case 1:
            ssidTextField.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
            y += buttonHeight + 10
            passwordTextField.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
            y += buttonHeight + 15
        case 2:
            nameTextField.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
            y += buttonHeight + 10
            phoneTextField.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
            y += buttonHeight + 10
            emailTextField.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
            y += buttonHeight + 10
            if let contactButton = contentView.viewWithTag(100) {
                contactButton.frame = CGRect(x: padding, y: y, width: textFieldWidth, height: buttonHeight)
                y += buttonHeight + 15
            }
        case 3:
            savedCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight)
            y = availableHeight + 100
        default:
            break
        }
        
        if currentMode < 3 {
            let qrSize = min(textFieldWidth, availableHeight - y - buttonHeight - 30)
            qrImageView.frame = CGRect(x: padding, y: y, width: qrSize, height: qrSize)
            y += qrSize + 15
            
            let buttonWidth = (textFieldWidth - 20) / 2
            saveButton.frame = CGRect(x: padding, y: y, width: buttonWidth, height: buttonHeight)
            shareButton.frame = CGRect(x: padding + buttonWidth + 20, y: y, width: buttonWidth, height: buttonHeight)
        }
    }
    
    @objc private func segmentChanged() {
        currentMode = segmentedControl.selectedSegmentIndex
        updateMode()
        view.setNeedsLayout()
        
        if currentMode == 3 {
            loadSavedPhotos()
        }
    }
    
    private func updateMode() {
        let isQRMode = currentMode < 3
        urlTextField.isHidden = currentMode != 0
        ssidTextField.isHidden = currentMode != 1
        passwordTextField.isHidden = currentMode != 1
        nameTextField.isHidden = currentMode != 2
        phoneTextField.isHidden = currentMode != 2
        emailTextField.isHidden = currentMode != 2
        contentView.viewWithTag(100)?.isHidden = currentMode != 2
        qrImageView.isHidden = currentMode == 3
        saveButton.isHidden = currentMode == 3
        shareButton.isHidden = currentMode == 3
        savedCollectionView.isHidden = currentMode != 3
        
        if currentMode < 3 && qrImageView.image == nil {
            generateQR()
        }
    }
    
    @objc private func textFieldDidEndEditing() {
        generateQR()
    }
    
    @objc private func generateQR() {
        var data: String?
        var displayText: String = ""
        
        switch currentMode {
        case 0:
            data = urlTextField.text
            displayText = urlTextField.text ?? ""
        case 1:
            let ssid = ssidTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            if !ssid.isEmpty && !password.isEmpty {
                data = "WIFI:T:WPA;S:\(ssid);P:\(password);;"
                displayText = "Network: \(ssid)\nPassword: \(password)"
            }
        case 2:
            let name = nameTextField.text ?? ""
            let phone = phoneTextField.text ?? ""
            let email = emailTextField.text ?? ""
            if !name.isEmpty {
                data = "BEGIN:VCARD\nVERSION:3.0\nFN:\(name)\nTEL:\(phone)\nEMAIL:\(email)\nEND:VCARD"
                displayText = "Name: \(name)"
                if !phone.isEmpty { displayText += "\nPhone: \(phone)" }
                if !email.isEmpty { displayText += "\nEmail: \(email)" }
            }
        default:
            break
        }
        
        guard let qrData = data, !qrData.isEmpty else {
            qrImageView.image = nil
            return
        }
        
        let qrImage = generateQRCodeImage(qrData)
        
        if displayText.isEmpty {
            qrImageView.image = qrImage
            return
        }
        
        if let combinedImage = addTextToImage(qrImage, text: displayText) {
            qrImageView.image = combinedImage
        } else {
            qrImageView.image = qrImage
        }
    }
    
    private func generateQRCodeImage(_ content: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(content.utf8)
        filter.correctionLevel = "H"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func addTextToImage(_ image: UIImage?, text: String) -> UIImage? {
        guard let qrImage = image else { return nil }
        
        let qrSize = qrImage.size
        let scale = qrImage.scale
        let width = Int(qrSize.width * scale)
        let height = Int(qrSize.height * scale)
        
        let fontSize: CGFloat = max(14, CGFloat(width) / 25)
        let font = UIFont.systemFont(ofSize: fontSize)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let maxTextWidth = CGFloat(width - 40)
        let wrappedLines = wrapText(text, font: font, maxWidth: maxTextWidth)
        
        let lineHeight = font.ascender - font.descender + 4
        let textAreaHeight = CGFloat(wrappedLines.count) * lineHeight + 20
        
        let totalHeight = height + Int(textAreaHeight)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(width), height: CGFloat(totalHeight)), false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(totalHeight)))
        
        qrImage.draw(at: CGPoint(x: 0, y: 0))
        
        let textY = CGFloat(height) + 15
        let centerX = CGFloat(width) / 2
        for (index, line) in wrappedLines.enumerated() {
            let y = textY + CGFloat(index) * lineHeight
            let lineSize = line.size(withAttributes: attributes)
            let x = centerX - lineSize.width / 2
            line.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
        }
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    private func wrapText(_ text: String, font: UIFont, maxWidth: CGFloat) -> [String] {
        let lines = text.components(separatedBy: "\n")
        var wrappedLines: [String] = []
        
        for line in lines {
            let nsLine = line as NSString
            let lineWidth = nsLine.size(withAttributes: [.font: font]).width
            
            if lineWidth <= maxWidth {
                wrappedLines.append(line)
            } else {
                var currentLine = ""
                let words = line.components(separatedBy: " ")
                
                for word in words {
                    let testLine = currentLine.isEmpty ? word : "\(currentLine) \(word)"
                    let testWidth = (testLine as NSString).size(withAttributes: [.font: font]).width
                    
                    if testWidth <= maxWidth {
                        currentLine = testLine
                    } else {
                        if !currentLine.isEmpty {
                            wrappedLines.append(currentLine)
                        }
                        currentLine = word
                    }
                }
                
                if !currentLine.isEmpty {
                    wrappedLines.append(currentLine)
                }
            }
        }
        
        return wrappedLines
    }
    
    @objc private func saveImage() {
        guard qrImageView.image != nil else {
            showAlert(title: "No QR Code", message: "Please generate a QR code first.")
            return
        }
        
        guard let image = qrImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            showAlert(title: "Error", message: "Failed to save QR code.")
        } else {
            showAlert(title: "Saved!", message: "QR code saved to photos.")
        }
    }
    
    @objc private func shareImage() {
        guard qrImageView.image != nil else {
            showAlert(title: "No QR Code", message: "Please generate a QR code first.")
            return
        }
        
        guard let image = qrImageView.image else { return }
        
        let activityItems: [Any] = [image]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToVimeo,
            .postToFlickr,
            .postToTencentWeibo
        ]
        
        present(activityVC, animated: true)
    }
    
    @objc private func selectContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        present(contactPicker, animated: true)
    }
    
    private func loadSavedPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    self?.fetchSavedImages()
                } else {
                    self?.showAlert(title: "Permission Required", message: "Please allow access to Photos in Settings.")
                }
            }
        }
    }
    
    private func fetchSavedImages() {
        savedImages.removeAll()
        savedImageAssets.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        var count = 0
        allPhotos.enumerateObjects { (asset, _, stop) in
            if count >= 50 { stop.pointee = true; return }
            self.savedImageAssets.append(asset)
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 1200, height: 1200), contentMode: .aspectFit, options: options) { image, info in
                if let image = image {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                    if !isDegraded {
                        DispatchQueue.main.async {
                            self.savedImages.append(image)
                            self.savedCollectionView.reloadData()
                        }
                    }
                }
            }
            count += 1
        }
        
        savedCollectionView.reloadData()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            if selectedIndexes.contains(indexPath.item) {
                selectedIndexes.remove(indexPath.item)
            } else {
                selectedIndexes.insert(indexPath.item)
            }
            updateSelectedCount()
            collectionView.reloadData()
        } else {
            let image = savedImages[indexPath.item]
            
            let fullScreenVC = FullScreenImageViewController(image: image)
            fullScreenVC.modalPresentationStyle = .fullScreen
            present(fullScreenVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(image: savedImages[indexPath.item])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.frame = cell.contentView.bounds
        cell.contentView.addSubview(imageView)
        
        if isSelectionMode {
            let checkmark = UIImageView(image: UIImage(systemName: selectedIndexes.contains(indexPath.item) ? "checkmark.circle.fill" : "circle"))
            checkmark.tintColor = selectedIndexes.contains(indexPath.item) ? .systemBlue : .white
            checkmark.frame = CGRect(x: cell.contentView.bounds.width - 30, y: 5, width: 25, height: 25)
            checkmark.tag = 999
            cell.contentView.addSubview(checkmark)
            
            if selectedIndexes.contains(indexPath.item) {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                cell.contentView.layer.borderWidth = 0
            }
        } else {
            cell.contentView.layer.borderWidth = 0
        }
        
        return cell
    }
}

class FullScreenImageViewController: UIViewController {
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let closeButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.frame = CGRect(x: view.frame.width - 60, y: 50, width: 40, height: 40)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        view.addSubview(shareButton)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func shareTapped() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = recognizer.location(in: imageView)
            let rect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
            scrollView.zoom(to: rect, animated: true)
        }
    }
}

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ViewController {
    @objc private func toggleSelectionMode() {
        isSelectionMode = !isSelectionMode
        selectedIndexes.removeAll()
        
        if isSelectionMode {
            editButton.title = "Cancel"
            deleteButton.target = self
            deleteButton.action = #selector(deleteSelectedImages)
            deleteButton.tintColor = .red
            
            shareButtonItem.target = self
            shareButtonItem.action = #selector(shareSelectedImages)
            shareButtonItem.tintColor = .systemBlue
            
            navigationItem.rightBarButtonItems = [editButton, deleteButton, shareButtonItem]
        } else {
            editButton.title = "Select"
            navigationItem.rightBarButtonItem = editButton
        }
        
        savedCollectionView.reloadData()
    }
    
    @objc private func deleteSelectedImages() {
        guard !selectedIndexes.isEmpty else {
            showAlert(title: "No Selection", message: "Please select images to delete.")
            return
        }
        
        let alert = UIAlertController(title: "Delete \(selectedIndexes.count) Image(s)?", message: "This will remove the selected images from your photo library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        present(alert, animated: true)
    }
    
    private func performDelete() {
        let assetsToDelete = selectedIndexes.map { savedImageAssets[$0] }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.selectedIndexes.removeAll()
                    self?.isSelectionMode = false
                    self?.editButton.title = "Select"
                    self?.navigationItem.rightBarButtonItem = self?.editButton
                    self?.loadSavedPhotos()
                    self?.showAlert(title: "Deleted", message: "Selected images have been deleted.")
                } else {
                    self?.showAlert(title: "Error", message: "Failed to delete images.")
                }
            }
        }
    }
    
    @objc private func shareSelectedImages() {
        guard !selectedIndexes.isEmpty else {
            showAlert(title: "No Selection", message: "Please select images to share.")
            return
        }
        
        let imagesToShare = selectedIndexes.map { savedImages[$0] }
        let activityVC = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func updateSelectedCount() {
        if isSelectionMode {
            if selectedIndexes.isEmpty {
                deleteButton.isEnabled = false
                shareButtonItem.isEnabled = false
            } else {
                deleteButton.isEnabled = true
                shareButtonItem.isEnabled = true
                deleteButton.title = "Delete (\(selectedIndexes.count))"
                shareButtonItem.title = "Share (\(selectedIndexes.count))"
            }
        }
    }
}

extension ViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        nameTextField.text = fullName.isEmpty ? nil : fullName
        
        if let phone = contact.phoneNumbers.first?.value.stringValue {
            phoneTextField.text = phone
        }
        
        if let email = contact.emailAddresses.first?.value as String? {
            emailTextField.text = email
        }
        
        generateQR()
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        return true
    }
}