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
    
    // 确保视图可以交互
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    @try {
        // 创建 layer delegate
        self.layerDelegate = [[SimpleLayerDelegate alloc] init];
        if (self.layerDelegate) {
            self.layerDelegate.animated = _shouldAnimate;
            self.layer.delegate = self.layerDelegate;
        }
        
        // 设置边框
        [self setupBorders];
        
        // 设置线条
        [self setupLines];
        
        // 设置 knob
        [self setupKnob];
        
        // 确保 knob 可以交互（但不拦截触摸）
        if (self.knob) {
            self.knob.userInteractionEnabled = NO;
        }
        
        // 添加手势
        [self setupGestures];
        
        NSLog(@"[SimpleSwitch] commonInit 完成, userInteractionEnabled=%@, gestures=%@", 
              @(self.userInteractionEnabled), self.gestureRecognizers);
        
        // 更新外观 - 延迟到 layoutSubviews 中执行，避免 bounds 为零的问题
        // [self updateAppearance];
    } @catch (NSException *exception) {
        NSLog(@"[SimpleSwitch] commonInit 异常: %@", exception);
    }
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

// 确保触摸事件能正确传递
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 如果视图不可交互或隐藏，返回 nil
    if (!self.userInteractionEnabled || self.hidden || self.alpha < 0.01) {
        return nil;
    }
    
    // 检查触摸点是否在视图范围内
    if ([self pointInside:point withEvent:event]) {
        // 检查子视图
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint subviewPoint = [self convertPoint:point toView:subview];
            UIView *hitView = [subview hitTest:subviewPoint withEvent:event];
            if (hitView && hitView.userInteractionEnabled) {
                return hitView;
            }
        }
        // 如果子视图不处理，返回自己
        return self;
    }
    
    return nil;
}

- (void)setupLines {
    // 左侧线条
    self.leftLine = [[UIView alloc] init];
    self.leftLine.backgroundColor = [UIColor systemGrayColor];
    self.leftLine.userInteractionEnabled = NO; // 不拦截触摸
    [self addSubview:self.leftLine];
    
    // 右侧线条
    self.rightLine = [[UIView alloc] init];
    self.rightLine.backgroundColor = [UIColor systemGreenColor];
    self.rightLine.alpha = 0.0;
    self.rightLine.userInteractionEnabled = NO; // 不拦截触摸
    [self addSubview:self.rightLine];
    
    // 镜像线条（用于动画效果）
    self.mirrorLine = [[UIView alloc] init];
    self.mirrorLine.backgroundColor = [UIColor systemGreenColor];
    self.mirrorLine.alpha = 0.0;
    self.mirrorLine.userInteractionEnabled = NO; // 不拦截触摸
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
    // 移除旧的手势（如果有）
    if (self.panGesture) {
        [self removeGestureRecognizer:self.panGesture];
    }
    if (self.tapGesture) {
        [self removeGestureRecognizer:self.tapGesture];
    }
    
    // 拖动手势
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOccurred:)];
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panGesture];
    
    // 点击手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOccurred:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.numberOfTouchesRequired = 1;
    // 让点击手势在拖动手势失败时才触发
    [self.tapGesture requireGestureRecognizerToFail:self.panGesture];
    [self addGestureRecognizer:self.tapGesture];
    
    NSLog(@"[SimpleSwitch] setupGestures 完成, pan=%@, tap=%@", self.panGesture, self.tapGesture);
}

- (double)borderWidth {
    return 1.5;
}

- (double)knobMargin {
    return 2.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 如果 bounds 为零，跳过布局
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    @try {
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        CGFloat cornerRadius = height / 2;
        CGFloat borderWidth = [self borderWidth];
        CGFloat knobMargin = [self knobMargin];
        
        // 更新边框路径
        CGRect borderRect = CGRectInset(self.bounds, borderWidth / 2, borderWidth / 2);
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:cornerRadius];
        if (self.offBorder) {
            self.offBorder.path = borderPath.CGPath;
        }
        if (self.onBorder) {
            self.onBorder.path = borderPath.CGPath;
        }
        
        // 更新线条
        CGFloat lineHeight = 2.0;
        CGFloat lineY = height / 2 - lineHeight / 2;
        if (self.leftLine) {
            self.leftLine.frame = CGRectMake(knobMargin, lineY, width / 3, lineHeight);
        }
        if (self.rightLine) {
            self.rightLine.frame = CGRectMake(width * 2 / 3, lineY, width / 3 - knobMargin, lineHeight);
        }
        if (self.mirrorLine) {
            self.mirrorLine.frame = self.rightLine.frame;
        }
        
        // 更新 knob 位置
        if (self.knob) {
            CGFloat knobSize = height - knobMargin * 2;
            CGFloat knobX = self.on ? (width - knobSize - knobMargin) : knobMargin;
            self.knob.frame = CGRectMake(knobX, knobMargin, knobSize, knobSize);
            [self.knob layoutSubviews];
        }
        
        // 布局完成后更新外观（每次布局都更新，确保状态正确）
        [self updateAppearance];
    } @catch (NSException *exception) {
        NSLog(@"[SimpleSwitch] layoutSubviews 异常: %@", exception);
    }
}

