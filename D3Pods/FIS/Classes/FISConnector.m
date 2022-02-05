//
//  FISManager.m
//  FIS
//
//  Created by Pablo Pellegrino on 25/11/2021.
//

#import "FISConnector.h"

@import FISDigitalPaymentsSDK;

@implementation FISConnector

+(NSArray<NSString*>*) defaultDomains {
    return @[@"epayments-crossdomain-fnc.billdomain.com",
             @"epayments-epayui-fnc-3.money-movement.com",
             @"epayments-epayui-uat-3.money-movement.com"];;
}

-(void) connectToWebView:(WKWebView*)webView withAllowedDomains:(NSArray<NSString*>*)domains {
    [FDSSDKManager createWithWebView:webView domainWhitelist:domains webEventListener: nil];
}

-(void) connectToWebView:(WKWebView*)webView {
    [FDSSDKManager createWithWebView:webView domainWhitelist:[FISConnector defaultDomains] webEventListener: nil];
}

@end
