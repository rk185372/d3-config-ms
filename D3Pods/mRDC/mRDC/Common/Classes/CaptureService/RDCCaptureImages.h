//
//  RDCCaptureImages.h
//  Pods
//
//  Created by Chris Carranza on 7/11/17.
//
//

#import <Foundation/Foundation.h>

@interface RDCCaptureImages : NSObject

@property (readonly, nonatomic, strong, nonnull) NSString *encodedFrontImage;
@property (readonly, nonatomic, strong, nonnull) NSString *encodedBackImage;
@property (readonly, nonatomic, strong, nullable) NSString *encodedOrigFrontImage;
@property (readonly, nonatomic, strong, nullable) NSString *encodedOrigBackImage;

- (instancetype _Nonnull) initWithFront: (NSData * _Nonnull)front back: (NSData * _Nonnull)back;
- (instancetype _Nonnull) initWithEncodedFront: (NSString * _Nonnull)front encodedBack: (NSString * _Nonnull)back;
- (instancetype _Nonnull) initWithFront: (NSData * _Nonnull)front back: (NSData * _Nonnull)back origFront: (NSData * _Nullable)origFront origBack: (NSData * _Nullable)origBack;
- (instancetype _Nonnull) initWithEncodedFront:(NSString * _Nonnull)front encodedBack:(NSString * _Nonnull)back origFront: (NSData * _Nullable)origFront origBack: (NSData * _Nullable)origBack;

@end
