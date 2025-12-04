import SwiftUI
import CoreImage
import WebKit
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#elseif os(iOS)
import UIKit
public typealias PlatformImage = Image
#endif

public struct QRCodeReader: View {
    #if os(macOS)
    @State private var selectedImage: PlatformImage?
    #else
    @State private var selectedImage: UIImage?
    #endif
    @State private var decodedMessage: String?
    @State private var openPanelPresented: Bool = false
    @State private var errorMessage: String?

    // State for InAppBrowser navigation
    @State private var browserURLString: String? = nil
    @State private var isBrowserVisible: Bool = false

    // Drag-and-drop state
    #if os(macOS)
    @State private var isDropTargeted: Bool = false
    #endif
    
    @State private var autoOpenUrl: Bool = true
    @State private var resetAfterOpen: Bool = true

    public init() {
    }
    
    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 5) {

                // Drop zone + preview
                Group {
                    if let image = selectedImage {
                        #if os(macOS)
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 100 , maxHeight: 100)
                            .border(Color.secondary, width: 1)
                        #else
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 100 , maxHeight: 100)
                            .border(Color.secondary, width: 1)
                        #endif
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 75)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                            #if os(macOS)
                                .stroke(
                                    (isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.5)),
                                    
                                    style: StrokeStyle(lineWidth:
                                        
                                        (isDropTargeted ? 3 : 1),
                                      
                                        dash: [6]
                                    )
                                )
                            #else
                                .stroke(
                                    Color.secondary.opacity(0.5),
                                   
                                    style: StrokeStyle(lineWidth:
                                      
                                        1,
                                        dash: [6]
                                    )
                                )
                            #endif
                        )
                    }
                }
                .contentShape(Rectangle())
                #if os(macOS)
                .onDrop(of: [UTType.image], isTargeted: $isDropTargeted) { providers in
                    handleDroppedProviders(providers)
                }
                #endif
                
                HStack(spacing: 0) {
                    Button("Choose Image…") {
                        pickImage()
                    }
                    .keyboardShortcut("o", modifiers: [.command])
                    
                    if selectedImage != nil {
                        Button("Clear") {
                            clear()
                        }
                    }
                }

                if let message = decodedMessage {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Decoded QR Message:")
                            .font(.headline)
                        Text(message)
                            .textSelection(.enabled)
                            .font(.body)
                            .padding(8)
#if os(macOS)
                            .background(
                                Color(NSColor.textBackgroundColor) )
                                #else
                                    .background(
                                Color(UIColor.secondarySystemBackground) )
                                #endif
                           
                            .cornerRadius(6)

                        if isLikelyURL(message) {
                            HStack(spacing: 12) {
                                NavigationLink {
                                    // In-app browser not implemented here
                                } label: {
                                    Label("Open in App", systemImage: "globe")
                                }

                                Button {
                                    openInSystemBrowser(message)
                                } label: {
                                    Label("Open in Browser", systemImage: "safari")
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                }

                Spacer()
            }
            .padding()
            .navigationTitle("QR Code Reader")
        }
    }
    
    private func pickImage() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.png, UTType.jpeg, UTType.tiff, UTType.bmp, UTType.gif, UTType.heic]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "Choose"

        if panel.runModal() == .OK, let url = panel.url {
            if let image = PlatformImage(contentsOf: url) {
                self.selectedImage = image
                self.errorMessage = nil
                // Decode immediately after selecting
                if let result = readQRCode(from: image) {
                    self.decodedMessage = result
                    self.browserURLString = isLikelyURL(result) ? result : nil
                    maybeAutoOpenURLIfNeeded(with: result)
                } else {
                    self.decodedMessage = nil
                    self.browserURLString = nil
                    self.errorMessage = "No QR code detected in the selected image."
                }
            } else {
                self.errorMessage = "Failed to load image from the selected file."
                self.selectedImage = nil
                self.decodedMessage = nil
                self.browserURLString = nil
            }
        }
        #else
        // TODO: Implement a SwiftUI-friendly image picker (e.g., PhotosPicker) for iOS.
        // For now, do nothing to keep the build compiling on iOS.
        #endif
    }
    
    private func clear() {
        selectedImage = nil
        decodedMessage = nil
        errorMessage = nil
        browserURLString = nil
    }
    
    // Handle drag-and-drop providers for images (macOS only)
    #if os(macOS)
    private func handleDroppedProviders(_ providers: [NSItemProvider]) -> Bool {
        // Prefer the first provider that can load an image
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) else {
            return false
        }
        // Try loading as NSImage directly
        if provider.canLoadObject(ofClass: NSImage.self) {
            _ = provider.loadObject(ofClass: NSImage.self) { object, error in
                // Convert to a concrete value before crossing actors to avoid sendability warnings.
                let loadedImage: NSImage?
                let errorText: String?

                if let img = object as? NSImage {
                    loadedImage = img
                    errorText = nil
                } else if let error {
                    loadedImage = nil
                    errorText = "Failed to load dropped image: \(error.localizedDescription)"
                } else {
                    loadedImage = nil
                    errorText = "Failed to load dropped image."
                }

                DispatchQueue.main.async {
                    if let img = loadedImage {
                        self.applyNewImageAndDecode(img)
                    } else if let errorText {
                        self.errorMessage = errorText
                    }
                }
            }
            return true
        }
        // Fallback: load data-representation
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
            DispatchQueue.main.async {
                if let data, let img = NSImage(data: data) {
                    self.applyNewImageAndDecode(img)
                } else if let error {
                    self.errorMessage = "Failed to load dropped image: \(error.localizedDescription)"
                } else {
                    self.errorMessage = "Failed to load dropped image."
                }
            }
        }
        return true
    }
    #endif
    
    #if os(macOS)
    private func applyNewImageAndDecode(_ image: NSImage) {
        self.selectedImage = image
        self.errorMessage = nil
        if let result = readQRCode(from: image) {
            self.decodedMessage = result
            self.browserURLString = isLikelyURL(result) ? result : nil
            maybeAutoOpenURLIfNeeded(with: result)
        } else {
            self.decodedMessage = nil
            self.browserURLString = nil
            self.errorMessage = "No QR code detected in the dropped image."
        }
    }
    #else
    private func applyNewImageAndDecode(_ image: UIImage) {
        self.selectedImage = image
        self.errorMessage = nil
        if let result = readQRCode(from: image) {
            self.decodedMessage = result
            self.browserURLString = isLikelyURL(result) ? result : nil
            maybeAutoOpenURLIfNeeded(with: result)
        } else {
            self.decodedMessage = nil
            self.browserURLString = nil
            self.errorMessage = "No QR code detected in the selected image."
        }
    }
    #endif
