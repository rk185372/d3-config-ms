/*
 
 TSKSPKIHashCache.h
 TrustKit
 
 The MIT License (MIT)
 
 Copyright (c) 2015 Data Theorem, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "TSKPublicKeyAlgorithm.h"

@import Foundation;
@import Security;

NS_ASSUME_NONNULL_BEGIN

// The identifier used for the default shared hash cache. Use this identifier
// in the TSKSPKIHashCache constructor to use the shared cache.
static NSString * const kTSKSPKISharedHashCacheIdentifier = @"spki-hash.cache";

// Each key is a raw certificate data (for easy lookup) and each value is the certificate's raw SPKI data
typedef NSMutableDictionary<NSData *, NSData *> SPKICacheDictionnary;

@interface TSKSPKIHashCache : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Create a new cache of SPKI hashes. The identifier is required to ensure that multiple cache
 instances do not attempt to use the same file on disk for persistence. If nil, persistence
 will be disabled (not recommended).
 @param uniqueIdentifier A unique identifier that is stable across app launches/instance creation
 @return An initialized hash cache.
 */
- (instancetype _Nullable)initWithIdentifier:(NSString * _Nullable)uniqueIdentifier NS_DESIGNATED_INITIALIZER;

/**
 Get a pin cache for the provided certificate and public key algorithm. The pins
 are cached so subsequent calls will be faster than the initial call.
 @param certificate The certificate containing the public key that will be hashed
 @param publicKeyAlgorithm The public algorithm to expect was used in this certificate
 @return The hash of the public key assuming it used the provided algorithm or nil if the hash could not be generated
 */
- (NSData * _Nullable)hashSubjectPublicKeyInfoFromCertificate:(SecCertificateRef)certificate publicKeyAlgorithm:(TSKPublicKeyAlgorithm)publicKeyAlgorithm;

@end

NS_ASSUME_NONNULL_END
