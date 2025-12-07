# SimpleSwitchPlugin

一个美观的自定义开关UI插件，基于 SimpleSwitch 组件。

## 功能特性

- ✨ 美观的开关UI设计
- 🎯 支持拖拽和点击切换
- 🎨 流畅的动画效果
- 🌙 太阳/月亮图标切换
- 📱 完全兼容 iOS 14.5+

## 项目结构

```
SimpleSwitchPlugin/
├── Sources/              # 源代码文件
│   ├── SimpleSwitch.h   # 开关组件头文件
│   ├── SimpleSwitch.m   # 开关组件实现
│   ├── Knob.h           # 旋钮组件头文件
│   ├── Knob.m           # 旋钮组件实现
│   ├── SimpleLayerDelegate.h
│   ├── SimpleLayerDelegate.m
│   ├── ColorUtils.h
│   └── ColorUtils.m
├── Hooks/                # Hook 文件
│   └── SimpleSwitchDemo.xm
├── Tweak.xm              # 主 Hook 文件
├── Makefile              # 构建配置
├── control               # 包信息
├── SimpleSwitchPlugin.plist  # 过滤器配置
└── README.md             # 说明文档
```

## 使用方法

### 1. 编译

```bash
cd SimpleSwitchPlugin
make
```

### 2. 安装

```bash
make package
make install
```

### 3. 在代码中使用

```objective-c
#import "SimpleSwitch.h"

// 创建开关
SimpleSwitch *switch = [[SimpleSwitch alloc] initWithCenter:CGPointMake(100, 100)];

// 设置状态
[switch setOn:YES animated:YES];

// 设置回调
switch.changeAction = ^(BOOL isOn) {
    NSLog(@"开关状态: %@", isOn ? @"开启" : @"关闭");
    // 保存状态
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:@"your.key"];
};
```

## API 说明

### SimpleSwitch

主要开关组件类。

#### 属性

- `on` (BOOL): 开关状态
- `changeAction` (block): 状态改变回调
- `knob` (Knob *): 旋钮组件
- `sparkleColor` (UIColor *): 闪烁颜色
- `cloudColor` (UIColor *): 云朵颜色

#### 方法

- `- (instancetype)initWithCenter:(CGPoint)center`: 使用中心点初始化
- `- (void)setOn:(BOOL)on animated:(BOOL)animated`: 设置开关状态（带动画）
- `- (void)blockChangeActionAnimated:(BOOL)animated`: 临时阻止回调
- `- (void)unblockChangeAction`: 恢复回调

### Knob

旋钮组件，显示太阳/月亮图标。

#### 属性

- `on` (BOOL): 是否开启（显示太阳）
- `expanded` (BOOL): 是否展开

## 自定义

### 修改颜色

```objective-c
// 修改边框颜色
switch.onBorder.strokeColor = [UIColor systemBlueColor].CGColor;
switch.offBorder.strokeColor = [UIColor systemGrayColor].CGColor;

// 修改旋钮颜色
switch.knob.sunLayer.fillColor = [UIColor systemOrangeColor].CGColor;
```

### 修改大小

```objective-c
// 在 layoutSubviews 中调整
CGFloat customWidth = 60.0;
CGFloat customHeight = 35.0;
switch.frame = CGRectMake(x, y, customWidth, customHeight);
```

## 注意事项

1. 确保在 iOS 14.5+ 上使用
2. 开关组件会自动处理内存管理
3. 建议在主线程中更新 UI

## 许可证

MIT License

## 作者

Axs

