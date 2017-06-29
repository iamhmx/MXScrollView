//
//  MXPageControlView.m
//  Pods
//
//  Created by msxf on 2017/6/29.
//
//

#import "MXPageControlView.h"

#define MXDotW 7
#define MXMagrin 7

@interface MXPageControl : UIPageControl
//圆点宽高，默认7
@property (assign, nonatomic) CGFloat dotWidth;
//圆点间隔距离，默认7
@property (assign, nonatomic) CGFloat dotMargin;
@property (assign, nonatomic) BOOL customize;
@end

@implementation MXPageControl
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.dotWidth = MXDotW;
        self.dotMargin = MXMagrin;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //计算圆点间距
    CGFloat marginX = self.dotWidth + self.dotMargin;
    if (_customize) {
        //遍历subview,设置圆点frame
        for (NSInteger i = 0; i < [self.subviews count]; i++) {
            UIImageView* dot = [self.subviews objectAtIndex:i];
            [dot setFrame:CGRectMake(self.dotMargin/2 + i * marginX, (CGRectGetHeight(self.frame) - self.dotWidth)/2.0, self.dotWidth, self.dotWidth)];
        }
    } else {
        //遍历subview,设置圆点frame
        CGFloat width = self.dotWidth * self.numberOfPages + self.dotMargin * (self.numberOfPages - 1);
        CGFloat firstDotX;
        for (NSInteger i = 0; i < [self.subviews count]; i++) {
            UIImageView* dot = [self.subviews objectAtIndex:i];
            if (i == 0) {
                firstDotX = (CGRectGetWidth(self.frame)-width)/2;
            }
            [dot setFrame:CGRectMake(firstDotX + i * marginX, (CGRectGetHeight(self.frame) - self.dotWidth)/2.0, self.dotWidth, self.dotWidth)];
        }
    }
}

@end

@interface MXPageControlView ()
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) MXPageControl *pageControl;
@property (assign, nonatomic) CGFloat pageControlWidth;
@end

@implementation MXPageControlView

- (instancetype)initWithFrame:(CGRect)frame andFirstText:(NSString*)firstText {
    MXPageControlView *view = [[MXPageControlView alloc]initWithFrame:frame];
    self.firstText = firstText;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.dotWidth = MXDotW;
        self.dotMargin = MXMagrin;
        self.label = [UILabel new];
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.label];
        
        self.pageControl = [[MXPageControl alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.pageControl.hidesForSinglePage = YES;
        [self addSubview:self.pageControl];
        
        self.showText = NO;
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    self.pageControl.currentPage = currentPage;
}

- (NSInteger)currentPage {
    return self.pageControl.currentPage;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    self.pageControl.numberOfPages = numberOfPages;
    //最后加上一个间距，在有文字显示时，在右边留出间隔
    self.pageControlWidth = numberOfPages * MXDotW + (numberOfPages-1) * MXMagrin + MXMagrin;
}

- (NSInteger)numberOfPages {
    return self.pageControl.numberOfPages;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setDotWidth:(CGFloat)dotWidth {
    self.pageControl.dotWidth = dotWidth;
}

- (void)setDotMargin:(CGFloat)dotMargin {
    self.pageControl.dotMargin = dotMargin;
}

- (void)setFirstText:(NSString *)firstText {
    self.label.text = firstText;
}

- (void)setShowText:(BOOL)showText {
    _showText = showText;
    if (showText) {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        self.label.hidden = NO;
        self.label.frame = CGRectMake(10, 0, CGRectGetWidth(self.frame)-self.pageControlWidth, CGRectGetHeight(self.frame));
        
        self.pageControl.customize = YES;
        self.pageControl.frame = CGRectMake(CGRectGetWidth(self.frame)-self.pageControlWidth, 0, self.pageControlWidth, CGRectGetHeight(self.frame));
    } else {
        self.label.hidden = YES;
        
        self.pageControl.customize = NO;
        self.pageControl.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
}

- (void)setText:(NSString *)text {
    self.label.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
