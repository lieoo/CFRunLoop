//
//  ViewController.m
//  CFRunLoopDemo
//
//  Created by Leo on 2018/7/9.
//  Copyright © 2018 Leo. All rights reserved.
//

#import "ViewController.h"
#import "LoopViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"Touch Screen to push";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    LoopViewController *vc = [[LoopViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


