//
//  FISConnector.h
//  FIS
//
//  Created by Pablo Pellegrino on 25/11/2021.
//

#import <Foundation/Foundation.h>
#import "WebKit/WKWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FISConnector : NSObject

-(void) connectToWebView:(WKWebView*)webView withAllowedDomains:(NSArray<NSString*>*)domains;
-(void) connectToWebView:(WKWebView*)webView;

@end

NS_ASSUME_NONNULL_END
