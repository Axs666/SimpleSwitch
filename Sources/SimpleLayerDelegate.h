#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SimpleLayerDelegate : NSObject <CALayerDelegate>

@property (nonatomic) BOOL animated;

- (id)actionForLayer:(id)a0 forKey:(id)a1;

@end
