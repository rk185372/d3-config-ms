#ifndef Fingerprint_h
#define Fingerprint_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SystemInformation : NSObject

@property NSString * _Nullable identc09a97bf8afcb8c0dc8cdf7f67c92901;
@property NSString * _Nullable identb52b76b8ae48041afbcf560f91d440a7;
@property NSString * _Nonnull ident20f35e630daf44dbfa4c3f68f5399d8c;
@property NSString * _Nonnull identb068931cc450442b63f5b3d276ea4297;
@property NSString * _Nonnull ident683e4b0d870013b03dad9adf9003f508;
@property NSString * _Nonnull ident2af72f100c356273d46284f6fd1dfc08;
@property BOOL ident6cfdc2e2399f0cf722b3f6de3075c54d;
@property BOOL ident61fa153f2827c887a48a351ae3c6cfd3;
@property BOOL ident0073c744e76e32a46d36953b1d849e5c;

@end

@interface Fingerprint : NSObject

@property SystemInformation * _Nonnull identb5b13193f2e0fadf91b5c67d0f59cc98;

@property CGSize ident30a1db1b990fee95c4f4fb5c56a9620e;

@property NSUUID * _Nonnull identef7c876f00f3acddd00fa671f52d0b1f;

@property NSString * _Nullable identaf9ad4037f4bb83ac9ceb5e118e6de1a;
@property NSString * _Nullable ident3a3cb397ade05a407f0d792e87f6f299;
@property NSDictionary * _Nullable identb8220f75ae614dc132b933cc07752f31;

-(id _Nonnull)initWithDevice:(UIDevice* _Nonnull)device
                userDefaults:(NSUserDefaults* _Nonnull)userDefaults
                      locale:(NSLocale* _Nonnull)locale;

@end


NSDictionary* _Nonnull fingerprintPropertyList(Fingerprint* _Nonnull fingerprint);


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static inline NSString* _Nonnull decryptString(char const* const _Nonnull data, size_t const length) {
    NSMutableData* const buffer = [NSMutableData dataWithBytes:data length:length];
    unsigned char* const bytes = [buffer mutableBytes];
    for (size_t i = 0; i < length; ++i) {
        bytes[i] ^= 0xFF;
    }
    return [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
}

#pragma clang diagnostic pop

#endif /* Fingerprint_h */
