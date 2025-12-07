@class UIView;

@interface Knob : UIView {
    BOOL _shouldAnimate;
}

@property (nonatomic) BOOL on;
@property (nonatomic) BOOL expanded;
@property (retain, nonatomic) UIView *subview;

- (double)subviewMargin;
- (id)sunLayer;
- (id)moonLayer;
- (id)initWithFrame:(struct CGRect { struct CGPoint { double x0; double x1; } x0; struct CGSize { double x0; double x1; } x1; })a0;
- (void)layoutSubviews;
- (void)setAnimated:(BOOL)a0;
- (void)_setOn:(BOOL)a0;
- (void)_setExpanded:(BOOL)a0;
- (void).cxx_destruct;

@end
