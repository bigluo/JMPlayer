//
//  JMPlayer.m
//  JMPlayer
//
//  Created by 123 on 2018/10/4.
//  Copyright © 2018年 seven. All rights reserved.
//

#import "JMPlayer.h"
@interface JMPlayer()

/*
 * AVAudioPlayer播放本地音乐文件,AVPlayer既可以播放本地音频文件，也可以播放在线音频。
 */
//@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) AVPlayer *player;
/**
 * 播放多个资源播放器
 */
@property (nonatomic, strong) AVQueuePlayer * queuePlayer;

@property (nonatomic, strong) NSURL *mediaURL;

@property (nonatomic, strong) AVPlayerItem *mediaItem;

@property (nonatomic, strong) id timeObserve;
@end

@implementation JMPlayer
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static JMPlayer *player = nil;
    dispatch_once(&onceToken, ^{
        player = [[JMPlayer alloc]init];
    });
    return player;
}

- (void)playWithURL:(NSURL *)url{
    if (!url) {
        NSLog(@"url empty");
        return;
    }
    
    self.mediaItem = [[AVPlayerItem alloc]initWithURL:url];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    /**监听改播放器状态*/
    [self.mediaItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    /**添加数据缓冲状态监听*/
    [self.mediaItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinishedCallBack:) name:AVPlayerItemDidPlayToEndTimeNotification object:_mediaItem];
    
    if (!self.player) {
        self.player = [[AVPlayer alloc] initWithPlayerItem:_mediaItem];
    }else{
        [self.player replaceCurrentItemWithPlayerItem:_mediaItem];
    }
   
    
}


- (void)playFinishedCallBack:(NSNotification *)notice {
     NSLog(@"播放结束");
    [self removeTimeObserver];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playWithURLArr:(NSArray *)mediaURLArray{
    if (!mediaURLArray || mediaURLArray.count == 0) {
        NSLog(@"url empty");
        return;
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSURL *url in mediaURLArray) {
        if ([[[AVPlayerItem alloc]initWithURL:url] isKindOfClass:[NSURL class]]) {
            [tempArray addObject:[[AVPlayerItem alloc]initWithURL:url]];
        }else{
            NSLog(@"传入mediaURLArray 格式错误");
            return;
        }
    }
    self.queuePlayer = [[AVQueuePlayer alloc]initWithItems:tempArray];
}

- (void)addTimeObserver{
    __weak typeof(JMPlayer *)weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                     queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                                        
                                        float current = CMTimeGetSeconds(time);
                                        float total = CMTimeGetSeconds(weakSelf.mediaItem.duration);
                                         
                                        if (current) {
                                           float progress = current / total;
                                            NSLog(@"total:%f,current:%f,progress:%f",total,current,progress);
                                        }
                                     
                        }];
}

- (void)removeTimeObserver{
    if (self.timeObserve) {
        [self.player removeTimeObserver:_timeObserve];
        self.timeObserve = nil;
    }
}

- (void)play{
    [self.player play];
}

- (void)pause{
    [self.player pause];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status)
        {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}


@end
