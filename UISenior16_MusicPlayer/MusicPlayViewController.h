//
//  MusicPlayViewController.h
//  UISenior_16_MusicPlayer
//
//  Copyright © 2016年 PZS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayViewController : UIViewController

/// 背景图片
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
/// 控制音量的Slider
@property (weak, nonatomic) IBOutlet UISlider *voiceSlider;
/// 控制进度的Slider
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
/// 播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/// 下一首按钮
@property (weak, nonatomic) IBOutlet UIButton *nextMusicButton;
/// 上一首按钮
@property (weak, nonatomic) IBOutlet UIButton *aboveMusicButton;
/// 歌词tableView
@property (weak, nonatomic) IBOutlet UITableView *showLyricsTableView;
/// 开始时间
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
/// 结束时间
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
/// 记录播放的是哪首歌
@property (nonatomic, assign) NSInteger playIndex;


@end
