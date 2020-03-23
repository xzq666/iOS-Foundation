//
//  BaseViewController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/17.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame= CGRectMake(20, 40, 100, 40);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:close];
    [close addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
