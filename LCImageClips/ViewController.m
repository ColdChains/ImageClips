//
//  ViewController.m
//  LCImageClips
//
//  Created by lax on 2022/6/21.
//

#import "ViewController.h"
#import "LCImageClipsView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LCImageClipsView *clipView = [[LCImageClipsView alloc] init];
    clipView.frame = CGRectMake(16, 88, UIScreen.mainScreen.bounds.size.width - 32, UIScreen.mainScreen.bounds.size.width - 32);
    clipView.backgroundColor = [UIColor orangeColor];
    clipView.actionViewHitTestInsets = UIEdgeInsetsMake(-22, -22, -22, -22);
    
    // 自定义样式
    clipView.maskLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
    // 设置边框
    clipView.actionView.borderLayer.borderWidth = 5;
    clipView.actionView.borderInOut = YES;
    // 设置触摸条
    clipView.actionView.barLayer.borderWidth = 10;
    clipView.actionView.barLayer.cornerRadius = 3;
    clipView.actionView.barLayer.fillColor = [UIColor greenColor].CGColor;
    
    clipView.tag = 200;
    [self.view addSubview:clipView];
    
    clipView.image = [UIImage imageNamed:@"image"];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIImageView *imageView = [self.view viewWithTag:100];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor grayColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 100;
        imageView.frame = CGRectMake(16, 500, 100, 100);
        [self.view addSubview:imageView];
    }
    // 裁剪图片
    LCImageClipsView *clipView = [(LCImageClipsView *)self.view viewWithTag:200];
    imageView.image = [clipView clipsImage];
}

@end
