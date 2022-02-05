//
//  PDFPresenter.swift
//  Utilities
//
//  Created by Andrew Watt on 8/21/18.
//

import Alamofire
import Logging
import RxSwift
import UIKit

public final class PDFPresenter {
    class InteractionDelegate: NSObject, UIDocumentInteractionControllerDelegate {
        private let viewController: UIViewController
        var completionHandler: (() -> Void)?
        
        init(viewController: UIViewController, completionHandler: @escaping () -> Void) {
            self.viewController = viewController
            self.completionHandler = completionHandler
        }
        
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            UINavigationBar.appearance().tintColor = viewController.navigationController?.navigationBar.tintColor ?? .black
            return viewController
        }
        
        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            completionHandler?()
        }
    }
    
    public init() { }

    public func presentPDF(atURL url: URL, fromViewController viewController: UIViewController) -> Completable {
        return download(url: url).flatMapCompletable { (fileURL) -> Completable in
            return Completable.create { (observer) -> Disposable in
                let delegate = InteractionDelegate(viewController: viewController) {
                    observer(.completed)
                }

                let controller = UIDocumentInteractionController(url: fileURL)
                controller.delegate = delegate

                if !controller.presentPreview(animated: true) {
                    observer(.error(PDFPresenterError.invalidFileForPreview))
                }
                
                return Disposables.create {
                    delegate.completionHandler = nil
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        log.error("Unable to delete temp PDF file at: \(fileURL)", context: error)
                    }
                }
            }
        }
    }
    
    private func download(url: URL) -> Single<URL> {
        let destination: DownloadRequest.DownloadFileDestination = { (temporaryURL, response) in
            let filename = response.suggestedFilename ?? "tempFile.pdf"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        func fileURL(fromDownloadResponse response: DefaultDownloadResponse) throws -> URL {
            if let error = response.error {
                throw error
            }
            guard let fileURL = response.destinationURL else {
                throw PDFPresenterError.emptyDestinationURL
            }
            return fileURL
        }

        return Single.create { (observer) -> Disposable in
            let request = Alamofire.download(url, to: destination).response { (response) in
                do {
                    let url = try fileURL(fromDownloadResponse: response)
                    observer(.success(url))
                } catch {
                    observer(.error(error))
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
}

enum PDFPresenterError: Error {
    case emptyDestinationURL
    case invalidFileForPreview
}
