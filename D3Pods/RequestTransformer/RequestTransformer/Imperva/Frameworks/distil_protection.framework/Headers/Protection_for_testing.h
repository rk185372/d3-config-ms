#ifndef Protection_internal_h
#define Protection_internal_h

#import "ProblemSolver.h"
#import "Errors.h"

@interface ExpiryError : NSObject

@property NSError* _Nonnull const error;
@property NSTimeInterval const cacheTime;


-(id _Nonnull) initWithError:(NSError* const _Nonnull)error_ cacheTime:(NSTimeInterval)cacheTime_;

@end

@protocol ProtectionProtocol <NSObject>

-(void) getTokenWithOldToken:(NSString* _Nullable)oldToken completionHandler:(void (^ _Nonnull)(Token* _Nullable, ExpiryError* _Nullable))completionHandler;

@end

@interface UncachedProtection : NSObject <ProtectionProtocol>

- (nullable NSString*)getToken:(NSError* _Nullable* _Nonnull)error;

-(NSURL* _Nullable)createQuery:(NSArray* _Nonnull)queryItems;

-(id _Nonnull) initWithChallengeUrl:(NSURL * _Nonnull)challengeUrl_
                                 debugKey:(NSString * _Nullable)debugKey;

-(id _Nonnull) initWithChallengeUrl:(NSURL * _Nonnull)challengeUrl
                                  session:(NSURLSession* _Nonnull)session
                                 debugKey:(NSString * _Nullable)debugKey;

-(id _Nonnull) initWithChallengeUrl:(NSURL * _Nonnull)challengeUrl
           applicationManifest:(NSString * _Nonnull)applicationManifest
                       session:(NSURLSession* _Nonnull)session
                 problemSolver:(id<ProblemSolver> _Nonnull)problemSolver
                    debugKey:(NSString * _Nullable)debugKey;
@end


@interface Protection()

- (id _Nonnull)initWithProtection:(UncachedProtection* _Nonnull)protection;

+(NSString* _Nonnull)cacheKey;

-(id _Nonnull)initWithUserDefaults:(NSUserDefaults* _Nonnull)userDefaults
                     monotonicTime:(NSTimeInterval (^ _Nonnull)(void))monotonicTime
                        protection:(UncachedProtection* _Nonnull)protection;

-(id _Nonnull)initWithUserDefaults:(NSUserDefaults* _Nonnull)userDefaults
                     monotonicTime:(NSTimeInterval (^ _Nonnull)(void))monotonicTime
                        protection:(UncachedProtection* _Nonnull)protection
                  schedulePrefetch:(bool)schedulePrefetch;

@end

@interface Fingerprint()

+(NSString* _Nonnull)uuidKey;

@end

#endif /* Protection_internal_h */
