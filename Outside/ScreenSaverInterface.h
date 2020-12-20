//
//  ScreenSaverInterface.h
//  Outside
//
//  Created by Joshua May on 20/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScreenSaverInterface <NSObject>

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview;

- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
