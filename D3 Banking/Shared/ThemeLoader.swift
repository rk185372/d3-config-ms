//
//  ThemeLoader.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/2/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import RxSwift

protocol ThemeLoader {
    func loadTheme() -> Single<[String: Any]>
}

final class FileThemeLoader: ThemeLoader {
    private let fileUrl: URL
    
    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    func loadTheme() -> Single<[String: Any]> {
        return Single.create { observer in
            do {
                let contents = try Data(contentsOf: self.fileUrl)
                let theme = try JSONSerialization.jsonObject(with: contents) as! [String: Any]
                observer(.success(theme))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
