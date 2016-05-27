//
//  MusicDataManager.h
//  UISenior_16_MusicPlayer
//
//  Copyright © 2016年 PZS. All rights reserved.
//

#import <Foundation/Foundation.h>
// 音乐的数据管理类，主要用来实现数组的相关操作
@interface MusicDataManager : NSObject
/// 存储音乐的数组
@property (nonatomic, strong) NSMutableArray *musicArray;

// 单例
+ (instancetype)shareInstence;


@end
