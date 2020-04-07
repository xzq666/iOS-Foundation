##  读取与写入媒体


AVFoundation定义了一组功能可以用于创建媒体应用程序时遇到的大部分用例场景。还有一些功能不受AVFoundation框架的内置支持，需要使用框架的AVAssetReader和AVAssetWriter类提供的低级功能来直接处理媒体样本。


### AVAssetReader

用于从AVAsset中读取媒体样本，通常会配置一个或多个AVAssetReaderOutput实例，并通过copyNextSampleBuffer方法访问音频样本和视频帧。<br/>
AVAssetReaderOutput是一个抽象类，不过框架定义了具体实例来从指定的AVAssetTrack中读取解码的媒体样本，从多音频轨道中读取混合输出，或者从多视频轨道总读取组合输出。<br/>
1）AVAssetReaderAudioMixOutput<br/>
2）AVAssetReaderTrackOutput<br/>
3）AVAssetReaderVideoCompositionOutput<br/>
4）AVAssetReaderSampleReferenceOutput<br/>
一个资源读取器内部通道都是以多线程的方式不断提取下一个可用样本的，这样可以在系统请求资源时最小化时延。尽管提供了低时延的检索操作，还是不倾向于实时操作，比如播放。<br/>
注：AVAssetReader只针对于带有一个资源的媒体样本，如果需要同时从多个基于文件的资源中读取样本，可将它们组合到一个AVAsset子类AVComposition中。


### AVAssetWriter

对媒体资源进行编码并将其写入到容器文件中，例如一个MPEG-4文件或一个QuickTime文件。它由一个或多个AVAssetWriterInput对象配置，用于附加将包含要写入容器的媒体样本的CMSampleBuffer对象。<br/>
AVAssetWriterInput被配置为可以处理指定的媒体类型，比如音频或视频，并且附加在其后的样本会在最终输出时生成一个独立的AVAssetTrack。当使用一个配置了处理视频样本的AVAssetWriterInput时，会常用到一个专门的适配器对象AVAssetWriterInputPixelBufferAdaptor，这个类在附加被包装为CVPixelBuffer对象的视频样本时提供最优性能。<br/>
输入信息也可以通过使用AVAssetWriterInputGroup组成互斥的参数，可以创建特定资源，包含在播放时使用AVMediaSelectionGroup和AVMediaSelectionOption类选择的指定语言媒体轨道。<br/>
AVAssetWriter可以自动支持交叉媒体样本。AVAssetWriterInput提供一个readyForMoreMediaData属性来指示在保持所需的交错情况下输入信息是否还可以附加更多数据，只有在这个属性值为YES时才可以将一个新的样本添加到输入信息中。<br/>
AVAssetWriter可用于实时操作和离线操作两种情况。对于每个场景中都有不同的方法将样本buffer添加到写入对象的输入中。<br/>
1、实时：处理实时资源时，比如从AVCaptureVideoDataOutput写入捕捉的样本时，AVAssetWriter应该令expectsMediaDataInRealTime为YES来确保readyForMoreMediaData值被正确计算。从实时资源写入数据优化了写入器，与维持理想交错效果相比，快速写入样本具有更高的优先级。<br/>
2、离线：当从离线资源中读取媒体资源时，比如从AVAssetReader读取样本buffer，在附加样本前仍需写入器输入的readyForMoreMediaData属性的状态，不过可以使用requestMediaDataWhenReadyOnQueue:usingBlock:方法控制数据的提供。传到这个方法中的代码块会随写入器输入准备附加更多的样本而不断被调用。添加样本时需要检索数据并从资源中找到下一个样本进行添加。


### 创建音频波形(waveform)视图

绘制波形有三个步骤：<br/>
一、读取，读取音频样本进行渲染。需要读取或可能解压缩音频数据。<br/>
二、缩减，实际读取到的样本数量要远比在屏幕上渲染的多。缩减过程必须作用于样本集，将样本总量分为小的样本块，并在每个样本块上找到最大的样本、所有样本的平均值或min/max值。<br/>
三、渲染，将缩减后的样本呈现在屏幕上。通常用到Quartz框架，可以使用苹果支持的绘图框架。如何绘制这些数据的类型取决于如何缩减样本。采用min/max对，则为它的每一对绘制一条垂线。如果使用每个样本块平均值或最大值，使用Quartz Bezier路径绘制波形。<br/>

1、读取音频样本 -- 提取全部样本集合<br/>
1）加载AVAsset资源轨道数据；<br/>
2）加载完成之后，创建AVAssertReader，并配置AVAssetReaderTrackOutput；<br/>
3）AVAssertReader读取数据，并将读取到的样本数据添加到NSData实例后面。<br/>

2、缩减音频样本<br/>
根据指定压缩空间压缩样本。即将总样本分块，取每块子样本最大值，重新组成新的音频样本集合。<br/>

3、渲染音频样本<br/>
将筛选出来的音频样本数据，绘制成波形图。可以使用Quartz的Bezier绘制。
