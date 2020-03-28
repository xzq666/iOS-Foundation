//
//  XZQPhotoVideoCaptureController.h
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/26.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XZQVideoCaptureDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

@interface XZQPhotoVideoCaptureController : UIViewController

@property(nonatomic,weak) id<XZQVideoCaptureDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