#if os(macOS)
    func readQRCode(from image: NSImage) -> String? {
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Error: Could not get CGImage from NSImage.")
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            print("Error: Could not create QR code detector.")
            return nil
        }
        
        let features = detector.features(in: ciImage)
        
        if let firstFeature = features.first as? CIQRCodeFeature {
            return firstFeature.messageString
        }
        return nil
    }
#else
    func readQRCode(from image: UIImage) -> String? {
        guard let cgImage = image.cgImage else {
            print("Error: Could not get CGImage from UIImage.")
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            print("Error: Could not create QR code detector.")
            return nil
        }
        
        let features = detector.features(in: ciImage)
        
        if let firstFeature = features.first as? CIQRCodeFeature {
            return firstFeature.messageString
        }
        return nil
    }
#endif
    // Simple URL check that also allows strings without scheme (adds https://)
    private func isLikelyURL(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        if let url = URL(string: trimmed), url.scheme != nil {
            return true
        }
        // try adding https:// if no scheme present
        let withScheme = "https://" + trimmed
        return URL(string: withScheme) != nil
    }

    // Open using the system default browser
    private func openInSystemBrowser(_ s: String) {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        var candidate = trimmed
        if !candidate.contains("://") {
            candidate = "https://" + candidate
        }
        guard let url = URL(string: candidate) else { return }
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #endif
    }
    
    // If autoOpenUrl is enabled and the decoded string is a URL, open it immediately.
    private func maybeAutoOpenURLIfNeeded(with decoded: String) {
        guard autoOpenUrl, isLikelyURL(decoded) else { return }
        openInSystemBrowser(decoded)
        
        if (resetAfterOpen) {
            clear()
        }
    }
}
