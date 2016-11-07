//
//  UIImageController.m
//  UIImagePickerControllerDemo
//
//  Created by huweiya on 16/11/7.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "UIImageController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImageController ()

<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) IBOutlet UIImageView *photo;//照片展示视图
@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频


@end

@implementation UIImageController

#pragma mark - 控制器视图事件
- (void)viewDidLoad {
    [super viewDidLoad];
    //通过这里设置当前程序是拍照还是录制视频
    [self.view addSubview:self.photo];
    self.view.backgroundColor = [UIColor yellowColor];
    _isVideo=NO;
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 100, 50)];
    [btn setTitle:@"开始" forState:0];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(takeClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (UIImageView *)photo
{
    if (!_photo) {
        _photo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 200, 200)];
        
    }
    return _photo;
}

#pragma mark - UI事件
//点击拍照按钮
- (IBAction)takeClick:(UIButton *)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo setImage:image];//显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
}

#pragma mark - 私有方法
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker=[[UIImagePickerController alloc]init];
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
        _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
        if (self.isVideo) {
            _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
            
        }else{
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作
    }
    return _imagePicker;
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame=self.photo.frame;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
        
    }
}
@end
