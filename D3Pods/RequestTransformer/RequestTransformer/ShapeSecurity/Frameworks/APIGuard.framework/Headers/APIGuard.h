
/*
 *
 * APIGuard.h
 * APIGuard
 * SDK Version 3.3.2
 *
 * Copyright (c) 2018 Shape Security, Inc. This source code and/or documentation is the confidential and copyrighted
 * property of Shape Security, Inc. All rights are reserved to Shape Security, Inc. The reproduction, preparation of
 * derivative works, distribution, public performance or public display of the source code and/or documentation is
 * not authorized unless expressly licensed.
 * Please contact
 *      Shape Security, Inc., Attn: Licensing Department,
 *      P.O. Box 772, Palo Alto, CA 94302
 *      licensing@shapesecurity.com
 *      650-399-0400
 * for information regarding commercial and/or trial license availability.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/******************** APIGuardDelegate ********************/

/*!
 *  @brief Delegate provided by the app to the SDK.
 */
@protocol APIGuardDelegate <NSObject>

@required

/*!
 *  @brief Method called by the SDK to let the app check the validity of the certificates.
 *  @param challenge The Authentication Challenge
 */
- (BOOL)checkCertificates:(NSURLAuthenticationChallenge *)challenge;

@optional
/*!
 *  @brief Method called by the SDK to log messages through the app (optional).
 *  @param string The message to log
 */
- (void)log:(NSString *)string;

@end

/******************** APIGuard ********************/

@interface APIGuard : NSObject

/*!
 *  @brief Return a shared instance of the main SDK object.
 *  @return The shared instance
 */

+ (nullable APIGuard *)sharedInstance;

/**
 @brief Initialize the SDK with environment and config filepath. Please note initialization should happen on main thread.
 
 @param environment must match the one which is defined in policy otherwise it will be a default environment
 @param configFilePath  fully qualified filepath of API Guard config file
 @return if initialized successfully, return YES. Otherwise, NO is returned
 */
- (BOOL)initializeWithConfigFile:(nullable NSString *)configFilePath withEnvironment:(NSString*)environment delegate:(id<APIGuardDelegate>)delegate;

/**
 @brief Initialize the SDK with a config filepath. Please note initialization should happen on main thread.
 
 @param configFilePath  fully qualified filepath of API Guard config file
 @return if initialized successfully, return YES. Otherwise, NO is returned
 */
- (BOOL)initializeWithConfigFile:(nullable NSString *)configFilePath delegate:(id<APIGuardDelegate>)delegate;

/**
 Transform a HTTP request that the app is about to send.
 
 @param request NSMutableURLRequest
 */
- (void)transformRequest:(NSMutableURLRequest *)request;

/**
 Transform a HTTP response that the app has received.
 
 @param response NSURLResponse to be parsed
 */

- (void)parseResponse:(NSURLResponse *)response;

/**
 Return the HTTP headers that the app must add to the request.
 Alternative to [transformRequest] for apps using 3rd-party networking libraries.
 
 @param url Full URL of the request
 @param body Body of the request
 @return Dictionary of HTTP headers to add to the request
 */
- (nullable NSDictionary<NSString *, NSString *> *)getRequestHeaders:(NSString *)url body:(nullable NSData *)body;

/**
 Decode the HTTP headers that were added by Shape to the server response.
 - Alternative to [parseResponse] for apps using 3rd-party networking libraries.
 
 @param headers Dictionary of the HTTP response headers.
 */
- (void)parseResponseHeaders:(NSDictionary<NSString *, NSString *> *)headers;

@end

NS_ASSUME_NONNULL_END
