//
//  ViewController.m
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import "ViewController.h"
#import "MXScrollView.h"

@interface ViewController ()<MXScrollViewDelegate>
@property (strong, nonatomic) NSArray *imageUrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    /*初始化一：已知图片数据*/
    MXScrollView *mxScrollView = [[MXScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) withContents:self.imageUrls andScrollDelay:3.5];
    
    /*初始化二：不知图片数据，数据由网络请求而来，更常见*/
    /*MXScrollView *mxScrollView = [[MXScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) withScrollDelay:3.5];
    //请求到数据，设置图片
    [self requestDataFromNet:^(id data) {
        [mxScrollView setContents:data];
    }];*/
    
    //设置动画类型
    //渐变
    //mxScrollView.animationType = MXImageAnimationFadeInOut;
    
    //旋转
    mxScrollView.animationType = MXImageAnimationRotation;
    
    //缩放
    //mxScrollView.animationType = MXImageAnimationScale;
    //mxScrollView.scaleRatio = 0.5;
    
    //mxScrollView.animationType = MXImageAnimationUp;
    
    //mxScrollView.animationType = MXImageAnimationDown;
    
    mxScrollView.animationType = MXImageAnimationBlur;
    
    //方法一：设置代理并实现方法
    //mxScrollView.delegate = self;
    
    //方法二：设置回调Block
    mxScrollView.clickHandler = ^(NSInteger index) {
        NSLog(@"图片index：%ld",index);
    };
    
    [self.view addSubview:mxScrollView];
}

- (void)clickImageIndex:(NSInteger)index {
    NSLog(@"图片index：%ld",index);
}

- (NSArray *)imageUrls {
    return @[@"http://a2.att.hudong.com/73/16/01300000165476121211162421024.jpg", @"http://pic8.nipic.com/20100808/4953913_162517044879_2.jpg",@"http://www.taopic.com/uploads/allimg/121214/267863-12121421114939.jpg"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
