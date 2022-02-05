
#import <Foundation/Foundation.h>
#import <FlipperKit/FlipperPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface D3FlipperThemeLoader : NSObject<FlipperPlugin>

+ (void)setupFlipperWithTheme:(NSDictionary *)currentTheme;
- (instancetype)initWithCurrentTheme:(NSDictionary *)currentTheme;

@end

NS_ASSUME_NONNULL_END
