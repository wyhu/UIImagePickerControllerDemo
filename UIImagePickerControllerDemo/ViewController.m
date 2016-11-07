//
//  ViewController.m
//  UIImagePickerControllerDemo
//
//  Created by huweiya on 16/11/7.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TableViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AVAudioRecorderController.h"
#import "UIImageController.h"
@interface ViewController ()
<MPMediaPickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;


//@property (nonatomic,strong)UISlider *volumeSlider;
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,assign)CGPoint firstPoint;
@property (nonatomic,assign)CGPoint secondPoint;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];

//    [self playSoundEffect:@"aaaa.caf"];
}


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (NSArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = @[@"本地录音及播放",
                     @"MPMusicPlayerController",
                     @"UIImagePickerController(摄像头相关)",
                     @"备用",
                     @"备用"];
    }
    return _dataArr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //录音机
        AVAudioRecorderController *av = [[AVAudioRecorderController alloc] init];
        [self.navigationController pushViewController:av animated:YES];
        
    }
    if (indexPath.row == 1) {
        TableViewController *ta = [[TableViewController alloc] init];
        [self.navigationController pushViewController:ta animated:YES];
    }
    if (indexPath.row == 2) {
        //摄像头相关
        UIImageController *a = [[UIImageController alloc] init];
        [self.navigationController pushViewController:a animated:YES];

    }
    
}


/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}




/**
 *  播放音效文件
 *
 *  @param name 音频文件名称
 */
-(void)playSoundEffect:(NSString *)name{
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:nil];
    
    if (!audioFile) {
        return;
    }
    
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}








@end
