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
        self.control = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.control addTarget:self action:@selector(imageClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.control];
    }
    return self;
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
@property (assign, nonatomic) CGRect contentRect;
@property (assign, nonatomic) NSUInteger originalImageCount;
@property (assign, nonatomic) NSInteger imageCount;
//定时器，控制自动滚动广告
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL manual;
@property (strong, nonatomic) NSMutableArray *mImageArray;
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
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.delegate = self;
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.y+self.height-MXPageControlHeight, kScreenWidth, MXPageControlHeight)];
        self.pageControl.hidesForSinglePage = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withContents:(NSArray<NSString*>*)contents andScrollDelay:(CGFloat)delay {
    MXScrollView *view = [[MXScrollView alloc]initWithFrame:frame withScrollDelay:delay];
    view.mImageArray = [[NSMutableArray alloc] initWithArray:contents];
    [view initContents];
    return view;
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
    self.contentSize = CGSizeMake(self.width*self.mImageArray.count, self.height);
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
                if ([self.mxDelegate respondsToSelector:@selector(clickImageIndex:)]) {
                    [self.mxDelegate clickImageIndex:index];
                }
                if (self.clickHandler) {
                    self.clickHandler(index);
                }
            };
            [self addSubview:imageView];
        }
    }
}

- (void)setupTimer {
    if (self.mImageArray.count > 1 && self.delay > 0) {
        //设置好滚动视图，启动定时器
        if (!self.timer) {
            self.contentOffset = CGPointMake(self.width, 0);
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
    NSInteger page = 0;
    NSInteger x = self.contentOffset.x/self.width;
    page = x - 1;
    //显示最后一张，移动offset到最左边
    if (x == _imageCount - 2) {
        self.contentOffset = CGPointZero;
        x = 0;
        page = -1;
    }
    //滚动到下一页
    [UIView animateWithDuration:0.375 animations:^{
        self.contentOffset = CGPointMake((x+1)*self.width, 0);
    } completion:^(BOOL finished) {
        self.pageControl.currentPage = page + 1;
    }];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
