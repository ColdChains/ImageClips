//
//  LCImageClipsActionView.h
//  LCImageClips
//
//  Created by lax on 2022/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCImageClipsActionView : UIView

// 外边框 默认白色
@property (nonatomic, strong, readonly) CAShapeLayer *borderLayer;

// 辅助线 默认白色
@property (nonatomic, strong, readonly) CAShapeLayer *lineLayer;

// 触摸条 默认白色
@property (nonatomic, strong, readonly) CAShapeLayer *barLayer;

// 触摸条高度 默认16 (角上的触摸条长度 中间的触摸条长度会X2)
@property (nonatomic) CGFloat barLength;

// 是否是外边框 默认NO
@property (nonatomic) BOOL borderInOut;

// 是否正在触摸
@property (nonatomic) BOOL isTouch;

@end

NS_ASSUME_NONNULL_END
