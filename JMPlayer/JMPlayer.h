//
//  JMPlayer.h
//  JMPlayer
//
//  Created by 123 on 2018/10/4.
//  Copyright © 2018年 seven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface JMPlayer : NSObject

+ (instancetype)shareInstance;

- (void)playWithURL:(NSURL *)url;

/**
 *  连续播放多个资源
 *  param:
 *  mediaArray格式：URL1，URL2……
 */
- (void)playWithURLArr:(NSArray *)mediaURLArray;

@end
