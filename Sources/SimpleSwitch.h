#import <UIKit/UIKit.h>

@class SimpleLayerDelegate, NSArray, UIColor, CAShapeLayer, UIView, Knob;

@interface SimpleSwitch : UIView {
    BOOL _shouldSkipChangeAction;
    BOOL _shouldAnimate;
}

@property (retain, nonatomic) Knob *knob;
@property (nonatomic) BOOL moved;
@property (nonatomic) BOOL dragging;
@property (nonatomic) BOOL isOnBeforeDrag;
@property (retain, nonatomic) SimpleLayerDelegate *layerDelegate;
@property (retain, nonatomic) UIView *mirrorLine;
@property (retain, nonatomic) UIView *leftLine;
@property (retain, nonatomic) UIView *rightLine;
@property (retain, nonatomic) NSArray *sparkleIcons;
@property (retain, nonatomic) NSArray *cloudIcons;
@property (retain, nonatomic) UIColor *sparkleColor;
@property (retain, nonatomic) UIColor *cloudColor;
@property (copy, nonatomic) id /* block */ changeAction;
@property (nonatomic) BOOL on;
@property (retain, nonatomic) CAShapeLayer *offBorder;
@property (retain, nonatomic) CAShapeLayer *onBorder;

- (double)borderWidth;
- (double)knobMargin;
- (id)setupKnob;
- (id)initWithCenter:(CGPoint)center;
- (void)commonInit;
- (void)panGestureOccurred:(id)a0;
- (id)initWithCoder:(id)a0;
- (id)initWithFrame:(CGRect)frame;
- (void)tapGestureOccurred:(id)a0;
- (void)_setOn:(BOOL)a0;
- (void)setOn:(BOOL)on;
- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (void)blockChangeActionAnimated:(BOOL)a0;
- (void)unblockChangeAction;
- (void)animateCloudFlyInAndFloat:(id)a0;
- (void)startCloudFloatingAnimation:(id)a0;
- (void)startSparkleBlinkAnimation:(id)a0;

@end
