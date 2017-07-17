//
//  MXCycleScrollView.h
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

/*
 github:https://github.com/iamhmx
 */

#import <UIKit/UIKit.h>
#import "MXCycleScrollViewHeader.h"

/**
 图片和文字模型
 */
@interface MXImageModel : NSObject
@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *imageText;
@end

@protocol MXCycleScrollViewDelegate <NSObject>

@optional
- (void)clickImageIndex:(NSInteger)index;

@end

typedef void(^MXClickImageHandler)(NSInteger index);

@interface MXCycleScrollView : UIView

@property (weak, nonatomic)   id <MXCycleScrollViewDelegate> delegate;

@property (copy, nonatomic)   MXClickImageHandler clickHandler;

/**
 图片&文字内容
 */
@property (strong, nonatomic) NSArray <MXImageModel*>* contents;

/**
 自动滚动间隔时间
 */
@property (assign, nonatomic) CGFloat delay;

/**
 图片加载失败显示图片，默认为nil
 */
@property (strong, nonatomic) UIImage *placeholderImage;

/**
 是否显示pageControl，默认为YES
 */
@property (assign, nonatomic) BOOL hidePageControl;

/**
 pageControl颜色
 */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

/**
 pageControl圆点大小
 */
@property (assign, nonatomic) CGFloat pageControlDotWidth;

/**
 pageControl圆点间距
 */
@property (assign, nonatomic) CGFloat pageControlDotMargin;

/**
 是否显示文字，默认为NO
 */
@property (assign, nonatomic) BOOL showText;

/**
 动画类型，默认无动画
 */
@property (assign, nonatomic) MXImageAnimation animationType;

/**
 缩放动画的缩放系数（0~0.9）
 */
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
- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<MXImageModel*>*)contents andScrollDelay:(CGFloat)delay;

@end
