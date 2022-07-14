//
//  LCImageClipsActionView.m
//  LCImageClips
//
//  Created by lax on 2022/6/21.
//

#import "LCImageClipsActionView.h"

@interface LCImageClipsActionView ()

// 外边框
@property (nonatomic, strong) CAShapeLayer *borderLayer;

// 辅助线
@property (nonatomic, strong) CAShapeLayer *lineLayer;

// 触摸条
@property (nonatomic, strong) CAShapeLayer *barLayer;

@end

@implementation LCImageClipsActionView

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [[CAShapeLayer alloc] init];
        _borderLayer.fillRule = kCAFillRuleEvenOdd;
        _borderLayer.fillColor = [UIColor whiteColor].CGColor;
        _borderLayer.shadowColor = [UIColor blackColor].CGColor;
        _borderLayer.shadowOffset = CGSizeMake(0, 2);
        _borderLayer.shadowRadius = 2;
        _borderLayer.shadowOpacity = 0.1;
        _borderLayer.borderWidth = 2;
    }
    return _borderLayer;
}

- (CAShapeLayer *)lineLayer {
    if (!_lineLayer) {
        _lineLayer = [[CAShapeLayer alloc] init];
        _lineLayer.fillRule = kCAFillRuleNonZero;
        _lineLayer.fillColor = [UIColor whiteColor].CGColor;
        _lineLayer.shadowColor = [UIColor blackColor].CGColor;
        _lineLayer.shadowOffset = CGSizeMake(0, 2);
        _lineLayer.shadowRadius = 2;
        _lineLayer.shadowOpacity = 0.1;
        _borderLayer.borderWidth = 1;
    }
    return _lineLayer;
}

- (CAShapeLayer *)barLayer {
    if (!_barLayer) {
        _barLayer = [[CAShapeLayer alloc] init];
        _barLayer.fillRule = kCAFillRuleNonZero;
        _barLayer.fillColor = [UIColor whiteColor].CGColor;
        _barLayer.shadowColor = [UIColor blackColor].CGColor;
        _barLayer.shadowOffset = CGSizeMake(0, 2);
        _barLayer.shadowRadius = 2;
        _barLayer.shadowOpacity = 0.1;
        _barLayer.borderWidth = 4;
    }
    return _barLayer;
}

- (void)setBarLength:(CGFloat)barHeight {
    _barLength = barHeight;
    [self drawLayer];
}

- (void)setBorderInOut:(BOOL)borderInOut {
    _borderInOut = borderInOut;
    [self drawLayer];
}

- (void)setIsTouch:(BOOL)isTouch {
    _isTouch = isTouch;
    [self drawLayer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self drawLayer];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.barLength = 16;
        [self.layer addSublayer:self.borderLayer];
        [self.layer addSublayer:self.lineLayer];
        [self.layer addSublayer:self.barLayer];
    }
    return self;
}

- (void)drawLayer {
    [self drawBorderLayer];
    [self drawBarLayer];
    if (self.isTouch) {
        [self drawLineLayer];
    } else {
        self.lineLayer.path = nil;
    }
}

- (void)drawBorderLayer {
    
    [CATransaction setDisableActions:YES];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (self.borderLayer.borderWidth > 0) {
        if (self.borderInOut) {
            [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-self.borderLayer.borderWidth, -self.borderLayer.borderWidth, self.bounds.size.width + self.borderLayer.borderWidth * 2, self.bounds.size.height + self.borderLayer.borderWidth * 2) cornerRadius:self.borderLayer.cornerRadius]];
            [path appendPath:[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0]];
        } else {
            [path appendPath:[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0]];
            [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.borderLayer.borderWidth, self.borderLayer.borderWidth, self.bounds.size.width - self.borderLayer.borderWidth * 2, self.bounds.size.height - self.borderLayer.borderWidth * 2) cornerRadius:self.borderLayer.cornerRadius]];
        }
    }
    
    [path closePath];
    
    self.borderLayer.path = path.CGPath;
}

