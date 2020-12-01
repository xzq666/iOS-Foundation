//
//  XZQSpeechDemoController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/10/13.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQSpeechDemoController.h"
#import "SpeechBubbleMyCell.h"
#import "SpeechBubbleYourCell.h"
#import "XZQSpeechDemo.h"
#import <AVFoundation/AVFoundation.h>

@interface XZQSpeechDemoController ()<AVSpeechSynthesizerDelegate>

@property(nonatomic,strong) XZQSpeechDemo *speechDemo;
@property(nonatomic,strong) NSMutableArray *speechStrings;

@end

@implementation XZQSpeechDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView registerClass:[SpeechBubbleMyCell class] forCellReuseIdentifier:@"myCell"];
    [self.tableView registerClass:[SpeechBubbleYourCell class] forCellReuseIdentifier:@"yourCell"];
    self.speechDemo = [XZQSpeechDemo speechDemo];
    self.speechDemo.synthesizer.delegate = self;
    self.speechStrings = [NSMutableArray array];
    [self.speechDemo beginConversation];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.speechStrings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = indexPath.row % 2 == 0 ? @"myCell" : @"yourCell";
    if (indexPath.row % 2 == 0) {
        SpeechBubbleMyCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.messageLabel.text = self.speechStrings[indexPath.row];
        return cell;
    } else {
        SpeechBubbleYourCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.messageLabel.text = self.speechStrings[indexPath.row];
        return cell;
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    [self.speechStrings addObject:utterance.speechString];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.speechStrings.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
