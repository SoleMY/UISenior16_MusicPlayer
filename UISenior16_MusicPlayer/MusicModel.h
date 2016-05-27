//
//  MusicModel.h
//  UISenior_16_MusicPlayer
//
//  Copyright © 2016年 PZS. All rights reserved.
//

#import <Foundation/Foundation.h>
// 用于处理音乐数据的model
@interface MusicModel : NSObject
/// 音乐的名字
@property (nonatomic, strong) NSString *musicName;
/// 音乐的类型
@property (nonatomic, strong) NSString *musicType;

/// 创建初始化方式
- (id)initWithMusicName:(NSString *)name
          withMusicType:(NSString *)type;

@end
