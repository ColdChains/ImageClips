//
//  LCImageClipsView.m
//  LCImageClips
//
//  Created by lax on 2022/6/21.
//

#import "LCImageClipsView.h"

typedef NS_OPTIONS(NSUInteger, LCTransformOrientation) {
    LCTransformOrientationNone = 0,
    LCTransformOrientationTop = 1 << 0,
    LCTransformOrientationLeft = 1 << 1,
    LCTransformOrientationBottom = 1 << 2,
    LCTransformOrientationRight = 1 << 3,
};

@interface LCImageClipsView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

// 蒙层
@property (nonatomic, strong) CAShapeLayer *maskLayer;

// 图片视图
@property (nonatomic, strong) UIImageView *imageView;

// 操作视图
@property (nonatomic, strong) LCImageClipsActionView *actionView;

// 操作视图拖拽前的位置
@property (nonatomic) CGRect actionViewOriginalFrame;

// 操作视图最小大小 (actionView的触摸条重叠的大小）
@property (nonatomic) CGSize actionViewMinSize;

// 操作视图可以调整的方向
@property (nonatomic) LCTransformOrientation actionViewTransformOrientation;

@end

@implementation LCImageClipsView

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
        _maskLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    }
    return _maskLayer;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (LCImageClipsActionView *)actionView {
    if (!_actionView) {
        _actionView = [[LCImageClipsActionView alloc] init];
        _actionView.frame = CGRectMake(0, 0, self.actionViewMinSize.width, self.actionViewMinSize.height);
    }
    return _actionView;
}

- (CGSize)actionViewMinSize {
    return CGSizeMake(self.actionView.barLength * 2, self.actionView.barLength * 2);
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = image;
    [self initImageView];
    
    if (!self.actionView.superview) {
        [self addSubview:self.actionView];
    }
    self.actionView.frame = self.imageView.frame;
}

- (void)setEdgInsets:(UIEdgeInsets)edgInsets {
    _edgInsets = edgInsets;
    [self initImageView];
}

// MARK: - System

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self initImageView];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame" context:nil];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(UIEdgeInsetsInsetRect(self.actionView.bounds, self.actionViewHitTestInsets), [self.actionView convertPoint:point fromView:self])) {
        return self.actionView;
    }
    return [super hitTest:point withEvent:event];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawBackLayer];
}

// MARK: - Custom

- (void)initView {
    self.edgInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.actionViewHitTestInsets = UIEdgeInsetsMake(-16, -16, -16, -16);
    
    [self addSubview:self.imageView];
    
    [self.layer addSublayer:self.maskLayer];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:self.panGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:self.pinchGesture];
}

- (void)initImageView {
    if (!self.imageView.image) { return; }
    
    if (self.imageView.image.size.width == 0 || self.imageView.image.size.height == 0) {
        self.imageView.frame = self.bounds;
    } else {
        self.imageView.frame = [self adaptionSize:self.frame.size edgInsets:self.edgInsets image:self.imageView.image aspectFit:YES needOrigin:YES];
    }
    
    if (CGRectContainsRect(self.actionView.bounds, self.imageView.bounds)) {
        self.actionView.bounds = self.imageView.bounds;
    }
    self.actionView.center = self.imageView.center;
    
}

// 宽高适配
- (CGRect)adaptionSize:(CGSize)size edgInsets:(UIEdgeInsets)edgInsets image:(UIImage *)image aspectFit:(BOOL)aspectFit needOrigin:(BOOL)needOrigin {
    CGFloat limitW = size.width - edgInsets.left - edgInsets.right;
    CGFloat limitH = size.height - edgInsets.top - edgInsets.bottom;
    CGFloat limitScale = limitW / limitH;
    CGFloat scale = image.size.width / image.size.height;
    CGFloat w = 0;
    CGFloat h = 0;
    if (aspectFit ? scale > limitScale : scale < limitScale) {
        w = limitW;
        h = limitW / image.size.width * image.size.height;
    } else {
        w = limitH / image.size.height * image.size.width;
        h = limitH;
    }
    return needOrigin ? CGRectMake(edgInsets.left + (limitW - w) / 2, edgInsets.top + (limitH - h) / 2, w, h) : CGRectMake(0, 0, w, h);
}

