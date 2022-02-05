#ifndef Types_h
#define Types_h


uint32_t obfuscate(uint32_t i, uint32_t nonce);
NSData* _Nonnull obfuscateData(NSData* _Nonnull data);
NSData* _Nullable deobfuscateData(NSData* _Nonnull obfuscatedData);

NSString* _Nonnull urlSafeBase64Encode(NSData* const _Nonnull data);

@protocol Deserialize

-(id _Nullable)initWithJSON:(NSDictionary* _Nonnull)data;

@end


@interface De<T> : NSObject

+(id _Nullable)fromData:(T _Nonnull)self_ data:(NSData* _Nonnull)data error:(NSError* _Nullable * _Nonnull)error;

@end


@interface AuthenticationProtocol : NSObject

@property NSString* _Nonnull version;
@property NSString* _Nonnull product;

- (id _Nonnull)initWithVersion:(NSString* _Nonnull)version product:(NSString* _Nonnull)product;

@end


@interface Challenge : NSObject <Deserialize>

@property NSString* _Nonnull session;
@property NSString* _Nonnull question;

@end


@interface Token : NSObject <Deserialize>

@property NSString* _Nonnull token;
@property NSTimeInterval expiresIn;
@property NSString* _Nullable debugInformation;

-(id _Nonnull)initWithToken:(NSString* _Nonnull)token expiresIn:(NSTimeInterval)expiresIn;

-(NSDictionary* _Nonnull) propertyList;

@end


NSString* _Nullable encodeManifest(NSString* _Nonnull const applicationManifest,
                                   NSString* _Nullable oldToken,
                                   NSError* _Nullable * _Nonnull error);

NSString* _Nullable encodeResponse(NSString* _Nonnull session,
                                   NSString* _Nonnull answer,
                                   NSString* _Nonnull debugToken,
                                   NSError* _Nonnull * _Nullable error);


@interface ExpiryToken : NSObject <Deserialize>

@property NSString* _Nonnull token;
@property NSTimeInterval expiryTime;

-(id _Nonnull)initWithToken:(NSString* _Nonnull)token expiryTime:(NSTimeInterval)expiryTime;

-(NSDictionary* _Nonnull) propertyList;

@end

NSObject* _Nonnull valueOrNull(NSObject* _Nullable x);

#endif /* Types_h */
