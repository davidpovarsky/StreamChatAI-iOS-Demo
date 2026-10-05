//
//  DocumentPickerView.swift
//  AgentUI
//
//  Extracted existing DocumentPickerView unchanged.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

public struct DocumentPickerView: UIViewControllerRepresentable {
    public var onDocumentPicked: (URL, String) -> Void

    public init(onDocumentPicked: @escaping (URL, String) -> Void) {
        self.onDocumentPicked = onDocumentPicked
    }

    private static let supportedTypes: [UTType] = [
        .pdf,
        .plainText,
        .html,
        .commaSeparatedText,
        UTType(filenameExtension: "md") ?? .plainText
    ]

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: Self.supportedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL, String) -> Void

        init(onDocumentPicked: @escaping (URL, String) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let sourceURL = urls.first else { return }

            let fileName = sourceURL.lastPathComponent

            guard sourceURL.startAccessingSecurityScopedResource() else {
                return
            }
            defer { sourceURL.stopAccessingSecurityScopedResource() }

            let tempDir = FileManager.default.temporaryDirectory
            let tempURL = tempDir.appendingPathComponent(UUID().uuidString + "_" + fileName)

            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: sourceURL, to: tempURL)
                onDocumentPicked(tempURL, fileName)
            } catch {
                #if DEBUG
                print("Failed to copy document to temp directory: \(error)")
                #endif
            }
        }
    }
}
