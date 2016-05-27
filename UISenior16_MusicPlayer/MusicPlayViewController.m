//
//  MusicPlayViewController.m
//  UISenior_16_MusicPlayer
//
//  Copyright © 2016年 PZS. All rights reserved.
//

#import "MusicPlayViewController.h"
// 第一步引入系统类库
#import <AVFoundation/AVFoundation.h>
#import "MusicModel.h"
#import "MusicDataManager.h"
@interface MusicPlayViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    // 进行音乐播放
    AVAudioPlayer *audioPlayer;
    // 判断是否正在播放
    BOOL isPlay;
}
// 存储时间的数组
@property (nonatomic, strong) NSMutableArray *timeArray;
// 歌词的字典
@property (nonatomic, strong) NSMutableDictionary *lyricDict;


@end

@implementation MusicPlayViewController
- (NSMutableArray *)timeArray {
    if (!_timeArray) {
        _timeArray = [NSMutableArray array];
    }
    return _timeArray;
}
- (NSMutableDictionary *)lyricDict {
    if (!_lyricDict) {
        _lyricDict = [NSMutableDictionary dictionary];
    }
    return _lyricDict;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    MusicModel *model = [MusicDataManager shareInstence].musicArray[self.playIndex];
//    self.title = model.musicName;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 注册cell
    [self.showLyricsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.showLyricsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 具体播放哪首歌曲，需要上个界面传过来
    // 获取当前音乐的model类
    MusicModel *model = [MusicDataManager shareInstence].musicArray[self.playIndex];
    // 初始化音乐播放器对象
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:model.musicName ofType:model.musicType]] error:nil];
    // 音量的设置
    self.voiceSlider.minimumValue = 0;
    self.voiceSlider.maximumValue = 1;
    // 设置播放器默认音量
    audioPlayer.volume = 0.1;
    self.voiceSlider.value = audioPlayer.volume;
    // 设置音量按钮的图片
    [self.voiceSlider setThumbImage:[UIImage imageNamed:@"soundSlider"] forState:UIControlStateNormal];
    [self.voiceSlider setThumbImage:[UIImage imageNamed:@"soundSlider"] forState:UIControlStateHighlighted];
    // 添加滑动事件
    [self.voiceSlider addTarget:self action:@selector(changeVolumeAction) forControlEvents:UIControlEventValueChanged];
    // 设置进度按钮的图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateHighlighted];
    // 获取歌词
    [self getLyrics];
    // 设置歌词的代理
    self.showLyricsTableView.delegate = self;
    self.showLyricsTableView.dataSource = self;
    
    
    
    
}
// 控制音量
- (void)changeVolumeAction {
    audioPlayer.volume = self.voiceSlider.value;
}
// 控制进度
- (IBAction)progressChange:(id)sender {
    audioPlayer.currentTime = self.progressSlider.value * audioPlayer.duration;
}
#pragma mark - 动态显示歌词
- (void)showTime {
    // 刷新进度条的数据
    if ((int)audioPlayer.currentTime % 60 < 10) {
        self.startTimeLabel.text = [NSString stringWithFormat:@"%d:0%d", (int)audioPlayer.currentTime / 60, (int)audioPlayer.currentTime % 60];
    } else {
        self.startTimeLabel.text = [NSString stringWithFormat:@"%d:%d", (int)audioPlayer.currentTime / 60, (int)audioPlayer.currentTime % 60];
    }
    if ((int)audioPlayer.duration % 60 < 10 ) {
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d:0%d", (int)audioPlayer.duration / 60, (int)audioPlayer.duration % 60];
    } else {
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d:%d", (int)audioPlayer.duration / 60, (int)audioPlayer.duration % 60];
    }
    self.progressSlider.value = audioPlayer.currentTime / audioPlayer.duration;
    // 动态显示歌词
    [self disPlaySoundWord:audioPlayer.currentTime];
    // 在播放完毕之后，自动播放下一首
    if (self.progressSlider.value > 0.999) {
        // 自动播放
        [self autoPlay];
    }
}
#pragma mark - 自动播放
- (void)autoPlay {
    
    self.progressSlider.value = 0;
    if (self.playIndex == [MusicDataManager shareInstence].musicArray.count - 1) {
        self.playIndex = -1;
    }
    self.playIndex++;
    NSLog(@"playIndex = %ld", self.playIndex);
    // 更新播放器
    [self updatePlayerSetting];
    
}
#pragma mark - 动态显示歌词
- (void)disPlaySoundWord:(NSInteger)time {
    for (int i = 0; i < self.timeArray.count; i++) {
        NSArray *array = [self.timeArray[i] componentsSeparatedByString:@":"];
        // 把数组中存在的时间转化成秒
        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
        // 求出最后一句歌词的时间点
        if (i == self.timeArray.count - 1) {
            NSArray *array1 = [self.timeArray[self.timeArray.count - 1] componentsSeparatedByString:@":"];
            NSUInteger finalTime = [array1[0] intValue] * 60 + [array1[1] intValue];
            if (time > finalTime) {
                [self updateLrcTableView:i];
                break;
            }
        } else {
            // 求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [self.timeArray[0] componentsSeparatedByString:@":"];
            NSUInteger firstTime = [array2[0] intValue] * 60 + [array2[1] intValue];
            if (time < firstTime) {
                [self updateLrcTableView:0];
                break;
            }
            NSArray *array3 = [self.timeArray[i + 1] componentsSeparatedByString:@":"];
            NSUInteger currentTime1 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime && time <= currentTime1) {
                // 动态更新歌词表中的歌词
                [self updateLrcTableView:i];
                break;
            }
        }
    }
}
#pragma mark - 动态更新歌词表歌词
- (void)updateLrcTableView:(NSUInteger)index {
    // 重新加载tableView
    [self.showLyricsTableView reloadData];
    
    // 是被选中的行移到中间
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UITableViewCell *cell = [self.showLyricsTableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [UIColor colorWithRed:35 / 255.0 green:190 / 255.0 blue:85 / 255.0 alpha:1];
    [self.showLyricsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}
#pragma mark - 获取歌词
- (void)getLyrics {
    
    // 获取音乐对象
    MusicModel *model = [[MusicDataManager shareInstence].musicArray objectAtIndex:self.playIndex];
    self.title = model.musicName;
    self.backGroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", model.musicName]];
    NSString *lyricsPath = [[NSBundle mainBundle] pathForResource:model.musicName ofType:@"lrc"];
    
    // 编码
    NSString *lyricsUTF8 = [NSString stringWithContentsOfFile:lyricsPath encoding:NSUTF8StringEncoding error:nil];
    // 分割字符串(以\n分割)
    NSMutableArray *array = [lyricsUTF8 componentsSeparatedByString:@"\n"].mutableCopy;
    
    for (int i = 0; i < array.count; i++) {
        // 获取每一行的内容
        NSString *lineStr = array[i];
        NSArray *lineArray = [lineStr componentsSeparatedByString:@"]"];
        
        // 如果长度大于8的时候才进行歌词的操作
        if (lineArray.count > 1) {
            if ([lineArray[1] length] > 1) {
                NSString *str = [lineArray[0] substringWithRange:NSMakeRange(1, 5)];
                [self.timeArray addObject:str];
                [self.lyricDict setObject:lineArray[1] forKey:str];
//                NSLog(@"lineArray0 = %@, lineArray1 = %@", str, lineArray[1]);
            }
        }
    }
    
//    NSLog(@"time = %ld, %@, dict = %ld, %@", self.timeArray.count, self.timeArray[10], self.lyricDict.count,[self.lyricDict objectForKey:self.timeArray[10]]);
    [self.showLyricsTableView reloadData];
    
}
// 播放按钮响应方法
- (IBAction)playButtonAction:(id)sender {
    
    // 判断是否正在播放，然后修改相关内容
    if (!isPlay) {
        [audioPlayer play];
        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        // 设置定时器，0.1秒之后刷新，播放时间的刷新，如果本首歌曲播放完毕，是否进入下一首
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
        isPlay = YES;
    }else {
        [audioPlayer pause];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        isPlay = NO;
    }
    
}
// 上一首按钮响应方法
- (IBAction)aboveMusicButtonAction:(id)sender {
    self.progressSlider.value = 0;
    if (self.playIndex == 0) {
        self.playIndex = [MusicDataManager shareInstence].musicArray.count;
    }
    self.playIndex--;
    // 更新播放器
    [self updatePlayerSetting];
}
#pragma mark - 更新播放器
- (void)updatePlayerSetting {
    // 更改播放按钮状态
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    isPlay = YES;
    // 获取播放的音乐对象
    MusicModel *model = [[MusicDataManager shareInstence].musicArray objectAtIndex:self.playIndex];
    // 更新曲目
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:model.musicName ofType:model.musicType]] error:nil];
    // 音量重新设置
    audioPlayer.volume = self.voiceSlider.value;
    // 歌词更新
    self.timeArray = [NSMutableArray array];
    self.lyricDict = [NSMutableDictionary dictionary];
    // 获取歌词
    [self getLyrics];
    // 播放
    [audioPlayer play];
}
// 下一首按钮响应方法
- (IBAction)nextMusicButtonAction:(id)sender {
    self.progressSlider.value = 0;
    if (self.playIndex == [MusicDataManager shareInstence].musicArray.count - 1) {
        self.playIndex = -1;
    }
    self.playIndex++;
    // 更新播放器
    [self updatePlayerSetting];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [self.lyricDict objectForKey:self.timeArray[indexPath.row]];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
