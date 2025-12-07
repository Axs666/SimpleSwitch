#import "SimpleSwitchDemoViewController.h"
#import "SimpleSwitch.h"

static NSString * const kSimpleSwitchDemoEnabledKey = @"com.wechat.simpleswitch.demo.enabled";

@interface SimpleSwitchDemoViewController ()
@property (nonatomic, strong) SimpleSwitch *demoSwitch;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation SimpleSwitchDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SimpleSwitch 演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建说明标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"SimpleSwitch 开关演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    
    // 创建开关
    SimpleSwitch *simpleSwitch = [[SimpleSwitch alloc] initWithCenter:CGPointZero];
    simpleSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 读取当前状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isEnabled = [defaults boolForKey:kSimpleSwitchDemoEnabledKey];
    [simpleSwitch setOn:isEnabled animated:NO];
    
    // 设置回调
    __weak typeof(self) weakSelf = self;
    simpleSwitch.changeAction = ^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kSimpleSwitchDemoEnabledKey];
        [defaults synchronize];
        
        if (weakSelf) {
            weakSelf.statusLabel.text = isOn ? @"状态：已开启" : @"状态：已关闭";
            weakSelf.statusLabel.textColor = isOn ? [UIColor systemGreenColor] : [UIColor systemGrayColor];
        }
        
        NSLog(@"SimpleSwitch 状态改变: %@", isOn ? @"开启" : @"关闭");
    };
    
    self.demoSwitch = simpleSwitch;
    [self.view addSubview:simpleSwitch];
    
    // 创建状态标签
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.text = isEnabled ? @"状态：已开启" : @"状态：已关闭";
    statusLabel.font = [UIFont systemFontOfSize:18];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = isEnabled ? [UIColor systemGreenColor] : [UIColor systemGrayColor];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel = statusLabel;
    [self.view addSubview:statusLabel];
    
    // 创建说明文本
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"这是一个美观的自定义开关组件\n支持拖拽和点击切换\n流畅的动画效果";
    descriptionLabel.font = [UIFont systemFontOfSize:16];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = [UIColor secondaryLabelColor];
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:descriptionLabel];
    
    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        // 标题
        [titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // 开关
        [simpleSwitch.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [simpleSwitch.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:60],
        [simpleSwitch.widthAnchor constraintEqualToConstant:51],
        [simpleSwitch.heightAnchor constraintEqualToConstant:31],
        
        // 状态标签
        [statusLabel.topAnchor constraintEqualToAnchor:simpleSwitch.bottomAnchor constant:30],
        [statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // 说明文本
        [descriptionLabel.topAnchor constraintEqualToAnchor:statusLabel.bottomAnchor constant:40],
        [descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    ]];
}

@end