- (void)drawLineLayer {
    
    [CATransaction setDisableActions:YES];

    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, self.frame.size.height / 3 - 0.5, self.frame.size.width, 1) cornerRadius:0]];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, self.frame.size.height / 3 * 2 - 0.5, self.frame.size.width, 1) cornerRadius:0]];
    
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 3, 0, 1, self.frame.size.height) cornerRadius:0]];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 3 * 2, 0, 1, self.frame.size.height) cornerRadius:0]];
    
    [path closePath];
    
    self.lineLayer.path = path.CGPath;
}

- (void)drawBarLayer {
    
    [CATransaction setDisableActions:YES];
    
    CGFloat w = self.barLayer.borderWidth;
    CGFloat l = self.barLength;
    CGFloat x;
    CGFloat y;
    CGFloat r = self.barLayer.cornerRadius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(-w, -w + r)];
    [path addArcWithCenter:CGPointMake(-w + r, -w + r) radius:r startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(l, -w)];
    [path addArcWithCenter:CGPointMake(l, -w + r) radius:r startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(l + r, -r)];
    [path addArcWithCenter:CGPointMake(l, -r) radius:r startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, l)];
    [path addArcWithCenter:CGPointMake(-r, l) radius:r startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(-w + r, l + r)];
    [path addArcWithCenter:CGPointMake(-w + r, l) radius:r startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    x = self.frame.size.width;
    [path moveToPoint:CGPointMake(x - l, -w + r)];
    [path addArcWithCenter:CGPointMake(x - l, -w + r) radius:r startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(x + w - r, -w)];
    [path addArcWithCenter:CGPointMake(x + w - r, -w + r) radius:r startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(x + w, l)];
    [path addArcWithCenter:CGPointMake(x + w - r, l) radius:r startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(x + r, l + r)];
    [path addArcWithCenter:CGPointMake(x + r, l) radius:r startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(x, 0)];
    [path addLineToPoint:CGPointMake(x - l, 0)];
    [path addArcWithCenter:CGPointMake(x - l, -r) radius:r startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(x - l - r, -w + r)];
    
    x = self.frame.size.width;
    y = self.frame.size.height;
    [path moveToPoint:CGPointMake(x, y - l)];
    [path addArcWithCenter:CGPointMake(x + r, y - l) radius:r startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(x + w - r, y - l - r)];
    [path addArcWithCenter:CGPointMake(x + w - r, y - l) radius:r startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(x + w, y + w - r)];
    [path addArcWithCenter:CGPointMake(x + w - r, y + w - r) radius:r startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(x - l, y + w)];
    [path addArcWithCenter:CGPointMake(x - l, y + w - r) radius:r startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(x - l - r, y + r)];
    [path addArcWithCenter:CGPointMake(x - l, y + r) radius:r startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(x, y)];
    
    y = self.frame.size.height;
    [path moveToPoint:CGPointMake(-w, y - l)];
    [path addArcWithCenter:CGPointMake(-w + r, y - l) radius:r startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(-r, y - l - r)];
    [path addArcWithCenter:CGPointMake(-r, y - l) radius:r startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(0, y)];
    [path addLineToPoint:CGPointMake(l, y)];
    [path addArcWithCenter:CGPointMake(l, y + r) radius:r startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(l + r, y + w - r)];
    [path addArcWithCenter:CGPointMake(l, y + w - r) radius:r startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(-w + r, y + w)];
    [path addArcWithCenter:CGPointMake(-w + r, y + w - r) radius:r startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 2 - l, -w, l * 2, w) cornerRadius:r]];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 2 - l, self.frame.size.height, l * 2, w) cornerRadius:r]];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-w, self.frame.size.height / 2 - l, w, l * 2) cornerRadius:r]];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width, self.frame.size.height / 2 - l, w, l * 2) cornerRadius:r]];
    
    [path closePath];
    
    self.barLayer.path = path.CGPath;
}

@end
