//
//  LoopViewController.m
//  CFRunLoopDemo
//
//  Created by Leo on 2018/7/9.
//  Copyright © 2018 Leo. All rights reserved.
//

#import "LoopViewController.h"
#import "YYFPSLabel.h"
#import "AViewController.h"

typedef void(^Action)();

@interface LoopViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic) NSInteger maxConcurrentTaskCount;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation LoopViewController

// 原理将


- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationItem.title = @"Loooooooooop";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.rowHeight = 90;
    
    YYFPSLabel *label = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.navigationItem.titleView = label;
    
    _maxConcurrentTaskCount = NSIntegerMax;

    _tasks = [[NSMutableArray alloc] init];
    

//    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
//    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.00001 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(_timer, ^{
//        if (weakSelf.tasks.count == 0)return;
//            Action action = weakSelf.tasks.firstObject;
//            [weakSelf.tasks removeObjectAtIndex:0];
//            action();
//    });
//    dispatch_resume(_timer);
//    NSTimer来每间隔一定时间执行一个任务，这样RunLoop每间隔一定时间就会苏醒一次，每苏醒一次就执行加载一张图片。

    
    
#pragma mark -- 使用RunLoop
    //注 非常快速滑动，然后又点击返回按钮返回上一个ViewController会引起内存泄漏
    __weak typeof(self) weakSelf = self;

    CFRunLoopRef _rl = CFRunLoopGetCurrent();
    CFRunLoopMode _mode = kCFRunLoopCommonModes;
    CFRunLoopObserverRef _observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (weakSelf.tasks.count == 0) {
            return;
        }
        Action action = weakSelf.tasks.firstObject;
        [weakSelf.tasks removeObjectAtIndex:0];
        action();
    });
    CFRunLoopAddObserver(_rl, _observer, _mode);
    CFRelease(_observer);
}

- (void)addTask:(Action)action{
    [_tasks addObject:action];
    if (_tasks.count > _maxConcurrentTaskCount) {
        [_tasks removeObjectAtIndex:0];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        CGFloat width = (tableView.bounds.size.width - 20) / 3;
        for (int i = 0; i < 3; i++) {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(5*(i+1)+width*i, 5, width, tableView.rowHeight - 10)];
            iv.tag = 110+i;
            [cell.contentView addSubview:iv];
        }
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG" ofType:@"JPG"];
    UIImageView *iv0 = [cell viewWithTag:110];
    UIImageView *iv1 = [cell viewWithTag:111];
    UIImageView *iv2 = [cell viewWithTag:112];
    
#define USERUNLOOP
    
#ifdef USERUNLOOP
    [self addTask:^{
        iv0.image = [UIImage imageWithContentsOfFile:path];
    }];

    [self addTask:^{
        iv1.image = [UIImage imageWithContentsOfFile:path];
    }];

    [self addTask:^{
        iv2.image = [UIImage imageWithContentsOfFile:path];
    }];
#else
    //注 使用 imageWithContentsOfFile 故意不缓存图片
    iv0.image = [UIImage imageWithContentsOfFile:path];
    iv1.image = [UIImage imageWithContentsOfFile:path];
    iv2.image = [UIImage imageWithContentsOfFile:path];
#endif
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AViewController *vc = [AViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc{
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
