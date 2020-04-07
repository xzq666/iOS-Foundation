//
//  XZQWaveformView.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/7.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQWaveformView.h"
#import "CreateAudioWaveformUtil.h"
#import "CreateAudioWaveformFilter.h"

@interface XZQWaveformView ()

@property(nonatomic,strong) AVAsset *asset;
@property(nonatomic,strong) CreateAudioWaveformFilter *filter;

@property(nonatomic,strong) UIColor *waveColor;
@property(nonatomic,strong) UIActivityIndicatorView *loadingView;

@end

@implementation XZQWaveformView

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setAsset:asset];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor lightGrayColor];
    [self setBgColor:[UIColor whiteColor]];
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    
    CGSize size = self.loadingView.frame.size;
    CGFloat x = (self.bounds.size.width - size.width) / 2;
    CGFloat y = (self.bounds.size.height - size.height) / 2;
    self.loadingView.frame = CGRectMake(x, y, size.width, size.height);
    [self addSubview:self.loadingView];
    
    [self.loadingView startAnimating];
}

// 设置波形颜色
- (void)setBgColor:(UIColor *)waveColor {
    self.waveColor = waveColor;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = waveColor.CGColor;
    [self setNeedsDisplay];
}

// 设置AVAsset
- (void)setAsset:(AVAsset *)asset {
    [CreateAudioWaveformUtil loadAudioSamplesFromAsset:asset completionBlock:^(NSData *sampleData) {
        self.filter = [[CreateAudioWaveformFilter alloc] initWithData:sampleData];
        [self.loadingView stopAnimating];
        [self setNeedsDisplay];
    }];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 在视图内呈现这个波形，首先基于定义的宽和高常量来缩放图像上下文
    // 坐标系X、Y缩放
    CGContextScaleCTM(context, 0.8, 0.8);
    
    // 计算x、y偏移量，转换上下文，在缩放上下文中适当调整便宜
    CGFloat offsetX = self.bounds.size.width - self.bounds.size.width * 0.8;
    CGFloat offsetY = self.bounds.size.height - self.bounds.size.height * 0.8;
    // 坐标系平移
    CGContextTranslateCTM(context, offsetX / 2, offsetY / 2);
    
    // 获取筛选样本，并传递视图边界的尺寸
    // 实际可能希望在drawRect方法之外执行这一检索操作，这样在筛选样本时会有更好的优化效果
    NSArray *filterSamples = [self.filter filterSamplesForSize:self.bounds.size];
    
    CGFloat midY = CGRectGetMidY(rect);
    
    // 创建一个新的CGMutablePathRef，用来绘制波形Bezier路径的上半部
    CGMutablePathRef halfPath = CGPathCreateMutable();
    // 将路径移动到一个点作为起点
    CGPathMoveToPoint(halfPath, NULL, 0.0f, midY);
    
    for (NSUInteger i = 0; i < filterSamples.count; i++) {
        float sample = [filterSamples[i] floatValue];
        // 每次迭代，向路径中添加一个点，索引i作为x坐标，样本值作为y坐标
        // 将路径移动到某个点画出一条线
        CGPathAddLineToPoint(halfPath, NULL, i, midY - sample);
    }
    
    // 创建第二个CGMutablepathRef，使Bezier路径绘制完整波形
    CGPathAddLineToPoint(halfPath, NULL, filterSamples.count, midY);
    
    CGMutablePathRef fullPath = CGPathCreateMutable();
    // 向路径中追加一段路径
    CGPathAddPath(fullPath, NULL, halfPath);
    
    // 要绘制波形下半部，需要对上半部路径应用translate和scale变化，使得上半部路径翻转到下面，填满整个波形
    // transform属性默认值设置为CGAffineTransformIdentity，可以在形变之后设置该值以还原到最初状态
    CGAffineTransform transform = CGAffineTransformIdentity;
    // 以一个已经存在的形变为基准，在x轴方向上平移x单位，在y轴方向上平移y单位
    transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
    // 以一个已经存在的形变为基准，在x轴方向上缩放x倍，在y轴方向上缩放y倍
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    // 将完整路径添加到图像上下文，根据指定的waveColor设置填充色。并绘制路径到图像上下文
    CGContextAddPath(context, fullPath);
    CGContextSetFillColorWithColor(context, self.waveColor.CGColor);
    // 进行绘制
    CGContextDrawPath(context, kCGPathFill);
    
    // 释放
    CGPathRelease(halfPath);
    CGPathRelease(fullPath);
}

@end
