#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Sources/SimpleSwitch.h"
#import "Sources/SimpleSwitchDemoViewController.h"

// 插件入口管理
static NSString *const kSSPluginDisplayName = @"SimpleSwitch";
static NSString *const kSSPluginVersion = @"1.0.0";

static BOOL SSPluginManagerAvailable(void) {
    Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
    if (!wcPluginsMgr) {
        return NO;
    }
    SEL sharedSelector = @selector(sharedInstance);
    if (![wcPluginsMgr respondsToSelector:sharedSelector]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id instance = [wcPluginsMgr performSelector:sharedSelector];
#pragma clang diagnostic pop
    if (!instance) {
        return NO;
    }
    return [instance respondsToSelector:@selector(registerControllerWithTitle:version:controller:)];
}

static void SSRegisterPluginWithPluginManagerIfPossible(void) {
    static BOOL registered = NO;
    if (registered || !SSPluginManagerAvailable()) {
        return;
    }
    @try {
        Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
        SEL sharedSelector = @selector(sharedInstance);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id instance = [wcPluginsMgr performSelector:sharedSelector];
#pragma clang diagnostic pop
        SEL registerSelector = @selector(registerControllerWithTitle:version:controller:);
        if (instance && [instance respondsToSelector:registerSelector]) {
            ((void (*)(id, SEL, NSString *, NSString *, NSString *))objc_msgSend)(instance,
                                                                                  registerSelector,
                                                                                  kSSPluginDisplayName,
                                                                                  kSSPluginVersion,
                                                                                  @"SimpleSwitchDemoViewController");
            registered = YES;
        }
    } @catch (NSException *exception) {
        NSLog(@"[SimpleSwitchPlugin] 注册插件失败: %@", exception);
    }
}

static void SSPresentDemoPanelFromController(UIViewController *hostController) {
    if (!hostController) {
        return;
    }
    UIViewController *controller = [[SimpleSwitchDemoViewController alloc] init];
    if (!controller) {
        return;
    }
    if (hostController.navigationController) {
        [hostController.navigationController pushViewController:controller animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [hostController presentViewController:nav animated:YES completion:nil];
    }
}

// 前向声明类型
@class NewSettingViewController, WCTableViewManager, WCTableViewSectionManager, WCTableViewNormalCellManager;

static WCTableViewManager *SSSettingsTableManager(id controller) {
    if (!controller) {
        return nil;
    }
    static const char *managerIvarNames[] = {"m_tableViewMgr", "_tableViewMgr", "m_tableMgr", "_tableMgr"};
    for (NSUInteger idx = 0; idx < sizeof(managerIvarNames) / sizeof(const char *); idx++) {
        Ivar ivar = class_getInstanceVariable([controller class], managerIvarNames[idx]);
        if (!ivar) {
            continue;
        }
        id value = object_getIvar(controller, ivar);
        if (value) {
            return (WCTableViewManager *)value;
        }
    }
    return nil;
}

static void *kSSSettingsEntryAssociatedKey = &kSSSettingsEntryAssociatedKey;

static void SSEnsureSettingsEntry(id controller) {
    if (!controller || SSPluginManagerAvailable()) {
        return;
    }
    if (objc_getAssociatedObject(controller, kSSSettingsEntryAssociatedKey)) {
        return;
    }
    WCTableViewManager *manager = SSSettingsTableManager(controller);
    if (!manager) {
        return;
    }
    WCTableViewSectionManager *section = [manager getSectionAt:0];
    if (!section) {
        return;
    }
    Class cellManagerClass = objc_getClass("WCTableViewNormalCellManager");
    if (!cellManagerClass) {
        return;
    }
    WCTableViewNormalCellManager *cell = [cellManagerClass normalCellForSel:@selector(ss_onSimpleSwitchSettingsEntryTapped)
                                                                     target:controller
                                                                      title:kSSPluginDisplayName
                                                                 rightValue:kSSPluginVersion
                                                              accessoryType:1];
    if (!cell) {
        return;
    }
    [section addCell:cell];
    [manager reloadTableView];
    objc_setAssociatedObject(controller, kSSSettingsEntryAssociatedKey, cell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Hook MinimizeViewController 来注册插件
static void SSHookMinimizeViewController(void) {
    Class cls = objc_getClass("MinimizeViewController");
    if (!cls) return;
    
    Method method = class_getInstanceMethod(cls, @selector(viewDidLoad));
    if (!method) return;
    
    void (*originalImp)(id, SEL) = (void (*)(id, SEL))method_getImplementation(method);
    
    void (^swizzledBlock)(id) = ^(id self) {
        originalImp(self, @selector(viewDidLoad));
        SSRegisterPluginWithPluginManagerIfPossible();
    };
    
    IMP swizzledImp = imp_implementationWithBlock(swizzledBlock);
    method_setImplementation(method, swizzledImp);
}

// Hook NewSettingViewController 来添加入口
static void SSHookNewSettingViewController(void) {
    Class cls = objc_getClass("NewSettingViewController");
    if (!cls) return;
    
    // Hook viewDidLoad
    Method viewDidLoadMethod = class_getInstanceMethod(cls, @selector(viewDidLoad));
    if (viewDidLoadMethod) {
        void (*originalViewDidLoad)(id, SEL) = (void (*)(id, SEL))method_getImplementation(viewDidLoadMethod);
        void (^swizzledViewDidLoad)(id) = ^(id self) {
            originalViewDidLoad(self, @selector(viewDidLoad));
            SSEnsureSettingsEntry(self);
        };
        IMP swizzledViewDidLoadImp = imp_implementationWithBlock(swizzledViewDidLoad);
        method_setImplementation(viewDidLoadMethod, swizzledViewDidLoadImp);
    }
    
    // Hook viewWillAppear:
    Method viewWillAppearMethod = class_getInstanceMethod(cls, @selector(viewWillAppear:));
    if (viewWillAppearMethod) {
        void (*originalViewWillAppear)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))method_getImplementation(viewWillAppearMethod);
        void (^swizzledViewWillAppear)(id, BOOL) = ^(id self, BOOL animated) {
            originalViewWillAppear(self, @selector(viewWillAppear:), animated);
            SSEnsureSettingsEntry(self);
        };
        IMP swizzledViewWillAppearImp = imp_implementationWithBlock(swizzledViewWillAppear);
        method_setImplementation(viewWillAppearMethod, swizzledViewWillAppearImp);
    }
    
    // Hook viewDidAppear:
    Method viewDidAppearMethod = class_getInstanceMethod(cls, @selector(viewDidAppear:));
    if (viewDidAppearMethod) {
        void (*originalViewDidAppear)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))method_getImplementation(viewDidAppearMethod);
        void (^swizzledViewDidAppear)(id, BOOL) = ^(id self, BOOL animated) {
            originalViewDidAppear(self, @selector(viewDidAppear:), animated);
            SSEnsureSettingsEntry(self);
        };
        IMP swizzledViewDidAppearImp = imp_implementationWithBlock(swizzledViewDidAppear);
        method_setImplementation(viewDidAppearMethod, swizzledViewDidAppearImp);
    }
}

// 添加点击处理方法
static void SSAddTapMethodToNewSettingViewController(void) {
    Class cls = objc_getClass("NewSettingViewController");
    if (!cls) return;
    
    SEL selector = @selector(ss_onSimpleSwitchSettingsEntryTapped);
    if (class_getInstanceMethod(cls, selector)) {
        return; // 方法已存在
    }
    
    IMP imp = imp_implementationWithBlock(^(id self) {
        SSPresentDemoPanelFromController(self);
    });
    
    class_addMethod(cls, selector, imp, "v@:");
}

%ctor {
    @autoreleasepool {
        // 注册插件
        SSRegisterPluginWithPluginManagerIfPossible();
        
        // Hook 视图控制器
        SSHookMinimizeViewController();
        SSHookNewSettingViewController();
        
        // 添加点击方法
        SSAddTapMethodToNewSettingViewController();
        
        NSLog(@"[SimpleSwitchPlugin] 插件已加载");
    }
}

