# MXScrollView
循环滚动视图(支持点击事件、自动滚动、多种动画)
## 效果示例
* 无动画<br>
   ![无动画](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/none.gif)
   <br>

* 渐变<br>
   ![渐变](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/fade.gif)
   <br>

* 旋转<br>
   ![旋转](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/rotate.gif)
   <br>
   
* 缩放<br>
   ![缩放](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/scale.gif)
   <br>
   
* 上升<br>
   ![上升](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/up.gif)
   <br>
   
* 下降<br>
   ![下降](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/down.gif)
   <br>
   
* 毛玻璃<br>
   ![毛玻璃](https://github.com/iamhmx/MXScrollView/blob/master/MXScrollViewDemo/screenshots/blur.gif)
   <br>   
## 使用说明
* 添加文件
    * 将MXScrollViewHeader.h、MXScrollView.h、MXScrollView.m添加到项目中
* 添加代码
```objc
/*ViewController.m*/
#import "MXScrollView.h"

@interface ViewController ()<MXScrollViewDelegate>
//图片数据
@property (strong, nonatomic) NSArray *imageUrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*初始化一：已知图片数据*/
    MXScrollView *mxScrollView = [[MXScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) withContents:self.imageUrls andScrollDelay:3.5];

    /*初始化二：不知图片数据，数据由网络请求而来，更常见*/
    /*MXScrollView *mxScrollView = [[MXScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) withScrollDelay:3.5];
    //请求到数据，设置图片
    [self requestDataFromNet:^(id data) {
        [mxScrollView setContents:data];
    }];*/

    //设置动画类型
    //渐变
    //mxScrollView.animationType = MXImageAnimationFadeInOut;
    
    //旋转
    mxScrollView.animationType = MXImageAnimationRotation;
    
    //缩放
    //mxScrollView.animationType = MXImageAnimationScale;
    //mxScrollView.scaleRatio = 0.5;
    
    //mxScrollView.animationType = MXImageAnimationUp;
    
    //mxScrollView.animationType = MXImageAnimationDown;
    
    mxScrollView.animationType = MXImageAnimationBlur;
    
    //方法一：设置代理并实现方法
    //mxScrollView.delegate = self;
    
    //方法二：设置回调Block
    mxScrollView.clickHandler = ^(NSInteger index) {
        NSLog(@"图片index：%ld",index);
    };
    
    [self.view addSubview:mxScrollView];
}

- (void)clickImageIndex:(NSInteger)index {
    NSLog(@"图片index：%ld",index);
}

- (NSArray *)imageUrls {
    return @[@"http://a2.att.hudong.com/73/16/01300000165476121211162421024.jpg", @"http://pic8.nipic.com/20100808/4953913_162517044879_2.jpg",@"http://www.taopic.com/uploads/allimg/121214/267863-12121421114939.jpg"];
}

@end
```
