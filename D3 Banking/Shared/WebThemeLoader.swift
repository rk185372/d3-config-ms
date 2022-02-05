//
//  WebThemeLoader.swift
//  D3 Banking
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 5/17/21.
//

import Foundation
import RxSwift

protocol WebThemeLoader {
    func loadWebTheme() -> Single<Data>
}

final class WebFileThemeLoader: WebThemeLoader {
    
    private let fileUrl: URL
    
    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    func loadWebTheme() -> Single<Data> {
        return Single.create { observer in
            do {
                let contents = try Data(contentsOf: self.fileUrl)
                observer(.success(contents))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
