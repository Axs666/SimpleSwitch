#import "SimpleSwitch.h"
#import "Knob.h"
#import "SimpleLayerDelegate.h"
#import "ColorUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface SimpleSwitch ()
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation SimpleSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCenter:(CGPoint)center {
    CGFloat defaultWidth = 51.0;
    CGFloat defaultHeight = 31.0;
    CGRect frame = CGRectMake(center.x - defaultWidth / 2, center.y - defaultHeight / 2, defaultWidth, defaultHeight);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _on = NO;
    _moved = NO;
    _dragging = NO;
    _shouldSkipChangeAction = NO;
    _shouldAnimate = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    // 创建 layer delegate
    self.layerDelegate = [[SimpleLayerDelegate alloc] init];
    self.layerDelegate.animated = _shouldAnimate;
    self.layer.delegate = self.layerDelegate;
    
    // 设置边框
    [self setupBorders];
    
    // 设置线条
    [self setupLines];
    
    // 设置 knob
    [self setupKnob];
    
    // 添加手势
    [self setupGestures];
    
    // 更新外观
    [self updateAppearance];
}

- (void)setupBorders {
    // 关闭状态边框
    self.offBorder = [CAShapeLayer layer];
    self.offBorder.fillColor = [UIColor clearColor].CGColor;
    self.offBorder.strokeColor = [UIColor systemGrayColor].CGColor;
    self.offBorder.lineWidth = [self borderWidth];
    [self.layer addSublayer:self.offBorder];
    
    // 开启状态边框
    self.onBorder = [CAShapeLayer layer];
    self.onBorder.fillColor = [UIColor clearColor].CGColor;
    self.onBorder.strokeColor = [UIColor systemGreenColor].CGColor;
    self.onBorder.lineWidth = [self borderWidth];
    self.onBorder.opacity = 0.0;
    [self.layer addSublayer:self.onBorder];
}

- (void)setupLines {
    // 左侧线条
    self.leftLine = [[UIView alloc] init];
    self.leftLine.backgroundColor = [UIColor systemGrayColor];
    [self addSubview:self.leftLine];
    
    // 右侧线条
    self.rightLine = [[UIView alloc] init];
    self.rightLine.backgroundColor = [UIColor systemGreenColor];
    self.rightLine.alpha = 0.0;
    [self addSubview:self.rightLine];
    
    // 镜像线条（用于动画效果）
    self.mirrorLine = [[UIView alloc] init];
    self.mirrorLine.backgroundColor = [UIColor systemGreenColor];
    self.mirrorLine.alpha = 0.0;
    [self addSubview:self.mirrorLine];
}

- (id)setupKnob {
    if (!self.knob) {
        self.knob = [[Knob alloc] initWithFrame:CGRectZero];
        [self addSubview:self.knob];
    }
    return self.knob;
}

- (void)setupGestures {
    // 拖动手势
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOccurred:)];
    [self addGestureRecognizer:self.panGesture];
    
    // 点击手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOccurred:)];
    [self addGestureRecognizer:self.tapGesture];
}

- (double)borderWidth {
    return 1.5;
}

- (double)knobMargin {
    return 2.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat cornerRadius = height / 2;
    CGFloat borderWidth = [self borderWidth];
    CGFloat knobMargin = [self knobMargin];
    
    // 更新边框路径
    CGRect borderRect = CGRectInset(self.bounds, borderWidth / 2, borderWidth / 2);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:cornerRadius];
    self.offBorder.path = borderPath.CGPath;
    self.onBorder.path = borderPath.CGPath;
    
    // 更新线条
    CGFloat lineHeight = 2.0;
    CGFloat lineY = height / 2 - lineHeight / 2;
    self.leftLine.frame = CGRectMake(knobMargin, lineY, width / 3, lineHeight);
    self.rightLine.frame = CGRectMake(width * 2 / 3, lineY, width / 3 - knobMargin, lineHeight);
    self.mirrorLine.frame = self.rightLine.frame;
    
    // 更新 knob 位置
    CGFloat knobSize = height - knobMargin * 2;
    CGFloat knobX = self.on ? (width - knobSize - knobMargin) : knobMargin;
    self.knob.frame = CGRectMake(knobX, knobMargin, knobSize, knobSize);
    [self.knob layoutSubviews];
}

- (void)updateAppearance {
    BOOL shouldAnimate = _shouldAnimate && !_dragging;
    
    if (shouldAnimate) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateAppearanceAnimated:YES];
        }];
    } else {
        [self updateAppearanceAnimated:NO];
    }
}

