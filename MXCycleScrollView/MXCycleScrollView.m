//
//  MXCycleScrollView.m
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import "MXCycleScrollView.h"
#import "UIImageView+WebCache.h"
#import "MXPageControlView.h"

@implementation MXImageModel

@end

typedef void(^MXClickHandler)(NSInteger index);

@interface MXImageView : UIView
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIControl *control;
@property (assign, nonatomic) NSInteger actionTag;
@property (copy, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImage *placeholder;
@property (copy, nonatomic) MXClickHandler handler;
@property (assign, nonatomic) BOOL hideCover;
@property (assign, nonatomic) CGFloat coverViewAlpha;
@property (assign, nonatomic) BOOL hideBlur;
@property (assign, nonatomic) CGFloat blurViewAlpha;
@property (strong, nonatomic) UIVisualEffectView *blurImageView;
@end

@implementation MXImageView

- (instancetype)initWithFrame:(CGRect)frame imageURL:(NSString*)url placeholderImage:(UIImage*)placeholder {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.placeholder = placeholder;
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.backgroundColor = [UIColor whiteColor];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder];
        [self addSubview:self.imageView];
        
        self.blurImageView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.blurImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.blurImageView.alpha = 0;
        [self.imageView addSubview:self.blurImageView];
        
        self.control = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.control addTarget:self action:@selector(imageClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.control];
    }
    return self;
}

- (void)setHideCover:(BOOL)hideCover {
    self.imageView.alpha = hideCover?0:1;
}

- (void)setCoverViewAlpha:(CGFloat)coverViewAlpha {
    self.imageView.alpha = coverViewAlpha;
}

- (void)setHideBlur:(BOOL)hideBlur {
    self.blurImageView.alpha = hideBlur?0:1;
}

- (void)setBlurViewAlpha:(CGFloat)blurViewAlpha {
    self.blurImageView.alpha = blurViewAlpha;
}

- (void)setActionTag:(NSInteger)actionTag {
    self.control.tag = actionTag;
}

- (void)setImageUrl:(NSString *)imageUrl {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:self.placeholder];
}

- (void)imageClickAction:(UIControl*)ct {
    if (self.handler) {
        self.handler(ct.tag);
    }
}

@end

@interface MXCycleScrollView ()<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
//@property (strong, nonatomic) UIView *pageControlView;
//@property (strong, nonatomic) UIPageControl *pageControl;
//@property (strong, nonatomic) UILabel *pageControlTextLabel;
@property (strong, nonatomic) MXPageControlView *pageControlView;
@property (assign, nonatomic) CGRect contentRect;
@property (assign, nonatomic) NSUInteger originalImageCount;
@property (assign, nonatomic) NSInteger imageCount;
//定时器，控制自动滚动广告
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL manual;
@property (strong, nonatomic) NSMutableArray <MXImageModel*>*imageModelArray;
@property (strong, nonatomic) NSMutableArray <NSString*>*mImageArray;
@property (strong, nonatomic) NSMutableArray *imageViewArray;
@property (strong, nonatomic) MXImageView *currentImage;
@property (strong, nonatomic) MXImageView *preImage;
@property (strong, nonatomic) MXImageView *nextImage;
//上一次scrollView的偏移量
@property (assign, nonatomic) NSInteger lastX;
//滚动方向，← or →
@property (assign, nonatomic) BOOL scrollLeft;
//基于父视图坐标
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@end

