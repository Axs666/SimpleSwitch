#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Sources/SimpleSwitch.h"

// 设置存储键值
static NSString * const kSimpleSwitchDemoEnabledKey = @"com.wechat.simpleswitch.demo.enabled";

// 前向声明函数
static void addSimpleSwitchDemo(UIViewController *viewController);

// Hook 微信设置界面，添加 SimpleSwitch 示例
// 使用运行时方法交换，避免需要头文件
%ctor {
    @autoreleasepool {
        Class cls = objc_getClass("NewSettingViewController");
        if (cls) {
            Method originalMethod = class_getInstanceMethod(cls, @selector(viewDidLoad));
            if (originalMethod) {
                void (*originalImp)(id, SEL) = (void (*)(id, SEL))method_getImplementation(originalMethod);
                
                void (^swizzledBlock)(id) = ^(id self) {
                    originalImp(self, @selector(viewDidLoad));
                    dispatch_async(dispatch_get_main_queue(), ^{
                        addSimpleSwitchDemo(self);
                    });
                };
                
                IMP swizzledImp = imp_implementationWithBlock(swizzledBlock);
                method_setImplementation(originalMethod, swizzledImp);
            }
        }
        NSLog(@"SimpleSwitchPlugin loaded");
    }
}

// 辅助函数：添加 SimpleSwitch 演示
static void addSimpleSwitchDemo(UIViewController *viewController) {
    // 查找表格视图
    UITableView *tableView = nil;
    for (UIView *subview in viewController.view.subviews) {
        if ([subview isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)subview;
            break;
        }
    }
    
    if (!tableView) return;
    
    // 创建容器视图
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)];
    containerView.backgroundColor = [UIColor clearColor];
    
    // 创建标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 60)];
    label.text = @"SimpleSwitch 演示";
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor labelColor];
    [containerView addSubview:label];
    
    // 创建 SimpleSwitch
    CGPoint center = CGPointMake(tableView.bounds.size.width - 40, 30);
    SimpleSwitch *simpleSwitch = [[SimpleSwitch alloc] initWithCenter:center];
    simpleSwitch.frame = CGRectMake(tableView.bounds.size.width - 67, 15, 51, 31);
    
    // 读取当前状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isEnabled = [defaults boolForKey:kSimpleSwitchDemoEnabledKey];
    [simpleSwitch setOn:isEnabled animated:NO];
    
    // 设置回调
    __weak typeof(simpleSwitch) weakSwitch = simpleSwitch;
    simpleSwitch.changeAction = ^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kSimpleSwitchDemoEnabledKey];
        [defaults synchronize];
        
        // 可以在这里添加其他逻辑
        NSLog(@"SimpleSwitch 状态改变: %@", isOn ? @"开启" : @"关闭");
    };
    
    [containerView addSubview:simpleSwitch];
    
    // 将容器视图添加到表格视图的头部
    if (tableView.tableHeaderView) {
        // 如果已有头部视图，创建一个新的容器
        UIView *existingHeader = tableView.tableHeaderView;
        UIView *newHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, existingHeader.bounds.size.height + containerView.bounds.size.height)];
        [newHeader addSubview:existingHeader];
        containerView.frame = CGRectMake(0, existingHeader.bounds.size.height, containerView.bounds.size.width, containerView.bounds.size.height);
        [newHeader addSubview:containerView];
        tableView.tableHeaderView = newHeader;
    } else {
        tableView.tableHeaderView = containerView;
    }
}