- (void)updateAppearanceAnimated:(BOOL)animated {
    CGFloat knobMargin = [self knobMargin];
    CGFloat width = self.bounds.size.width;
    CGFloat knobSize = self.bounds.size.height - knobMargin * 2;
    CGFloat knobX = self.on ? (width - knobSize - knobMargin) : knobMargin;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.knob.frame = CGRectMake(knobX, knobMargin, knobSize, knobSize);
        }];
    } else {
        self.knob.frame = CGRectMake(knobX, knobMargin, knobSize, knobSize);
    }
    
    // 更新 knob 状态
    [self.knob setAnimated:animated];
    [self.knob setOn:self.on];
    [self.knob setExpanded:self.dragging];
    
    // 更新边框
    if (animated) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.3];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
    }
    
    if (self.on) {
        self.offBorder.opacity = 0.0;
        self.onBorder.opacity = 1.0;
    } else {
        self.offBorder.opacity = 1.0;
        self.onBorder.opacity = 0.0;
    }
    
    [CATransaction commit];
    
    // 更新线条
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.leftLine.alpha = self.on ? 0.0 : 1.0;
            self.rightLine.alpha = self.on ? 1.0 : 0.0;
        }];
    } else {
        self.leftLine.alpha = self.on ? 0.0 : 1.0;
        self.rightLine.alpha = self.on ? 1.0 : 0.0;
    }
}

- (void)panGestureOccurred:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    CGPoint velocity = [gesture velocityInView:self];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _isOnBeforeDrag = self.on;
            _dragging = YES;
            _moved = NO;
            [self.knob setExpanded:YES];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat knobMargin = [self knobMargin];
            CGFloat knobSize = self.bounds.size.height - knobMargin * 2;
            CGFloat minX = knobMargin;
            CGFloat maxX = self.bounds.size.width - knobSize - knobMargin;
            CGFloat currentX = self.knob.frame.origin.x;
            CGFloat newX = currentX + translation.x;
            
            newX = MAX(minX, MIN(maxX, newX));
            self.knob.frame = CGRectMake(newX, knobMargin, knobSize, knobSize);
            
            // 判断是否应该切换状态
            CGFloat threshold = (maxX - minX) / 2;
            BOOL shouldBeOn = newX > (minX + threshold);
            
            if (shouldBeOn != _isOnBeforeDrag) {
                _moved = YES;
                [self _setOn:shouldBeOn];
            }
            
            [gesture setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            _dragging = NO;
            [self.knob setExpanded:NO];
            
            // 根据速度和位置决定最终状态
            CGFloat knobMargin = [self knobMargin];
            CGFloat knobSize = self.bounds.size.height - knobMargin * 2;
            CGFloat threshold = self.bounds.size.width / 2;
            CGFloat currentX = self.knob.frame.origin.x + knobSize / 2;
            
            BOOL shouldToggle = NO;
            if (fabs(velocity.x) > 500) {
                // 快速滑动，根据方向切换
                shouldToggle = velocity.x > 0 ? YES : NO;
            } else {
                // 慢速滑动，根据位置切换
                shouldToggle = currentX > threshold;
            }
            
            [self _setOn:shouldToggle];
            [self updateAppearance];
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureOccurred:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self _setOn:!self.on];
        [self updateAppearance];
    }
}

- (void)_setOn:(BOOL)on {
    if (_on == on) return;
    _on = on;
    
    if (!_shouldSkipChangeAction && self.changeAction) {
        void (^actionBlock)(BOOL) = self.changeAction;
        if (actionBlock) {
            actionBlock(on);
        }
    }
}

- (void)setOn:(BOOL)on {
    [self _setOn:on];
    [self updateAppearance];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _shouldAnimate = animated;
    [self setOn:on];
    _shouldAnimate = YES;
}

- (void)blockChangeActionAnimated:(BOOL)animated {
    _shouldSkipChangeAction = YES;
    _shouldAnimate = animated;
}

- (void)unblockChangeAction {
    _shouldSkipChangeAction = NO;
    _shouldAnimate = YES;
}

- (void)animateCloudFlyInAndFloat:(id)cloudIcon {
    // 云朵飞入和浮动动画（可选实现）
    if ([cloudIcon isKindOfClass:[UIView class]]) {
        UIView *cloud = (UIView *)cloudIcon;
        cloud.alpha = 0.0;
        cloud.transform = CGAffineTransformMakeTranslation(-50, 0);
        
        [UIView animateWithDuration:0.5 animations:^{
            cloud.alpha = 1.0;
            cloud.transform = CGAffineTransformIdentity;
        }];
        
        [self startCloudFloatingAnimation:cloud];
    }
}

- (void)startCloudFloatingAnimation:(id)cloudIcon {
    // 云朵浮动动画
    if ([cloudIcon isKindOfClass:[UIView class]]) {
        UIView *cloud = (UIView *)cloudIcon;
        [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut animations:^{
            cloud.transform = CGAffineTransformMakeTranslation(0, -5);
        } completion:nil];
    }
}

- (void)startSparkleBlinkAnimation:(id)sparkleIcon {
    // 闪烁动画
    if ([sparkleIcon isKindOfClass:[UIView class]]) {
        UIView *sparkle = (UIView *)sparkleIcon;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            sparkle.alpha = 0.3;
        } completion:nil];
    }
}

- (void)dealloc {
    self.layer.delegate = nil;
}

@end

