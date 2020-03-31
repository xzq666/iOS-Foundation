//
//  ViewController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/16.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "ViewController.h"
#import "XZQSpeechViewController.h"
#import "XZQPlayAndRecordViewController.h"
#import "XZQLibraryAndMetaDataViewController.h"
#import "XZQVideoPlayerController.h"
#import "XZQAVkitController.h"
#import "XZQVideoCaptureController.h"
#import "XZQScanController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *titleArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleArr = @[@"01 AVFoundation入门",
                      @"02 AVFoundation播放和录制视频",
                      @"03 AVFoundation资源和元数据",
                      @"04 AVFoundation视频播放",
                      @"05 AVKit用法",
                      @"06 AVFoundation捕捉媒体",
                      @"07 AVFoundation机器码识别"];
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            XZQSpeechViewController *speech = [[XZQSpeechViewController alloc]init];
            speech.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:speech animated:YES completion:^{
                
            }];
            break;
        }
            
        case 1: {
            XZQPlayAndRecordViewController *playAndRecord = [[XZQPlayAndRecordViewController alloc] init];
            playAndRecord.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:playAndRecord animated:YES completion:^{
                
            }];
            break;
        }
            
        case 2: {
            XZQLibraryAndMetaDataViewController *libraryAndMetaData = [[XZQLibraryAndMetaDataViewController alloc] init];
            libraryAndMetaData.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:libraryAndMetaData animated:YES completion:^{
                
            }];
            break;
        }
            
        case 3: {
            XZQVideoPlayerController *videoPlayer = [[XZQVideoPlayerController alloc] init];
            videoPlayer.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:videoPlayer animated:YES completion:^{
                
            }];
            break;
        }
            
        case 4: {
            XZQAVkitController *avKit = [[XZQAVkitController alloc] init];
            avKit.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:avKit animated:YES completion:^{
                
            }];
            break;
        }
            
        case 5: {
            XZQVideoCaptureController *videoCapture = [[XZQVideoCaptureController alloc] init];
            videoCapture.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:videoCapture animated:YES completion:^{
                
            }];
            break;
        }
            
        case 6: {
            XZQScanController *scan = [[XZQScanController alloc] init];
            scan.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:scan animated:YES completion:^{
                
            }];
            break;
        }
            
        default:
            break;
    }
}
@end
