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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    NSArray *imageUrls = @[@"http://a2.att.hudong.com/73/16/01300000165476121211162421024.jpg", @"http://pic8.nipic.com/20100808/4953913_162517044879_2.jpg",@"http://www.taopic.com/uploads/allimg/121214/267863-12121421114939.jpg"];
    MXScrollView *mxScrollView = [[MXScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) withContents:imageUrls andScrollDelay:3.5];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