- (void)updateAppearance {
    // 如果 view 还没有布局，bounds 为零，延迟更新
    if (CGRectIsEmpty(self.bounds)) {
        // 延迟到下一个运行循环再尝试
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!CGRectIsEmpty(self.bounds)) {
                [self updateAppearance];
            }
        });
        return;
    }
    
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
    // 如果 bounds 为零，跳过更新
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    @try {
        CGFloat knobMargin = [self knobMargin];
        CGFloat width = self.bounds.size.width;
        CGFloat knobSize = self.bounds.size.height - knobMargin * 2;
        CGFloat knobX = self.on ? (width - knobSize - knobMargin) : knobMargin;
        
        if (self.knob) {
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
        }
        
        // 更新边框
        if (self.offBorder && self.onBorder) {
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
        }
        
        // 更新线条
        if (self.leftLine && self.rightLine) {
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
    } @catch (NSException *exception) {
        NSLog(@"[SimpleSwitch] updateAppearanceAnimated 异常: %@", exception);
    }
}

- (void)panGestureOccurred:(UIPanGestureRecognizer *)gesture {
    NSLog(@"[SimpleSwitch] panGestureOccurred, state=%ld", (long)gesture.state);
    
    CGPoint touchLocation = [gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[SimpleSwitch] pan began at %@", NSStringFromCGPoint(touchLocation));
        _isOnBeforeDrag = _on;
        _dragging = YES;
        _moved = NO;
        [self.knob setExpanded:YES];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        _moved = YES;
        
        if (touchLocation.x > self.bounds.size.width / 2 && !_on) {
            [self setOn:YES];
        } else if (touchLocation.x < self.bounds.size.width / 2 && _on) {
            [self setOn:NO];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || 
               gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        NSLog(@"[SimpleSwitch] pan ended, final state=%d", _on);
        [self.knob setExpanded:NO];
        _dragging = NO;
        _moved = NO;
        
        if (_on != _isOnBeforeDrag && self.changeAction) {
            void (^actionBlock)(BOOL) = self.changeAction;
            if (actionBlock) {
                actionBlock(_on);
            }
        }
    }
}

- (void)tapGestureOccurred:(UITapGestureRecognizer *)gesture {
    NSLog(@"[SimpleSwitch] tapGestureOccurred, state=%ld, dragging=%d", (long)gesture.state, _dragging);
    
    if (_dragging) {
        return;
    }
    
    _dragging = YES;
    [self setOn:!_on];
    _dragging = NO;
}

- (void)setOn:(BOOL)on {
    if (_on == on) {
        return;
    }
    _on = on;
    [self _setOn:on];
}

- (void)_setOn:(BOOL)on {
    // call the action closure
    if (self.changeAction && !_shouldSkipChangeAction) {
        void (^actionBlock)(BOOL) = self.changeAction;
        if (actionBlock) {
            actionBlock(on);
        }
    }
    
    BOOL shouldAnimate = (_shouldAnimate || _dragging);
    
    [self.layerDelegate setAnimated:shouldAnimate];
    [self.knob setAnimated:shouldAnimate];
    
    self.knob.on = on;
    
    [UIView animateWithDuration:(shouldAnimate ? 0.4 : 0)
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGFloat knobMargin = [self knobMargin];
                         CGFloat knobSize = self.bounds.size.height - knobMargin * 2;
                         CGFloat knobRadius = knobSize / 2;
                         
                         if (on) {
                             self.knob.center = CGPointMake(self.bounds.size.width - knobRadius - knobMargin, 
                                                           self.knob.center.y);
                             self.backgroundColor = [UIColor systemGreenColor];
                             self.offBorder.opacity = 0.0;
                             self.onBorder.opacity = 1.0;
                             self.leftLine.alpha = 0.0;
                             self.rightLine.alpha = 1.0;
                         } else {
                             self.knob.center = CGPointMake(knobRadius + knobMargin, 
                                                           self.knob.center.y);
                             self.backgroundColor = [UIColor systemGrayColor];
                             self.offBorder.opacity = 1.0;
                             self.onBorder.opacity = 0.0;
                             self.leftLine.alpha = 1.0;
                             self.rightLine.alpha = 0.0;
                         }
                     }
                     completion:nil];
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

