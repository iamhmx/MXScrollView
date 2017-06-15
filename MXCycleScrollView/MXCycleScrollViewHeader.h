//
//  MXCycleScrollViewHeader.h
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#ifndef MXCycleScrollViewHeader_h
#define MXCycleScrollViewHeader_h

#ifndef kScreenWidth
#define kScreenWidth  ([[UIScreen mainScreen] bounds].size.width)
#endif

#ifndef kScreenHeight
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#endif

#define MXPageControlHeight 30
#define MXImageViewTagBase  100

#define MXDefaultDelay 3
#define MXAutoScrollDuration 0.5

#define MXWeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define MXStrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;


/**
 动画类型

 - MXImageAnimationNone: 默认无动画
 - MXImageAnimationFadeInOut: 渐变
 - MXImageAnimationRotation: 旋转
 - MXImageAnimationScale: 缩放
 - MXImageAnimationDown: 下降
 - MXImageAnimationUp: 上升
 - MXImageAnimationBlur: 毛玻璃
 */
typedef NS_ENUM(NSInteger, MXImageAnimation) {
    MXImageAnimationNone,
    MXImageAnimationFadeInOut,
    MXImageAnimationRotation,
    MXImageAnimationScale,
    MXImageAnimationUp,
    MXImageAnimationDown,
    MXImageAnimationBlur
};

#endif /* MXScrollViewHeader_h */
