//
//  MXScrollView.m
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import "MXScrollView.h"
#import "MXScrollViewHeader.h"
#import "UIImageView+WebCache.h"

typedef void(^MXClickHandler)(NSInteger index);

@interface MXImageView : UIView
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIControl *control;
@property (assign, nonatomic) NSInteger actionTag;
@property (copy, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImage *placeholder;
@property (copy, nonatomic) MXClickHandler handler;
@property (strong, nonatomic) UIView *coverView;
@property (assign, nonatomic) BOOL hideCover;
@property (assign, nonatomic) CGFloat coverViewAlpha;
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
        
        self.coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.coverView.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.9];
        self.coverView.alpha = 0;
        [self.imageView addSubview:self.coverView];
        
        self.control = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.control addTarget:self action:@selector(imageClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.control];
        
    }
    return self;
}

- (void)setHideCover:(BOOL)hideCover {
    self.coverView.alpha = hideCover?0:1;
}

- (void)setCoverViewAlpha:(CGFloat)coverViewAlpha {
    self.coverView.alpha = coverViewAlpha;
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

@interface MXScrollView ()<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) CGRect contentRect;
@property (assign, nonatomic) NSUInteger originalImageCount;
@property (assign, nonatomic) NSInteger imageCount;
//定时器，控制自动滚动广告
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL manual;
@property (strong, nonatomic) NSMutableArray *mImageArray;
@property (strong, nonatomic) NSMutableArray *imageViewArray;
@property (strong, nonatomic) MXImageView *currentImage;
@property (strong, nonatomic) MXImageView *preImage;
@property (strong, nonatomic) MXImageView *nextImage;
//上一次scrollView的偏移量
@property (assign, nonatomic) NSInteger lastX;

//基于父视图坐标
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@end

@implementation MXScrollView

- (instancetype)initWithFrame:(CGRect)frame withScrollDelay:(CGFloat)delay {
    if (self = [super initWithFrame:frame]) {
        self.contentRect = frame;
        self.delay = delay;
        [self setupScrollView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<NSString*>*)contents andScrollDelay:(CGFloat)delay {
    MXScrollView *view = [[MXScrollView alloc]initWithFrame:frame withScrollDelay:delay];
    view.mImageArray = [[NSMutableArray alloc] initWithArray:contents];
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
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.height-MXPageControlHeight, kScreenWidth, MXPageControlHeight)];
    self.pageControl.hidesForSinglePage = YES;
    [self addSubview:self.pageControl];
}

- (void)setContents:(NSArray <NSString*>*)contents {
    self.mImageArray = [[NSMutableArray alloc]initWithArray:contents];
    [self initContents];
}

- (void)initContents {
    [self initData];
    [self clearViewsTagAbove:MXImageViewTagBase];
    [self setupImageViews];
    [self setupTimer];
}

- (void)initData {
    self.pageControl.numberOfPages = self.mImageArray.count;
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
        if (self.fadeInOutAnimation) {
            //自动滚动只需要考虑当前页和下一页
            self.currentImage.hideCover = NO;
            self.nextImage.hideCover = YES;
        }
    } completion:^(BOOL finished) {
        @MXStrongObj(self);
        self.pageControl.currentPage = page + 1;
        //衔接自动滚动后手动滑动
        self.lastX = self.scrollView.contentOffset.x;
        [self resetThreeImages];
    }];
}

- (void)resetThreeImages {
    NSInteger offX = self.scrollView.contentOffset.x/self.width;
    /*if (offX == 0) {
     if (!self.manual) {
     //如果是自动滚动，显示最后一张图片时会设置contentOffset为0，所以offX为0只有下面一种情况
     self.currentImage = self.imageViewArray[0];
     self.nextImage = self.imageViewArray[1];
     } else {
     self.currentImage = self.imageViewArray[_imageCount-2];
     self.preImage = self.imageViewArray[_imageCount-3];
     self.nextImage = self.imageViewArray[_imageCount-1];
     }
     } else if (offX == _imageCount-1) {
     self.currentImage = self.imageViewArray[1];
     self.preImage = self.imageViewArray[0];
     self.nextImage = self.imageViewArray[2];
     } else {
     self.currentImage = self.imageViewArray[offX];
     self.preImage = self.imageViewArray[offX-1];
     self.nextImage = self.imageViewArray[offX+1];
     }*/
    if (self.imageViewArray.count > 2) {
        self.currentImage = self.imageViewArray[offX];
        if (offX > 0) {
            self.preImage = self.imageViewArray[offX-1];
        }
        self.nextImage = self.imageViewArray[offX+1];
        if (self.fadeInOutAnimation) {
            self.preImage.hideCover = self.nextImage.hideCover = NO;
            self.currentImage.hideCover = YES;
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
    self.pageControl.currentPage = page;
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
    NSLog(@"last = %ld, offset = %ld", self.lastX, (NSInteger)scrollView.contentOffset.x);
    //相对于上次contentOffset.x的滚动距离（0~self.width）
    NSInteger scrollDistance = labs(self.lastX - (NSInteger)scrollView.contentOffset.x);
    scrollDistance = MIN(scrollDistance, self.width);
    NSLog(@"scrollDistance = %ld",scrollDistance);
    
    CGFloat alpha = scrollDistance / self.width;
    NSLog(@"alpha = %.1f",alpha);
    if (self.fadeInOutAnimation) {
        self.currentImage.coverViewAlpha = alpha;
        self.preImage.coverViewAlpha = self.nextImage.coverViewAlpha = 1-alpha;
    }
}

#pragma mark getter
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
- (void)setDelay:(CGFloat)delay {
    _delay = delay > 0 ? delay : MXDefaultDelay;
}

- (void)setHidePageControl:(BOOL)hidePageControl {
    self.pageControl.hidden = hidePageControl;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
