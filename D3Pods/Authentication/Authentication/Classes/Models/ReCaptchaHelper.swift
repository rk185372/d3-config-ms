//
//  ReCaptchaHelper.swift
//  Authentication
//
//  Created by Branden Smith on 7/26/19.
//

import Foundation
import ReCaptcha

protocol ReCaptchaHelperDelegate: class {
    func reCaptchaDidSucceed(withToken token: String)
    func reCaptchaFailed(withError error: ReCaptchaError)
}

final class ReCaptchaHelper {

    private let apiKey: String
    private let baseURL: URL
    private let recaptchaWebViewTag = 9999

    private var reCaptcha: ReCaptcha?

    private weak var delegate: ReCaptchaHelperDelegate?

    init(apiKey: String, baseURL: URL, delegate: ReCaptchaHelperDelegate) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.delegate = delegate
    }

    func performReCaptcha(inView view: UIView) {
        self.reCaptcha = try? ReCaptcha(apiKey: apiKey, baseURL: baseURL)

        reCaptcha?.configureWebView { [weak self] webView in
            webView.frame = view.bounds

            let viewCenter = view.bounds.center

            let sizeScript = """
                var getSize = function() {
                    width = document.getElementsByTagName("div")[3].children[0].style.width;
                    height = document.getElementsByTagName("div")[3].children[0].style.height;
                    return {"width": parseInt(width,10), "height": parseInt(height,10)};
                };
                getSize();
            """

            webView.evaluateJavaScript(sizeScript, completionHandler: { size,_ in
                var width: Int = 300
                var height: Int = 480

                if let jsonResult = size as? [String: AnyObject] {
                    width = (jsonResult["width"] as! NSNumber).intValue
                    height = (jsonResult["height"] as! NSNumber).intValue
                }

                //Add bottom space for errors
                height += 40
                DispatchQueue.main.async {
                    webView.frame = CGRect(
                        x: Int(viewCenter.x.rounded()) - (width / 2),
                        y: Int(viewCenter.y.rounded()) - (height / 2),
                        width: width,
                        height: height
                    )

                    webView.layer.cornerRadius = 10.0
                    webView.clipsToBounds = true
                }
            })

            if let tag = self?.recaptchaWebViewTag {
                webView.tag = tag
            }
        }

        reCaptcha?.validate(on: view, resetOnError: false) { [weak self] result in
            do {
                let token = try result.dematerialize()
                self?.delegate?.reCaptchaDidSucceed(withToken: token)
            } catch {
                self?.delegate?.reCaptchaFailed(withError: error as! ReCaptchaError)
            }

            if let tag = self?.recaptchaWebViewTag {
                view.viewWithTag(tag)?.removeFromSuperview()
            }
        }

        #if DEBUG
            reCaptcha?.forceVisibleChallenge = true
        #endif
    }
}
