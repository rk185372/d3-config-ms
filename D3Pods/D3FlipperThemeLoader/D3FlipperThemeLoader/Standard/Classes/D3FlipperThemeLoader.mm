
#import "D3FlipperThemeLoader.h"

#import <FlipperKit/FlipperConnection.h>
#import <FlipperKit/FlipperResponder.h>

#import <FlipperKit/FlipperClient.h>

@interface D3FlipperThemeLoader ()
  @property (nonatomic, strong) id<FlipperConnection> flipperConnection;
  @property (nonatomic, strong) NSDictionary* currentTheme;
@end

@implementation D3FlipperThemeLoader

+ (void)setupFlipperWithTheme:(NSDictionary *)theme {
    FlipperClient *client = [FlipperClient sharedClient];
    
    [client addPlugin:[[D3FlipperThemeLoader alloc] initWithCurrentTheme:theme]];
    [client start];
}

- (instancetype)initWithCurrentTheme:(NSDictionary *)currentTheme {
  if (self = [self init]) {
    self.currentTheme = currentTheme;
  }
  return self;
}

- (void)didConnect:(id<FlipperConnection>)connection {
    self.flipperConnection = connection;
    
    [connection receive:@"updateDynamicTheme" withBlock:^(NSDictionary *params, id<FlipperResponder> responder) {
        NSString *jsonString = params[@"sentJson"];
        NSDictionary *json = [self themeDictionaryValueFromString:jsonString];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedThemeNotification" object:self userInfo:json];
        [responder success:[NSMutableDictionary new]];
    }];
    
    [connection receive:@"getCurrentTheme" withBlock:^(NSDictionary *params, id<FlipperResponder> responder) {
        NSDictionary *themeDict = [[NSDictionary alloc] initWithObjectsAndKeys:[self themeStringValue], @"theme", nil];
        [responder success:themeDict];
    }];
}

- (void)didDisconnect {
    self.flipperConnection = nil;
}

- (NSString *)identifier {
    return @"themeLoaderPlugin";
}

#pragma mark - Private

- (NSString *)themeStringValue {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.currentTheme
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

- (NSDictionary *)themeDictionaryValueFromString:(NSString *)themeString {
    NSError *error;
    NSData *jsonData = [themeString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (!jsonObj) {
        NSLog(@"Error during parsing JSON: %@", error);
        return [[NSDictionary alloc] init];
    } else {
        return jsonObj;
    }
}

@end
