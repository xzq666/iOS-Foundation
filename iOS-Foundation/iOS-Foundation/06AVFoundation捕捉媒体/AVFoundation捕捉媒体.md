##  AVFoundationm捕捉媒体


### 捕捉功能

1、捕捉会话AVCaptureSession
AVFoundation捕捉栈的核心类是AVCaptureSession。一个捕捉会话相当于一个虚拟的“插线板”，用于连接输入和输出的资源。
捕捉会话管理从物理设备得到的数据流，比如摄像头和麦克风设备，输出到一个或多个目的地。可以动态配置输入和输出的线路，可以在会话进行中按需配置捕捉环境。
捕捉会话还可以额外配置一个会话预设值(session preset)，用来控制捕捉数据的格式和质量。
会话预设值默认为AVCaptureSessionPresetHigh，适用于大多数情况。还有很多预设值，可以根据需求设置。

2、捕捉设备AVCaptureDevice
AVCaptureDevice为摄像头或麦克风等物理设备定义了一个接口。对硬件设备定义了大量的控制方法，如对焦、曝光、白平衡和闪光灯等。
AVCaptureDevice定义大量类方法用于访问系统的捕捉设备，最常用的是defaultDeviceWithMediaType:，根据给定的媒体类型返回一个系统指定的默认设备。
例如AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
AVMediaTypeVideo请求的是一个默认的视频设备，在包含前置和后置摄像头的iOS系统，返回后置摄像头。

3、捕捉设备的输入AVCaptureInput
AVCaptureInput是一个抽象类，提供一个连接接口将捕获到的输入源连接到AVCaptureSession。
抽象类无法直接使用，只能通过其子类满足需求：
1）AVCaptureDeviceInput - 使用该对象从AVCaptureDevice获取设备数据(摄像头、麦克风等)；
2）AVCaptureScreenInput - 通过屏幕获取数据(如录屏)；
3）AVCaptureMetaDataInput - 获取元数据。
下面以AVCaptureDeviceInput为例：
使用捕捉设备进行处理前，需要将它添加为捕捉会话的输入。通过将设备(AVCaptureDevice)封装到AVCaptureDeviceInput实例中，实现将设备插入到AVCaptureSession中。
AVCaptureDeviceInput在设备输出数据和捕捉会话间，扮演接线板的作用。
"
AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
NSError *error;
AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
"

4、捕捉的输出AVCaptureOutput
AVCaptureOutput是一个抽象基类，用于从捕捉会话得到的数据寻找输出目的地。
框架定义一些这个基类的高级扩展类，比如
1）AVCaptureStillImageOutput - 用来捕捉静态图片；
2）AVCaptureMovieFileOutput - 捕捉视频。
还有一些底层扩展，如AVCaptureAudioDataOutput和AVCaptureVideoDataOutput使用它们可以直接访问硬件捕捉到的数字样本。使用底层输出类需要对捕捉设备的数据渲染有更好的理解，不过这些类可以提供更强大的功能，比如对音频和视频流进行实时处理。

5、捕捉连接AVCaptureConnection
捕捉会话首先确定有给定捕捉设备输入渲染的媒体类型，并自动建立其到能够接收该媒体类型的捕捉输出端的连接。
对连接的访问可以对信号流进行底层的控制，比如禁用某些特定的连接，或者在音频连接中访问单独的音频轨道(一些高级用法，不纠结)。
AVCaptureConnection解决图像旋转90°的问题：(setVideoOrientation:方法)
"
AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
AVCaptureVideoOrientation  avcaptureOrientation = [self avOrientationForDeviceOrientation:UIDeviceOrientationPortrait];
[stillImageConnection setVideoOrientation:avcaptureOrientation];
"

6、捕捉预览AVCaptureVideoPreviewLayer
AVCaptureVideoPreviewLayer是一个CoreAnimation的CALayer的子类，对捕捉视频数据进行实时预览。类似于AVPlayerLayer，不过针对摄像头捕捉的需求进行了定制。他也支持视频重力概念setVideoGravity:
1）AVLayerVideoGravityResizeAspect -- 在承载层范围内缩放视频大小来保持视频原始宽高比，默认值，适用于大部分情况。
2）AVLayerVideoGravityResizeAspectFill -- 保留视频宽高比，通过缩放填满层的范围区域，会导致视频图片被部分裁剪。
3）AVLayerVideoGravityResize -- 拉伸视频内容拼配承载层的范围，会导致图片扭曲，funhouse effect效应。


