//
//  XZQSpeechDemo.h
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/10/13.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZQSpeechDemo : UIViewController

@property(nonatomic,strong,readonly) AVSpeechSynthesizer *synthesizer;

+ (instancetype)speechDemo;

/**
 立即开启文本转语音功能
 */
- (void)beginConversation;

@end

NS_ASSUME_NONNULL_END
