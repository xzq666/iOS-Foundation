//
//  XZQSpeechViewController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/16.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQSpeechViewController.h"

@interface XZQSpeechViewController ()

// 执行具体的”文本到语音“会话。
// 对于一个或多个AVSpeechUtterance实例，该对象起到队列的作用，提供了接口供控制和监视正在进行的语音播放。
@property(nonatomic,strong) AVSpeechSynthesizer *synthesizer;
@property(nonatomic,strong) NSArray *voiceArray;
@property(nonatomic,strong) NSArray *speechStringsArray;

@end

@implementation XZQSpeechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    // AVSpeechSynthesisVoice设置语音支持
    // 通过[AVSpeechSynthesisVoice speechVoices]可以获取所有支持的语音类型
    self.voiceArray = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"],];
    self.speechStringsArray = @[@"Hello,How are you ?",
                                @"I'm fine ,Thank you. And you ?",
                                @"I'm fine too.",
                                @"人之初，性本善。性相近，习相远。苟不教，性乃迁。教之道，贵以专。昔孟母，择邻处。子不学，断机杼。窦燕山，有义方。教五子，名俱扬。养不教，父之过。教不严，师之惰。子不学，非所宜。幼不学，老何为。玉不琢，不成器。人不学，不知义。为人子，方少时。亲师友，习礼仪。香九龄，能温席。孝于亲，所当执。融四岁，能让梨。弟于长，宜先知。"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame= CGRectMake(50, 100, 100, 40);
    [btn setTitle:@"文本到语音" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick {
    for (int i = 0; i < self.speechStringsArray.count; i++) {
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.speechStringsArray[i]];
        // 语音
        utterance.voice = self.voiceArray[i%2];
        // 播放语音内容的速率，默认值AVSpeechUtteranceDefaultSpeechRate=0.5
        // 这个值介于AVSpeechUtteranceMinimumSpeechRate和AVSpeechUtteranceMaximumSpeechRate之间(目前是0.0-1.0)
        utterance.rate = 0.4f;
        NSLog(@"min:%f-max:%f-default:%f", AVSpeechUtteranceMinimumSpeechRate, AVSpeechUtteranceMaximumSpeechRate, AVSpeechUtteranceDefaultSpeechRate);
        // 在播放特定语句时改变声音的音调，允许值介于0.5-2.0之间
        utterance.pitchMultiplier = 0.8f;
        // 语音合成器在播放下一语句之前有段时间的暂停
        utterance.postUtteranceDelay = 0.1f;
        [self.synthesizer speakUtterance:utterance];
    }
}

@end
