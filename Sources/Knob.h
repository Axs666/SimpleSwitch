#import <UIKit/UIKit.h>

@interface Knob : UIView {
    BOOL _shouldAnimate;
}

@property (nonatomic) BOOL on;
@property (nonatomic) BOOL expanded;
@property (retain, nonatomic) UIView *subview;

- (double)subviewMargin;
- (id)sunLayer;
- (id)moonLayer;
- (id)initWithFrame:(CGRect)frame;
- (void)layoutSubviews;
- (void)setAnimated:(BOOL)a0;
- (void)_setOn:(BOOL)a0;
- (void)_setExpanded:(BOOL)a0;

@end
