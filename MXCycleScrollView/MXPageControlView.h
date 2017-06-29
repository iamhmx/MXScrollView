//
//  MXPageControlView.h
//  Pods
//
//  Created by msxf on 2017/6/29.
//
//

#import <UIKit/UIKit.h>

@interface MXPageControlView : UIView
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger numberOfPages;
@property (strong, nonatomic) UIColor *pageIndicatorTintColor;
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor;
//圆点宽高
@property (assign, nonatomic) CGFloat dotWidth;
//圆点间隔距离
@property (assign, nonatomic) CGFloat dotMargin;

//显示文字，默认为NO
@property (assign, nonatomic) BOOL showText;
//文字是在翻页后设置，初始化后需设置第一张图片对应的文字
@property (copy, nonatomic) NSString *firstText;
//图片对应的文字
@property (copy, nonatomic) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame andFirstText:(NSString*)firstText;

@end
