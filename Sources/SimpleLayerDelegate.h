#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SimpleLayerDelegate : NSObject <CALayerDelegate>

@property (nonatomic) BOOL animated;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

- (id)actionForLayer:(id)a0 forKey:(id)a1;

@end
