//
//  MXScrollViewHeader.h
//  MXScrollViewDemo
//
//  Created by msxf on 2017/5/24.
//  Copyright © 2017年 yellow. All rights reserved.
//

#ifndef MXScrollViewHeader_h
#define MXScrollViewHeader_h

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

#endif /* MXScrollViewHeader_h */
