//
//  SpeechBubbleYourCell.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/10/13.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "SpeechBubbleYourCell.h"

@implementation SpeechBubbleYourCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.messageLabel];
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, [UIScreen mainScreen].bounds.size.width - 50, 55)];
        _messageLabel.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1.f];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.font = [UIFont systemFontOfSize:17.0];
    }
    return _messageLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
