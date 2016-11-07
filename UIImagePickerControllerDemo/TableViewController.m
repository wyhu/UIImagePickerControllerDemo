//
//  TableViewController.m
//  UIImagePickerControllerDemo
//
//  Created by huweiya on 16/11/7.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "TableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface TableViewController ()

@property (nonatomic,retain) NSMutableArray *items;         //存放本地歌曲
@property (nonatomic,retain) MPMusicPlayerController *mpc;  //播放器对象

@end

@implementation TableViewController

//只获取本地音乐列表
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    //监听歌曲播放完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    [self initMusicItems];
}


#pragma mark - Private Method
-(void)initMusicItems{
    //获得query，用于请求本地歌曲集合
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    //循环获取得到query获得的集合
    for (MPMediaItemCollection *conllection in query.collections) {
        //MPMediaItem为歌曲项，包含歌曲信息
        for (MPMediaItem *item in conllection.items) {
            [self.items addObject:item];
        }
    }
    //通过歌曲items数组创建一个collection
    MPMediaItemCollection *mic = [[MPMediaItemCollection alloc] initWithItems:self.items];
    //获得应用播放器
    self.mpc = [MPMusicPlayerController applicationMusicPlayer];
    //开启播放通知，不开启，不会发送歌曲完成，音量改变的通知
    [self.mpc beginGeneratingPlaybackNotifications];
    //设置播放的集合
    [self.mpc setQueueWithItemCollection:mic];
}

-(void)reload{
    //音乐播放完成刷新table
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    MPMediaItem *item = self.items[indexPath.row];
    //获得专辑对象
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    //专辑封面
    UIImage *img = [artwork imageWithSize:CGSizeMake(100, 100)];
    if (!img) {
        img = [UIImage imageNamed:@"musicImage.png"];
    }
    cell.imageView.image = img;
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];         //歌曲名称
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];  //歌手名称
    if (self.mpc.nowPlayingItem == self.items[indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    //设置播放选中的歌曲
    [self.mpc setNowPlayingItem:self.items[indexPath.row]];
    [self.mpc play];
    
    [self.tableView reloadData];
}


@end
