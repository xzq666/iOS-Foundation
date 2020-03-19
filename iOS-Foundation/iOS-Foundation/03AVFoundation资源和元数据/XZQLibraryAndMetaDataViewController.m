//
//  XZQLibraryAndMetaDataViewController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/19.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQLibraryAndMetaDataViewController.h"
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>

@interface XZQLibraryAndMetaDataViewController ()

@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

@end

@implementation XZQLibraryAndMetaDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self asserts];
    
    [self ipod];
    
//    [self asynchronouslyLoad];
    
    [self useMetaData];
}

// 访问系统照片库
- (void)asserts {
    //遍历相册，获取对应相册的changeRequest
    PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
        [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //获取相册的照片
                NSLog(@"-->%@, -->%lu", obj, (unsigned long)idx);
            } completionHandler:^(BOOL success, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }];
    }];
}

// 访问iPod库
- (void)ipod {
    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:@"刘德华" forProperty:MPMediaItemPropertyArtist];
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:@"把故事写成我们" forProperty:MPMediaItemPropertyArtist];
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:artistPredicate];
    [query addFilterPredicate:albumPredicate];
    NSArray *results = [query items];
    NSLog(@"-->%lu", (unsigned long)results.count);
    if (results.count > 0) {
        MPMediaItem *item = results[0];
        NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
        AVAsset *asset = [AVAsset assetWithURL:assetURL];
        NSLog(@"-->%@", asset);
    }
}

// 异步载入
- (void)asynchronouslyLoad {
    NSURL *assetUrl = [[NSBundle mainBundle] URLForResource:@"把故事写成我们" withExtension:@"mp3"];
    AVAsset *asset = [AVAsset assetWithURL:assetUrl];
    NSArray *keys = @[@"tracks"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        switch (status) {
            case AVKeyValueStatusLoaded:
                //已经加载，继续处理
                NSLog(@"loaded");
                NSLog(@"%@", asset.tracks);
                self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetUrl error:nil];
                if (self.audioPlayer) {
                    [self.audioPlayer prepareToPlay];
                    [self.audioPlayer play];
                }
                break;
                
            case AVKeyValueStatusFailed:
                NSLog(@"failure");
                break;
                
            case AVKeyValueStatusCancelled:
                NSLog(@"canceld");
                break;
                
            case AVKeyValueStatusUnknown:
                NSLog(@"unknown");
                break;
                
            default:
                NSLog(@"default");
                break;
        }
    }];
}

// 使用元数据
- (void)useMetaData {
    NSURL *assetUrl = [[NSBundle mainBundle] URLForResource:@"把故事写成我们" withExtension:@"mp3"];
    AVAsset *asset = [AVAsset assetWithURL:assetUrl];
    // 返回资源中包含的所有元数据格式
    for (AVMetadataFormat item in [asset availableMetadataFormats]) {
        // 访问指定格式的元数据格式，返回一个包含所有相关元数据信息的NSArray
        NSArray *medata = [asset metadataForFormat:item];
        for (AVMetadataItem *mitem in medata) {
            NSLog(@"%@:%@", mitem.key, mitem.value);
        }
    }
}

@end
