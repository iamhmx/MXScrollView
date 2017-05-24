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

@interface MXScrollView : UIScrollView
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray <NSString*>*contents;
@property (assign, nonatomic) CGFloat delay;
@property (weak, nonatomic) id <MXScrollViewDelegate> mxDelegate;
@property (strong, nonatomic) UIImage *placeholderImage;

- (instancetype)initWithFrame:(CGRect)frame withScrollDelay:(CGFloat)delay;
- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<NSString*>*)contents andScrollDelay:(CGFloat)delay;
@end
