#import "SimpleLayerDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation SimpleLayerDelegate

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    if (self.animated) {
        return nil; // 使用默认动画
    } else {
        // 禁用动画
        return [NSNull null];
    }
}

@end

