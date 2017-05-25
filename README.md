# MXScrollView
循环滚动视图
## 使用说明
* 添加文件
    * 将MXScrollViewHeader.h、MXScrollView.h、MXScrollView.m添加到项目中
* 添加代码
```objc
/*ViewController.m*/
#import "MXScrollView.h"
@interface ViewController ()<MXScrollViewDelegate>
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //数据源
    NSArray *imageUrls = @[@"http://a2.att.hudong.com/73/16/01300000165476121211162421024.jpg", @"http://pic8.nipic.com/20100808/4953913_162517044879_2.jpg",@"http://www.taopic.com/uploads/allimg/121214/267863-12121421114939.jpg"];
    //初始化（位置，数据源，自动滚动间隔）
    MXScrollView *mxScrollView = [[MXScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) withContents:imageUrls andScrollDelay:3.5];
    //方法一：设置代理并实现方法
    //mxScrollView.mxDelegate = self;
    //方法二：设置回调Block
    mxScrollView.clickHandler = ^(NSInteger index) {
        NSLog(@"图片index：%ld",index);
    };
    //添加视图
    [self.view addSubview:mxScrollView];
    //添加pageControl
    [self.view addSubview:mxScrollView.pageControl];
}

- (void)clickImageIndex:(NSInteger)index {
    NSLog(@"图片index：%ld",index);
}
@end
```
