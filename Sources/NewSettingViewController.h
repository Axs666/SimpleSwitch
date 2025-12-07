#import <UIKit/UIKit.h>

// 前向声明，避免依赖
@class WCTableViewManager, WCTableViewNormalCellManager;

@interface NewSettingViewController : UIViewController {
    WCTableViewManager *m_tableViewMgr;
    WCTableViewNormalCellManager *_pluginCellInfo;
}

@property(nonatomic, weak) WCTableViewNormalCellManager *pluginCellInfo;
- (void)viewDidAppear:(BOOL)animated;

@end
