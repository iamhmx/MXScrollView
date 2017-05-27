//
//  MXScrollView.h
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXScrollViewHeader.h"

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
//动画类型，默认无动画
@property (assign, nonatomic) MXImageAnimation animationType;
//缩放动画的缩放系数（0~0.9）
@property (assign, nonatomic) CGFloat scaleRatio;

/**
 初始化（用于事先不知道图片数据，一般图片数据有网络请求而来，先设置好视图，然后设置contents属性）

 @param frame 位置
 @param delay 自动滚动间隔时间
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame withScrollDelay:(CGFloat)delay;

/**
 初始化（用于事先知道图片数据）

 @param frame 位置
 @param contents 图片地址
 @param delay 自动滚动间隔时间
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<NSString*>*)contents andScrollDelay:(CGFloat)delay;

@end
