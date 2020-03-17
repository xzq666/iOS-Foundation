##  AVFoundation播放和录制视频


### 音频会话 AVAudioSession

音频会话在应用程序和操作系统之间扮演着中间人的角色，提供一种简单实用的方法使OS得知应用程序应该如何与iOS音频环境进行交互。
AVAudioSession有AVFoundation框架引入。每个iOS应用程序都有自己的一个音频会话，这个会话可以被AVAudioSession的类方法sharedInstance访问。音频会话是一个单例对象，可以使用它来设置应用程序的音频上下文环境，并向系统表达我们的应用程序音频行为的意图。

AVAudioSession *audioSession = [AVAudioSession sharedInstance];使用它可以实现：
1、启用或停用应用程序中的音频工作；
2、设置音频会话类别和模式；
3、配置音频设置，如采样率，I/O缓冲区持续时间和通道数；
4、处理音频输出更改；
5、相应重要的音频时间，如更改底层Media Services守护程序的可用性。


### 音频会话分类/类别

1、Ambient游戏、效率应用程序AVAudioSessionCategoryAmbient / kAudioSessionCategory_AmbientSound 使用这个分类应用会随着静音键和屏幕关闭而静音，且不会终止其他应用播放的声音，可以和其他自带应用如iPod、Safari同时播放声音。该类别无法在后台播放声音。
2、Solo Ambient(默认)游戏、效率应用程序AVAudioSessionCategorySoloAmbient / kAudioSessionCategory_SoloAmbientSound 类似Ambient，不同之处在于它会终止其它应用播放声音。该类别无法在后台播放声音。
3、Playback音频和视频播放AVAudioSessionCategoryPlayback / kAudioSessionCategory_MediaPlayback 用于以音频为主的应用，不会随着静音键和屏幕关闭而静音。可在后台播放声音。
4、Record录音机、视频捕捉AVAudioSessionCategoryRecord / kAudioSessionCategory_RecordAudio 录音应用，除了来电铃声、闹钟、日历提醒之外的其他系统声音不会被播放。只提供单纯录音功能。
5、Play and Record VoIP、语音聊天AVAudioSessionCategoryPlayAndRecord / kAudioSessionCategory_PlayAndRecord 提供录音和播放功能，如果应用需要用到iPhone上的听筒，这个类别是你唯一的选择，在这个类别下，声音的默认出口为听筒或者耳机。
6、Audio Processing离线会话和处理AVAudioSessionCategoryAudioProcessing / kAudioSessionCategory_AudioProcessing 在不播放或录制音频时使用音频硬件编解码器或信号处理器的类别。例如在执行离线音频格式转换时，此类别禁用播放和禁用录音。应用处于后台时，音频处理通常不会继续，但是可以在应用移至后台时，请求更多时间来完成处理。
7、Multi-Route使用外部硬件的高级A/V应用程序AVAudioSessionCategoryMultiRoute 
通过可以用的音频辅助设备和内置音频硬件设备，我们可以自定义使用类型。

并不是一个应用只能使用一个category，可以根据实际需求来切换设置不同的category。

通过音频会话单例对象的setCategory:error:设置iOS应用音频会话类别和模式。
NSError *error;
if (![_audioSession setCategory:AVAudioSessionCategoryPlayback error:&error]) { //设置类别
    NSLog(@"Category error :%@",[error localizedDescription]);
}


### 配置音频会话

音频会话在应用程序的生命周期中是可以修改的，一般在应用程序启动时，对其进行配置。配置音频会话的最佳位置就是应用程序委托的application: didFinishLaunchingWithOptions:方法。
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    if (![audioSession setCategory:AVAudioSessionCategoryPlayback error:&error]) {
        NSLog(@"Category error :%@",[error localizedDescription]);
    }
    if (![audioSession setActive:YES error:&error]) {
        NSLog(@"Activation Error :%@",[error localizedDescription]);
    }
    ...
}
AVAudioSession提供了与应用程序音频会话交互的接口，通过设置合适的分类可以为音频的播放指定需要的音频会话，定制一些行为。最后告知该音频会话激活该配置setActive:YES error:。
例如配置可以在后台运行：
info.plist文件添加一个新的Required background modes类型的数组，在其中添加名为App plays audio or streams audio/video using AirPlay选项。


### 使用AVAudioPlayer播放音频

AVAudioPlayer提供了简单地从文本或内存中播放音频的方法。AVAudioPlayer构建于Core Audio中的C-based Audio Queue Services的最顶层。它可以提供在Audio Queue Service中所能找到的核心功能。除非需要从网络流中播放音频、需要访问原始音频样本或者需要非常低的时延，否则它都能胜任。

1、创建AVAudioPlayer
两种方法创建AVAudioPlayer：initWithData:error:nil和initWithContentsOfURL:error:nil，分别使用包含要播放音频的内存NSData或者本地音频文件的NSURL。
NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"XXX" withExtension:@"mp3"];
_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
if (self.audioPlayer) {
    [self.audioPlayer prepareToPlay];
}
如果返回一个有效的播放实例，建议调用prepareToPlay方法，这样会取得需要音频硬件并预加载AudioQueue的缓冲区。调用这个方法是可选的，在调用play方法时会隐性激活，不过在创建时准备播放器可以降低调用paly方法和听到声音输出之间的延时。

