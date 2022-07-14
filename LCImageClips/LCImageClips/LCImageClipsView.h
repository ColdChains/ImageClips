//
//  LCImageClipsView.h
//  LCImageClips
//
//  Created by lax on 2022/6/21.
//

#import <UIKit/UIKit.h>
#import "LCImageClipsActionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCImageClipsView : UIView

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinchGesture;

// 蒙层 默认黑色0.5透明度
@property (nonatomic, strong, readonly) CAShapeLayer *maskLayer;

// 图片视图
@property (nonatomic, strong, readonly) UIImageView *imageView;

// 操作视图
@property (nonatomic, strong, readonly) LCImageClipsActionView *actionView;

// 操作视图扩大响应区域
@property (nonatomic) UIEdgeInsets actionViewHitTestInsets;

// 需要裁剪的图片 如果使用约束布局需要约束生效后再设置
@property (nonatomic, strong) UIImage *image;

// 图片内边距 默认0
@property (nonatomic) UIEdgeInsets edgInsets;

// 裁剪图片
- (nullable UIImage *)clipsImage;

@end

NS_ASSUME_NONNULL_END
