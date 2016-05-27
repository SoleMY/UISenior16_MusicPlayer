//
//  MusicDataManager.m
//  UISenior_16_MusicPlayer
//
//  Copyright © 2016年 PZS. All rights reserved.
//

#import "MusicDataManager.h"
static MusicDataManager *manager = nil;
@implementation MusicDataManager

+ (instancetype)shareInstence
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MusicDataManager alloc] init];
        // 数组初始化
        manager.musicArray = [NSMutableArray array];
    });
    return manager;
}

@end
