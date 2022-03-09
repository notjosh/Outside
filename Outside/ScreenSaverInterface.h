#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScreenSaverInterface <NSObject>

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview;

- (void)next;
- (void)moveMetadata;

- (void)startAnimation;
- (void)stopAnimation;

@property (readonly, strong) NSWindow * _Nullable configureSheet;

@end

NS_ASSUME_NONNULL_END
