//
//  ViewController.m
//  CustomPickerView
//
//  Created by wsq on 15/11/29.
//  Copyright (c) 2015年 wsq. All rights reserved.
//

#import "ViewController.h"
#import "WSPickerView.h"


@interface ViewController ()<WSPickerViewDelegate, WSPickerViewDataSource> {
    WSPickerView *wsPickerView;
    NSArray *array;
    
    UILabel *label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    array = [[NSArray alloc] initWithObjects:@"今晚",@"下班",@"吃",@"烤羊",@"去不去", @"再见", nil];
    
    CGFloat heightView = 100;
    wsPickerView = [[WSPickerView alloc] initWithFrame:CGRectMake(30.0, 250.0, 126.0, heightView)];
    wsPickerView.dataSource = self;
    wsPickerView.delegate = self;
    wsPickerView.rowFont = [UIFont boldSystemFontOfSize:19.0];
    wsPickerView.rowIndent = 0.0;
    wsPickerView.selectHeight = 21.0;
    wsPickerView.count = (int)array.count;
    [wsPickerView reloadData];
    [self.view addSubview:wsPickerView];
    wsPickerView.selectedRow = 2;
    wsPickerView.backgroundColor = [UIColor cyanColor];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(30 + 140, 270, 60, 21)];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor orangeColor];
    label.text = array[1];
    
}

#pragma mark - WSPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(WSPickerView *)pickerView {
    return array.count;
}


- (NSString *)pickerView:(WSPickerView *)pickerView titleForRow:(NSInteger)row {
    return [array objectAtIndex:row];
}


#pragma mark - WSPickerViewDelegate
- (void)pickerView:(WSPickerView *)pickerView didSelectRow:(NSInteger)row {
    
    NSLog(@"didSelect=%@",array[row]);
    label.text = array[row];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
