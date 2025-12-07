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
- (id)initWithCenter:(struct CGPoint { double x0; double x1; })a0;
- (void)commonInit;
- (void)panGestureOccurred:(id)a0;
- (id)initWithCoder:(id)a0;
- (id)initWithFrame:(struct CGRect { struct CGPoint { double x0; double x1; } x0; struct CGSize { double x0; double x1; } x1; })a0;
- (void)tapGestureOccurred:(id)a0;
- (void)_setOn:(BOOL)a0;
- (void)blockChangeActionAnimated:(BOOL)a0;
- (void)unblockChangeAction;
- (void)animateCloudFlyInAndFloat:(id)a0;
- (void)startCloudFloatingAnimation:(id)a0;
- (void)startSparkleBlinkAnimation:(id)a0;
- (void).cxx_destruct;

@end