### 创建简单捕捉会话

1、创建捕捉会话AVCaptureSession，可以设置为成员变量，开始会话以及停止会话都是用实例对象。
AVCaptureSession *session = [[AVCaptureSession alloc] init];

2、创建获取捕捉设备 AVCaptureDevice
AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

3、创建捕捉输入AVCaptureDeviceInput
NSError *error;
AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];

4、将捕捉输入加到会话中
if ([session canAddInput:input]) {
    //首先检测是否能够添加输入，直接添加可能会有crash
    [session addInput:input];
}

5、创建一个静态图片输出AVCaptureStillImageOutput
AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];

6、将捕捉输出添加到会话中
if ([session canAddOutput:imageOutput]) {
    //检测是否可以添加输出
    [session addOutput:imageOutput];
}

7、创建图像预览层AVCaptureVideoPreviewLayer
AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
previewLayer.frame = self.view.frame;
[self.view.layer addSublayer:previewLayer];

8、开始会话
[session startRunning];

注意先获取对应权限。这里只是实现捕捉流程，梳理核心组件的关系，没有任何操作。典型的会话创建过程会更复杂，这是毋庸置疑的。当开始运行会话，视频数据流就可以在系统中传输。


### 创建一个简单的拍照视频项目

整个的逻辑依旧是上面的几步，更多的是一些新的属性设置。这里只实现了功能，没有作具体的优化。

1、创建捕捉会话
这里不再只是实现静态图片捕捉，还会有视频拍摄，因此需要有视频和音频输入，就是同时给会话添加多个输入和多个输出，然后分别单独处理。

2、开始和结束会话
开始j和结束会话同步调用会消耗一定时间，用异步方式在videoQueue排队调用相关方法，避免阻塞主线程。

3、设置切换摄像头
切换前置和后置摄像头需要重新配置捕捉回话，可以动态重新配置AVCaptureSession，不必担心停止会话和重新启动会话带来的开销。
对会话进行的任何改变，都要通过beginConfiguration和commitConfiguration进行单独的、原子性的变化。

4、捕获静态图片
AVCaptureConnection，当创建一个会话并添加捕捉设备输入和捕捉输出时，会话自动建立输入和输出的链接，按需选择信号流线路。访问这些连接，可以更好地对发送到输出端的数据进行控制。
CMSampleBuffer是由CoreMedia框架定义的CoreFoundation对象，可以用来保存捕捉到的图片数据。图片格式根据输出对象设定的格式决定。

5、录制视频
视频内容捕捉，设置捕捉会话，添加名为AVCaptureMovieFileOutput的输出。将QuickTime影片捕捉到磁盘，这个类的大多数核心功能继承于超类AVCaptureFileOutput。
通常当QuickTime准备发布时，影片头的元数据处于文件的开始位置，有利于视频播放器快速读取头包含的信息。
录制的过程中，直到所有的样本都完成捕捉后才能创建信息头。

6、将图片和视频保存到相册
将拍摄到的图片和视频通过系统库保存到相册。从iOS8.0开始支持的Photos/Photos.h库来实现图片和视频的保存。

7、关于闪光灯和手电筒的设置
设备后面的LED灯，当拍摄静态图片时作为闪光灯，当拍摄视频时用作连续灯光(手电筒)。捕捉设备的flashMode和torchMode。
AVCapture(Flash|Torch)ModeAuto：基于周围环境光照情况自动关闭或打开
AVCapture(Flash|Torch)ModeOff：总是关闭
AVCapture(Flash|Torch)ModeOn：总是打开
修改闪光灯或手电筒设置的时候，一定要先锁定设备再修改，否则会挂掉。
flashMode用于拍摄静态图片时（相机）进行的闪光灯设置。

8、其他一些设置
还有许多可以设置的属性，比如聚焦、曝光等等，设置起来差不多，首先要检测设备(摄像头)是否支持相应功能，锁定设备，然后设置相关属性。