// 拖拽事件
- (void)panAction:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.actionView.isTouch = YES;
        self.actionViewOriginalFrame = self.actionView.frame;
        
        self.actionViewTransformOrientation = LCTransformOrientationNone;
        
        CGPoint point = [sender locationInView:self.actionView];
        
        if (CGRectContainsPoint(UIEdgeInsetsInsetRect(self.actionView.bounds, self.actionViewHitTestInsets), point)) {
            if (point.x < -self.actionViewHitTestInsets.left) {
                self.actionViewTransformOrientation = self.actionViewTransformOrientation | LCTransformOrientationLeft;
            }
            if (point.x > self.actionView.bounds.size.width + self.actionViewHitTestInsets.right) {
                self.actionViewTransformOrientation = self.actionViewTransformOrientation | LCTransformOrientationRight;
            }
            if (point.y < -self.actionViewHitTestInsets.top) {
                self.actionViewTransformOrientation = self.actionViewTransformOrientation | LCTransformOrientationTop;
            }
            if (point.y > self.actionView.bounds.size.height + self.actionViewHitTestInsets.bottom) {
                self.actionViewTransformOrientation = self.actionViewTransformOrientation | LCTransformOrientationBottom;
            }
        }
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [sender translationInView:self];
        CGRect frame = self.actionViewOriginalFrame;
        
        if (self.actionViewTransformOrientation == LCTransformOrientationNone) {
            frame.origin.x += translation.x;
            frame.origin.x = MAX(frame.origin.x, CGRectGetMinX(self.imageView.frame));
            frame.origin.x = MIN(frame.origin.x, CGRectGetMaxX(self.imageView.frame) - frame.size.width);
            
            frame.origin.y += translation.y;
            frame.origin.y = MAX(frame.origin.y, CGRectGetMinY(self.imageView.frame));
            frame.origin.y = MIN(frame.origin.y, CGRectGetMaxY(self.imageView.frame) - frame.size.height);
        }
        if (self.actionViewTransformOrientation & LCTransformOrientationLeft) {
            frame.size.width -= translation.x;
            frame.size.width = MIN(frame.size.width, CGRectGetMaxX(self.actionViewOriginalFrame) - CGRectGetMinX(self.imageView.frame));
            frame.size.width = MAX(frame.size.width, self.actionViewMinSize.width);
            
            frame.origin.x -= frame.size.width - self.actionViewOriginalFrame.size.width;
        }
        if (self.actionViewTransformOrientation & LCTransformOrientationRight) {
            frame.size.width += translation.x;
            frame.size.width = MIN(frame.size.width, CGRectGetMaxX(self.imageView.frame) - self.actionViewOriginalFrame.origin.x);
            frame.size.width = MAX(frame.size.width, self.actionViewMinSize.width);
        }
        if (self.actionViewTransformOrientation & LCTransformOrientationTop) {
            frame.size.height -= translation.y;
            frame.size.height = MIN(frame.size.height, CGRectGetMaxY(self.actionViewOriginalFrame) - CGRectGetMinY(self.imageView.frame));
            frame.size.height = MAX(frame.size.height, self.actionViewMinSize.height);
            
            frame.origin.y -= frame.size.height - self.actionViewOriginalFrame.size.height;
        }
        if (self.actionViewTransformOrientation & LCTransformOrientationBottom) {
            frame.size.height += translation.y;
            frame.size.height = MIN(frame.size.height, CGRectGetMaxY(self.imageView.frame) - self.actionViewOriginalFrame.origin.y);
            frame.size.height = MAX(frame.size.height, self.actionViewMinSize.height);
        }
        
        self.actionView.frame = frame;
        [self drawBackLayer];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        self.actionView.isTouch = NO;
    }
}

// 缩放事件
- (void)pinchAction:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.actionView.isTouch = YES;
        self.actionViewOriginalFrame = self.actionView.frame;
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = sender.scale;
        
        CGRect frame = self.actionViewOriginalFrame;
        frame.size.width = frame.size.width * scale;
        frame.size.width = MIN(frame.size.width, self.imageView.frame.size.width);
        frame.size.width = MAX(frame.size.width, self.actionViewMinSize.width);
        
        frame.size.height = frame.size.height * scale;
        frame.size.height = MIN(frame.size.height, self.imageView.frame.size.height);
        frame.size.height = MAX(frame.size.height, self.actionViewMinSize.height);
        
        frame.origin.x -= (frame.size.width - self.actionViewOriginalFrame.size.width) / 2;
        frame.origin.x = MAX(frame.origin.x, CGRectGetMinX(self.imageView.frame));
        frame.origin.x = MIN(frame.origin.x, CGRectGetMaxX(self.imageView.frame) - frame.size.width);
        
        frame.origin.y -= (frame.size.height - self.actionViewOriginalFrame.size.height) / 2;
        frame.origin.y = MAX(frame.origin.y, CGRectGetMinY(self.imageView.frame));
        frame.origin.y = MIN(frame.origin.y, CGRectGetMaxY(self.imageView.frame) - frame.size.height);
        
        self.actionView.frame = frame;
        [self drawBackLayer];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        self.actionView.isTouch = NO;
    }
}

// 绘制蒙层
- (void)drawBackLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    if (self.image) {
        [path appendPath:[UIBezierPath bezierPathWithRect:self.actionView.frame]];
    }
    [path closePath];
    self.maskLayer.path = path.CGPath;
}

// 裁剪图片
- (UIImage *)clipsImage {
    if (!self.imageView.image) {
        return nil;
    }
    
    if (CGRectEqualToRect(self.imageView.frame, self.actionView.frame)) {
        return self.imageView.image;
    }
    
    CGFloat scale = CGRectGetWidth(self.imageView.bounds) / self.imageView.image.size.width;
    CGRect rect = [self convertRect:self.actionView.frame toView:self.imageView];
    rect = CGRectMake(CGRectGetMinX(rect) / scale, CGRectGetMinY(rect) / scale, CGRectGetWidth(rect) / scale, CGRectGetHeight(rect) / scale);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    [self.imageView.image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return clipImage;
}

@end
