#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../Sources/SimpleSwitch.h"

// 设置存储键值
static NSString * const kSimpleSwitchDemoEnabledKey = @"com.wechat.simpleswitch.demo.enabled";

// 这个文件可以作为额外的 Hook 示例
// 展示如何在其他界面中使用 SimpleSwitch

// 辅助函数：添加 SimpleSwitch 到视图控制器
static void addSimpleSwitchToViewController(UIViewController *viewController) {
    if (!viewController || !viewController.view) {
        return;
    }
    
    // 检查是否已经添加过
    for (UIView *subview in viewController.view.subviews) {
        if ([subview isKindOfClass:[SimpleSwitch class]]) {
            return; // 已经添加过了
        }
    }
    
    // 创建 SimpleSwitch
    CGPoint center = CGPointMake(viewController.view.bounds.size.width - 40, 100);
    SimpleSwitch *simpleSwitch = [[SimpleSwitch alloc] initWithCenter:center];
    
    // 读取当前状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isEnabled = [defaults boolForKey:kSimpleSwitchDemoEnabledKey];
    [simpleSwitch setOn:isEnabled animated:NO];
    
    // 设置回调
    simpleSwitch.changeAction = ^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kSimpleSwitchDemoEnabledKey];
        [defaults synchronize];
        
        NSLog(@"SimpleSwitch 状态改变: %@", isOn ? @"开启" : @"关闭");
    };
    
    [viewController.view addSubview:simpleSwitch];
}

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    // 示例：在特定视图控制器中添加 SimpleSwitch
    // 可以根据需要修改条件
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"Setting"] || [className containsString:@"Config"]) {
        // 延迟添加，避免重复添加
        static NSMutableSet *addedControllers = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            addedControllers = [NSMutableSet set];
        });
        
        NSString *controllerKey = [NSString stringWithFormat:@"%p", self];
        if (![addedControllers containsObject:controllerKey]) {
            [addedControllers addObject:controllerKey];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                addSimpleSwitchToViewController(self);
            });
        }
    }
}

%end

%ctor {
    @autoreleasepool {
        NSLog(@"SimpleSwitchDemo Hook loaded");
    }
}