2、对播放进行控制
常规方法：play -- 立即播放音频、pause -- 暂停播放、stop -- 停止播放。
pause和stop都能停止播放，并且再次播放的时候继续播放。区别是stop方法会撤销调用prepareToPlay时所做的设置，而调用pause不会。
其他方法：
修改播放器音量 -- 播放器的音量独立于系统的音量，可以通过对播放器音量的处理实现一些效果，比如声音渐隐效果。音量或播放增益定义为0.0(静音)到1.0之间的浮点值。
修改播放器pan值 -- 允许使用立体声播放声音，pan值范围-1.0(极左)-1.0(极右)，默认是为居中。
调整播放率 -- 允许用户在不改变音调的情况下调整播放率，范围从0.5(半速)-2.0(2倍速)。
通过设置numberOfLoops实现音频无缝循环 -- 给这个属性设置一个大于0的数，可以实现播放器n次循环播放。相反如果为-1导致播放器无限循环。音频循环可以是未压缩的线性PCM音频，也可以是AAC之类的压缩格式音频。MP3格式片段可以实现无缝循环，但是MP3格式用作循环格式不被推崇。MP3格式的音频要实现循环的目的通常需要使用特殊工具进行处理。如果希望使用压缩格式的资源，建议使用AAC或者AppleLossless格式的内容。
进行音频计量 -- 播放发生时从播放器读取播放力度的平均值和峰值。将这些数据提供给VU计量器或其他可视化元件。向用户提供可视化的反馈效果。

3、创建Audio Looper

4、处理中断事件
添加通知监听，监听是否发生中断事件，通知名称为AVAudioSessionInterruptionNotification。
NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
[center addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
推送的消息会包含许多重要信息的userInfo字典，通过关键字AVAudioSessionInterruptionTypeKey获取中断类型AVAudioSessionInterruptionType，根据中断状态执行不同操作。
如果中断类型为AVAudioSessionInterruptionTypeEnded，userInfo字典里会包含一个通过AVAudioSessionInterruptionOptionKey取的AVAudioSessionInterruptionOptions类型值，表示音频会话是否已经重新激活以及是否可以再次播放。

5、对线路改变的响应
在iOS设备上添加或移除音频输入、输出线路时，会发生线路改变，有多重原因会导致线路的变化，比如插入耳机或断开USB麦克风。当这些事件发生时，音频会根据情况改变输入或输出线路，同时AVAudioSession会广播一个描述该变化的通知给所有相关的监听者。
添加监听的通知名称AVAudioSessionRouteChangeNotification，该通知同样包含一个userInfo字典，带有相应通知发送的原因以及一个线路的描述，以此可以确定线路变化的情况。
判断线路变更发生的原因，取AVAudioSessionRouteChangeReasonKey对应的AVAudioSessionRouteChangeReason类型值。根据变更原因，作相应处理。
AVAudioSessionRouteChangeReasonUnknown = 0：原因不明；
AVAudioSessionRouteChangeReasonNewDeviceAvailable = 1：有新设备可用，如耳机插入；
AVAudioSessionRouteChangeReasonOldDeviceUnavailable = 2：一个旧设备不可用，如耳机拔出；
AVAudioSessionRouteChangeReasonCategoryChange = 3：音频类别被改变，如Audio从Play back变成Play And Record；
AVAudioSessionRouteChangeReasonOverride = 4：音频线路(route)改变，如类别是Play and Record，输出已经从默认的接收器改变成为扬声器；
AVAudioSessionRouteChangeReasonWakeFromSleep = 6：设备从休眠中醒来
AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory = 7：没有路径返回当前的类别，如Record列表当前没有输入设备；
AVAudioSessionRouteChangeReasonRouteConfigurationChange NS_ENUM_AVAILABLE_IOS(7_0) = 8：当前输入/输出口没变，但设置修改，如一个端口的数据选择已经改变。
输入口不同类型，input port type
AVAudioSessionPortLineIn
AVAudioSessionPortBuiltInMic ：内置麦克风
AVAudioSessionPortHeadsetMic ：耳机线中的麦克风
输出口不同类型，output port type
AVAudioSessionPortLineOut
AVAudioSessionPortHeadphones ：耳机或者耳机式输出设备
AVAudioSessionPortBuiltInReceiver ：帖耳朵时候内置扬声器（打电话的时候的听筒）
AVAudioSessionPortBuiltInSpeaker ：iOS设备的扬声器
AVAudioSessionPortBluetoothA2DP ：A2DP协议式的蓝牙设备
AVAudioSessionPortHDMI ：高保真多媒体接口设备
AVAudioSessionPortAirPlay ：远程AirPlay设备
AVAudioSessionPortBluetoothLE ：蓝牙低电量输出设备
