//
//  MXScrollView.h
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MXScrollViewDelegate <NSObject>

@optional
- (void)clickImageIndex:(NSInteger)index;

@end

typedef void(^MXClickImageHandler)(NSInteger index);

@interface MXScrollView : UIView
//图片内容
@property (strong, nonatomic) NSArray <NSString*>*contents;
//自动滚动间隔时间
@property (assign, nonatomic) CGFloat delay;
@property (weak, nonatomic)   id <MXScrollViewDelegate> delegate;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (copy, nonatomic)   MXClickImageHandler clickHandler;
//是否显示pageControl，默认显示
@property (assign, nonatomic) BOOL hidePageControl;
//渐变动画，默认关闭
@property (assign, nonatomic) BOOL fadeInOutAnimation;

- (instancetype)initWithFrame:(CGRect)frame withScrollDelay:(CGFloat)delay;
- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<NSString*>*)contents andScrollDelay:(CGFloat)delay;

@end
