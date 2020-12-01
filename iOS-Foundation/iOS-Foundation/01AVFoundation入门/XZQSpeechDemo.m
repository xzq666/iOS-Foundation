//
//  XZQSpeechDemo.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/10/13.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQSpeechDemo.h"

@interface XZQSpeechDemo ()

// 重新定义AVSpeechSynthesizer，使其在内部可以支持读写操作
@property(nonatomic,strong) AVSpeechSynthesizer *synthesizer;
@property(nonatomic,strong) NSArray *voices;
@property(nonatomic,strong) NSArray *speechStrings;

@end

@implementation XZQSpeechDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (instancetype)speechDemo {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
        _speechStrings = @[@"Hello AVFoundation. How are you?",
                           @"I'm well! Thanks for asking.",
                           @"Are you excited about the book?",
                           @"Very! I have always felt so misunderstood.",
                           @"What's your favorite feature?",
                           @"Oh, they're all my babies. I coundn't possibly choose.",
                           @"It was great to speak with you!",
                           @"The pleasure was all mine! Have fun!",
                           ];
    }
    return self;
}

- (void)beginConversation {
    for (int i = 0; i < self.speechStrings.count; i++) {
        @autoreleasepool {
            // 语音内容
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.speechStrings[i]];
            utterance.voice = self.voices[i % 2];
            utterance.rate = 0.4f;  // 语音播放速率
            utterance.pitchMultiplier = 0.8f;  // 声音音调 一般介于0.5(低音调)和2.0(高音调)之间
            utterance.postUtteranceDelay = 0.1f;
            [self.synthesizer speakUtterance:utterance];
        }
    }
}

@end
