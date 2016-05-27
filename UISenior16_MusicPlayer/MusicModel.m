//
//  MusicModel.m
//  UISenior_16_MusicPlayer
//
//  Copyright © 2016年 PZS. All rights reserved.
//

#import "MusicModel.h"

@implementation MusicModel

- (id)initWithMusicName:(NSString *)name withMusicType:(NSString *)type
{
    self = [super init];
    if (self) {
        self.musicName = name;
        self.musicType = type;
    }
    return self;
}

@end
