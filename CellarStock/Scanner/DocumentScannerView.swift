//
//  DocumentScannerView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 03/12/2023.
//

import Combine
import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedText: String
    var listener: PassthroughSubject<Bool, Never>

    static let textDataType: DataScannerViewController.RecognizedDataType = .text(languages: [
        "fr-FR",
        "en-US",
    ])

    var scannerViewController: DataScannerViewController = DataScannerViewController(recognizedDataTypes: [
        DocumentScannerView.textDataType
    ],
    qualityLevel: .accurate,
    recognizesMultipleItems: false,
    isHighFrameRateTrackingEnabled: false,
    isHighlightingEnabled: true)

    func makeUIViewController(context: Context) -> DataScannerViewController {
        scannerViewController.delegate = context.coordinator
        context.coordinator.startScanning()
        return scannerViewController
    }

    func updateUIViewController(_: DataScannerViewController, context _: Context) {
        // Update any view controller settings here
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, listener: listener)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DocumentScannerView
        var cancellables: Set<AnyCancellable> = []

        private var listener: PassthroughSubject<Bool, Never>
        private var roundBoxMappings: [UUID: UIView] = [:]
        private var transcript: String?

        init(_ parent: DocumentScannerView, listener: PassthroughSubject<Bool, Never>) {
            self.parent = parent
            self.listener = listener
            super.init()
            subscribe()
        }

        func subscribe() {
            listener.sink { [weak self] _ in
                guard let self else { return }
                stopScanning()
                parent.selectedText = buildScannedText(transcript?.capitalized ?? "")
                parent.dismiss()
            }.store(in: &cancellables)
        }

        func dataScanner(_: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems _: [RecognizedItem]) {
            processAddedItems(items: addedItems)
        }

        func dataScanner(_: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems _: [RecognizedItem]) {
            processRemovedItems(items: removedItems)
        }

        func dataScanner(_: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems _: [RecognizedItem]) {
            processUpdatedItems(items: updatedItems)
        }

        func dataScanner(_: DataScannerViewController, didTapOn item: RecognizedItem) {
            processItem(item: item)
            if case let .text(text) = item {
                stopScanning()
                parent.selectedText = buildScannedText(text.transcript.capitalized)
                parent.dismiss()
            }
        }

        func processAddedItems(items: [RecognizedItem]) {
            for item in items {
                processItem(item: item)
            }
        }

        func processRemovedItems(items: [RecognizedItem]) {
            for item in items {
                removeRoundBoxFromItem(item: item)
            }
        }

        func processUpdatedItems(items: [RecognizedItem]) {
            for item in items {
                updateRoundBoxToItem(item: item)
            }
        }

        func addRoundBoxToItem(frame: CGRect, text: String, item: RecognizedItem) {
            let roundedRectView = RoundedRectLabel(frame: frame)
            roundedRectView.setText(text: text)
            parent.scannerViewController.overlayContainerView.addSubview(roundedRectView)
            roundBoxMappings[item.id] = roundedRectView
        }

        func removeRoundBoxFromItem(item: RecognizedItem) {
            if let roundBoxView = roundBoxMappings[item.id] {
                if roundBoxView.superview != nil {
                    roundBoxView.removeFromSuperview()
                    roundBoxMappings.removeValue(forKey: item.id)
                }
            }
        }

        func updateRoundBoxToItem(item: RecognizedItem) {
            if let roundBoxView = roundBoxMappings[item.id] {
                if roundBoxView.superview != nil {
                    let frame = getRoundBoxFrame(item: item)
                    roundBoxView.frame = frame
                }
            }
        }

        func getRoundBoxFrame(item: RecognizedItem) -> CGRect {
            CGRect(x: item.bounds.topLeft.x,
                   y: item.bounds.topLeft.y,
                   width: abs(item.bounds.topRight.x - item.bounds.topLeft.x) + CharterConstants.margin,
                   height: abs(item.bounds.topLeft.y - item.bounds.bottomLeft.y) + CharterConstants.margin)
        }

        func processItem(item: RecognizedItem) {
            switch item {
            case let .text(text):
                print("Text Observation - \(text.observation)")
                print("Text transcript - \(text.transcript)")
                transcript = text.transcript
                let frame = getRoundBoxFrame(item: item)
                addRoundBoxToItem(frame: frame, text: text.transcript, item: item)
            case .barcode:
                break
            @unknown default:
                print("Should not happen")
            }
        }

        func startScanning() {
            try? parent.scannerViewController.startScanning()
        }

        func stopScanning() {
            parent.scannerViewController.stopScanning()
        }

        func buildScannedText(_ selectedText: String) -> String {
            let lines = selectedText.components(separatedBy: "\n")
            return Helper().formatArrayWineName(lines: lines)
        }
    }
}
