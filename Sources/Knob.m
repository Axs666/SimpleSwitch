#import "Knob.h"
#import <QuartzCore/QuartzCore.h>

@interface Knob ()
@property (nonatomic, strong) CAShapeLayer *sunLayer;
@property (nonatomic, strong) CAShapeLayer *moonLayer;
@end

@implementation Knob

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _on = NO;
        _expanded = NO;
        _shouldAnimate = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setupLayers];
    }
    return self;
}

- (void)setupLayers {
    // 创建太阳图层（开启状态）
    self.sunLayer = [CAShapeLayer layer];
    self.sunLayer.fillColor = [UIColor systemYellowColor].CGColor;
    self.sunLayer.hidden = YES;
    [self.layer addSublayer:self.sunLayer];
    
    // 创建月亮图层（关闭状态）
    self.moonLayer = [CAShapeLayer layer];
    self.moonLayer.fillColor = [UIColor systemGrayColor].CGColor;
    self.moonLayer.hidden = NO;
    [self.layer addSublayer:self.moonLayer];
}

- (double)subviewMargin {
    return 4.0;
}

- (id)sunLayer {
    return self.sunLayer;
}

- (id)moonLayer {
    return self.moonLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat size = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat margin = [self subviewMargin];
    CGFloat iconSize = size - margin * 2;
    
    CGRect iconRect = CGRectMake(margin, margin, iconSize, iconSize);
    
    // 太阳图标（圆形）
    UIBezierPath *sunPath = [UIBezierPath bezierPathWithOvalInRect:iconRect];
    self.sunLayer.path = sunPath.CGPath;
    
    // 月亮图标（新月形状）
    UIBezierPath *moonPath = [UIBezierPath bezierPath];
    CGFloat centerX = CGRectGetMidX(iconRect);
    CGFloat centerY = CGRectGetMidY(iconRect);
    CGFloat radius = iconSize / 2;
    
    // 绘制新月形状
    [moonPath addArcWithCenter:CGPointMake(centerX, centerY) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [moonPath addArcWithCenter:CGPointMake(centerX + radius * 0.3, centerY) radius:radius * 0.7 startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    
    self.moonLayer.path = moonPath.CGPath;
    
    // 更新子视图
    if (self.subview) {
        self.subview.frame = iconRect;
    }
}

- (void)setAnimated:(BOOL)animated {
    _shouldAnimate = animated;
}

- (void)_setOn:(BOOL)on {
    if (_on == on) return;
    _on = on;
    
    [self updateLayers];
}

- (void)setOn:(BOOL)on {
    [self _setOn:on];
}

- (void)_setExpanded:(BOOL)expanded {
    if (_expanded == expanded) return;
    _expanded = expanded;
    
    [self updateLayers];
}

- (void)setExpanded:(BOOL)expanded {
    [self _setExpanded:expanded];
}

- (void)updateLayers {
    BOOL shouldAnimate = _shouldAnimate;
    
    if (shouldAnimate) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.3];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
    }
    
    if (self.on) {
        self.sunLayer.hidden = NO;
        self.moonLayer.hidden = YES;
        self.sunLayer.opacity = 1.0;
        self.moonLayer.opacity = 0.0;
    } else {
        self.sunLayer.hidden = YES;
        self.moonLayer.hidden = NO;
        self.sunLayer.opacity = 0.0;
        self.moonLayer.opacity = 1.0;
    }
    
    if (self.expanded) {
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } else {
        self.transform = CGAffineTransformIdentity;
    }
    
    [CATransaction commit];
}

@end

