#ifndef Challenge_h
#define Challenge_h

#include <Foundation/Foundation.h>

#include "Serialization.h"
#include "Fingerprint.h"

@protocol ProblemSolver <NSObject>

-(AuthenticationProtocol* _Nonnull)protocol;

-(NSString* _Nonnull)solve:(NSString* _Nonnull)question;

@end


@interface DebugProblemSolver : NSObject <ProblemSolver>

@end

@interface IosProblemSolver : NSObject <ProblemSolver>

{
@private
    Fingerprint* fingerprint;
}

-(id _Nonnull)initWithFingerprint:(Fingerprint* _Nonnull)fingerprint;

@end

#endif /* Challenge_h */