@implementation MXCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame withScrollDelay:(CGFloat)delay {
    if (self = [super initWithFrame:frame]) {
        self.contentRect = frame;
        self.delay = delay;
        [self setupScrollView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<MXImageModel*>*)contents andScrollDelay:(CGFloat)delay {
    MXCycleScrollView *view = [[MXCycleScrollView alloc]initWithFrame:frame withScrollDelay:delay];
    view.imageModelArray = [[NSMutableArray alloc] initWithArray:contents];
    view.mImageArray = [NSMutableArray new];
    for (MXImageModel *model in contents) {
        [view.mImageArray addObject:model.imageUrl];
    }
    [view initContents];
    return view;
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    /*self.pageControlView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-MXPageControlHeight, kScreenWidth, MXPageControlHeight)];
    [self addSubview:self.pageControlView];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, MXPageControlHeight)];
    self.pageControl.hidesForSinglePage = YES;
    [self.pageControlView addSubview:self.pageControl];
    [self.pageControl sizeForNumberOfPages:6];*/
    
    self.pageControlView = [[MXPageControlView alloc]initWithFrame:CGRectMake(0, self.height-MXPageControlHeight, kScreenWidth, MXPageControlHeight)];
    //self.pageControlView.dotWidth = 5;
    //self.pageControlView.dotMargin = 5;
    [self addSubview:_pageControlView];
}

- (void)setContents:(NSArray <NSString*>*)contents {
    self.imageModelArray = [[NSMutableArray alloc] initWithArray:contents];
    self.mImageArray = [NSMutableArray new];
    for (MXImageModel *model in contents) {
        [self.mImageArray addObject:model.imageUrl];
    }
    [self initContents];
}

- (void)initContents {
    [self initData];
    [self clearViewsTagAbove:MXImageViewTagBase];
    [self setupImageViews];
    [self setupTimer];
}

- (void)initData {
    self.pageControlView.numberOfPages = self.mImageArray.count;
    self.originalImageCount = self.mImageArray.count;
    if (self.mImageArray.count > 1) {
        //这里在最开始和最后多加一张图片，做循环滚动
        NSString *firstImageName = [NSString stringWithString:[_mImageArray lastObject]];
        NSString *lastImageName = [NSString stringWithString:[_mImageArray firstObject]];
        [self.mImageArray insertObject:firstImageName atIndex:0];
        [self.mImageArray insertObject:lastImageName atIndex:_mImageArray.count];
    }
    self.imageCount = self.mImageArray.count;
    self.scrollView.contentSize = CGSizeMake(self.width*self.mImageArray.count, self.height);
    if (self.mImageArray.count > 1) {
        self.scrollView.contentOffset = CGPointMake(self.width, 0);
        self.lastX = self.width;
    }
}

- (void)clearViewsTagAbove:(NSInteger)tag {
    NSArray *subViews = [self subviews];
    for (NSInteger i = 0; i < subViews.count; i++) {
        @autoreleasepool {
            UIView *view = subViews[i];
            if (view.tag >= tag) {
                [view removeFromSuperview];
                view = nil;
            }
        }
    }
}

- (void)setupImageViews {
    @MXWeakObj(self);
    self.imageViewArray = [NSMutableArray new];
    for (NSInteger i = 0; i < self.imageCount; i++) {
        @autoreleasepool {
            MXImageView *imageView = [[MXImageView alloc]initWithFrame:CGRectMake(self.width*i, 0, self.width, self.height) imageURL:_mImageArray[i] placeholderImage:self.placeholderImage];
            imageView.tag = i+MXImageViewTagBase;
            if (self.imageCount > 1) {
                imageView.actionTag = i-1;
                //第一张和最后一张是一样的
                if (imageView.actionTag == -1) {
                    imageView.actionTag += _originalImageCount;
                } else if (imageView.actionTag == _imageCount-2) {
                    imageView.actionTag -= _originalImageCount;
                }
            } else {
                imageView.actionTag = i;
            }
            imageView.handler = ^(NSInteger index) {
                @MXStrongObj(self);
                if ([self.delegate respondsToSelector:@selector(clickImageIndex:)]) {
                    [self.delegate clickImageIndex:index];
                }
                if (self.clickHandler) {
                    self.clickHandler(index);
                }
            };
            [self.scrollView addSubview:imageView];
            [self.imageViewArray addObject:imageView];
        }
    }
    [self resetThreeImages];
}

- (void)setupTimer {
    if (self.mImageArray.count > 1 && self.delay > 0) {
        //设置好滚动视图，启动定时器
        if (!self.timer) {
            self.timer = [self createTimer];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (NSTimer*)createTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_delay target:self selector:@selector(autoScrollAd) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

- (void)autoScrollAd {
    @MXWeakObj(self);
    NSInteger page = 0;
    NSInteger x = self.scrollView.contentOffset.x/self.width;
    page = x - 1;
    //显示最后一张，移动offset到最左边
    if (x == _imageCount - 2) {
        self.scrollView.contentOffset = CGPointZero;
        x = 0;
        page = -1;
    }
    //在滚动前获取三张图片
    [self resetThreeImages];
    //滚动到下一页
    [UIView animateWithDuration:MXAutoScrollDuration animations:^{
        @MXStrongObj(self);
        self.scrollView.contentOffset = CGPointMake((x+1)*self.width, 0);
        if (self.animationType == MXImageAnimationFadeInOut) {
            //自动滚动只需要考虑当前页和下一页
            self.currentImage.hideCover = YES;
            self.nextImage.hideCover = NO;
        } else if (self.animationType == MXImageAnimationRotation) {
            //自动滚动只需要考虑向左，逆时针方向
            self.currentImage.transform = CGAffineTransformMakeRotation(-M_PI_4);
        } else if (self.animationType == MXImageAnimationScale) {
            self.currentImage.transform = CGAffineTransformMakeScale(1 - self.scaleRatio, 1 - self.scaleRatio);
            self.preImage.transform = self.nextImage.transform = CGAffineTransformMakeScale(1, 1);
        }
    } completion:^(BOOL finished) {
        @MXStrongObj(self);
        self.pageControlView.currentPage = page + 1;
        if (self.showText) {
            self.pageControlView.text = self.imageModelArray[self.pageControlView.currentPage].imageText;
        }
        //衔接自动滚动后手动滑动
        self.lastX = self.scrollView.contentOffset.x;
        [self resetThreeImages];
    }];
}

- (void)resetThreeImages {
    NSInteger offX = self.scrollView.contentOffset.x/self.width;
    if (self.imageViewArray.count > 2) {
        self.currentImage = self.imageViewArray[offX];
        if (offX > 0) {
            self.preImage = self.imageViewArray[offX-1];
        }
        self.nextImage = self.imageViewArray[offX+1];
        if (self.animationType == MXImageAnimationFadeInOut) {
            //self.preImage.hideCover = self.nextImage.hideCover = NO;
            //self.currentImage.hideCover = YES;
            self.preImage.hideCover = self.nextImage.hideCover = YES;
            self.currentImage.hideCover = NO;
        } else if (self.animationType == MXImageAnimationRotation) {
            [self.scrollView bringSubviewToFront:self.currentImage];
            self.currentImage.layer.shadowOffset = CGSizeMake(0, 0);
            self.currentImage.layer.shadowColor = [UIColor blackColor].CGColor;
            self.currentImage.layer.shadowOpacity = 0.8;
            self.currentImage.layer.shadowRadius = 4;
            self.currentImage.transform = self.preImage.transform = self.nextImage.transform = CGAffineTransformIdentity;
        } else if (self.animationType == MXImageAnimationScale) {
            self.currentImage.transform = CGAffineTransformIdentity;
            self.preImage.transform = self.nextImage.transform = CGAffineTransformMakeScale(1 - self.scaleRatio, 1 - self.scaleRatio);
        } else if (self.animationType == MXImageAnimationDown ||
                   self.animationType == MXImageAnimationUp) {
            self.currentImage.frame = CGRectMake(self.currentImage.frame.origin.x, 0, CGRectGetWidth(self.currentImage.frame), CGRectGetHeight(self.currentImage.frame));
            self.preImage.frame = CGRectMake(self.preImage.frame.origin.x, 0, CGRectGetWidth(self.preImage.frame), CGRectGetHeight(self.preImage.frame));
            self.nextImage.frame = CGRectMake(self.nextImage.frame.origin.x, 0, CGRectGetWidth(self.nextImage.frame), CGRectGetHeight(self.nextImage.frame));
        } else if (self.animationType == MXImageAnimationBlur) {
            self.preImage.hideBlur = self.nextImage.hideBlur = NO;
            self.currentImage.hideBlur = YES;
        }
    }
}

#pragma mark scrollView代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger offX = scrollView.contentOffset.x/self.width;
    NSInteger page = offX - 1;
    if (offX == 0) {
        //滑动到第一张
        scrollView.contentOffset = CGPointMake(_originalImageCount*self.width, 0);
        page = _originalImageCount-1;
    } else if (offX == _imageCount-1) {
        //滑动到最后一张
        scrollView.contentOffset = CGPointMake(self.width, 0);
        page = 0;
    }
    self.pageControlView.currentPage = page;
    if (self.showText) {
        self.pageControlView.text = self.imageModelArray[page].imageText;
    }
    self.lastX = scrollView.contentOffset.x;
    [self resetThreeImages];
    if (self.manual && self.delay > 0) {
        self.timer = [self createTimer];
        self.manual = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //如果手动滑动，先取消定时器
    self.manual = YES;
    if (self.timer != nil) {
        [self.timer invalidate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"last = %ld, offset = %ld", (long)self.lastX, (long)scrollView.contentOffset.x);
    //相对于上次contentOffset.x的滚动距离（0~self.width）
    NSInteger scrollDistance = labs(self.lastX - (NSInteger)scrollView.contentOffset.x);
    scrollDistance = MIN(scrollDistance, self.width);
    NSLog(@"scrollDistance = %ld", (long)scrollDistance);
    
    CGFloat ratio = scrollDistance / self.width;
    NSLog(@"ratio = %.1f",ratio);
    
    switch (self.animationType) {
        case MXImageAnimationFadeInOut:
            self.currentImage.coverViewAlpha = 1 - ratio;
            self.preImage.coverViewAlpha = self.nextImage.coverViewAlpha = ratio;
            break;
            
        case MXImageAnimationRotation:
            self.currentImage.transform = CGAffineTransformMakeRotation((self.scrollLeft?-1:1) * ratio * M_PI_4);
            break;
            
        case MXImageAnimationScale:
            self.currentImage.transform = CGAffineTransformMakeScale(1 - ratio * self.scaleRatio, 1 - ratio * self.scaleRatio);
            self.preImage.transform = self.nextImage.transform = CGAffineTransformMakeScale((1 - self.scaleRatio) + ratio * self.scaleRatio, (1 - self.scaleRatio) + ratio * self.scaleRatio);
            break;
            
        case MXImageAnimationUp:
            self.currentImage.frame = CGRectMake(self.currentImage.frame.origin.x, -ratio * self.height, CGRectGetWidth(self.currentImage.frame), CGRectGetHeight(self.currentImage.frame));
            break;
            
        case MXImageAnimationDown:
            self.currentImage.frame = CGRectMake(self.currentImage.frame.origin.x, ratio * self.height, CGRectGetWidth(self.currentImage.frame), CGRectGetHeight(self.currentImage.frame));
            break;
            
        case MXImageAnimationBlur:
            self.currentImage.blurViewAlpha = ratio;
            self.preImage.blurViewAlpha = self.nextImage.blurViewAlpha = 1-ratio;
            break;
            
        default:
            break;
    }
}

#pragma mark getter
- (BOOL)scrollLeft {
    return self.lastX - (NSInteger)self.scrollView.contentOffset.x < 0;
}

- (CGFloat)x {
    return self.contentRect.origin.x;
}

- (CGFloat)y {
    return self.contentRect.origin.y;
}

- (CGFloat)width {
    return self.contentRect.size.width;
}

- (CGFloat)height {
    return self.contentRect.size.height;
}

#pragma mark setter
- (void)setShowText:(BOOL)showText {
    _showText = showText;
    self.pageControlView.showText = showText;
    if (showText) {
        self.pageControlView.firstText = self.imageModelArray.firstObject.imageText;
    }
}

- (void)setAnimationType:(MXImageAnimation)animationType {
    _animationType = animationType;
    [self resetThreeImages];
}

- (void)setDelay:(CGFloat)delay {
    _delay = delay > 0 ? delay : MXDefaultDelay;
}

- (void)setHidePageControl:(BOOL)hidePageControl {
    self.pageControlView.hidden = hidePageControl;
}

- (void)setScaleRatio:(CGFloat)scaleRatio {
    if (scaleRatio < 0) {
        _scaleRatio = 0;
    } else if (scaleRatio > 0.9) {
        _scaleRatio = 0.9;
    } else {
        _scaleRatio = scaleRatio;
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    self.pageControlView.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    self.pageControlView.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
