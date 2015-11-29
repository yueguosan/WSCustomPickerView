//
//  WSPickerView.h
//  CustomPickerView
//
//  Created by wsq on 15/11/29.
//  Copyright (c) 2015年 wsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSPickerView;

@protocol WSPickerViewDataSource <NSObject>

- (NSInteger)numberOfRowsInPickerView:(WSPickerView *)pickerView;
- (NSString *)pickerView:(WSPickerView *)WSPickerView titleForRow:(NSInteger)row;

@end

@protocol WSPickerViewDelegate <NSObject>

- (void)pickerView:(WSPickerView *)pickerView didSelectRow:(NSInteger)row;

@end

@interface WSPickerView : UIView <UIScrollViewDelegate> {
    UIScrollView *contentView;
    
    int currentRow;
    NSInteger rowsCount;
    
    NSMutableSet *recycledViews;
    NSMutableSet *visibleViews;
    
}

@property (nonatomic, weak) id <WSPickerViewDataSource> dataSource;
@property (nonatomic, weak) id <WSPickerViewDelegate> delegate;

/// 选中的行数
@property (nonatomic, assign) int selectedRow;
/// 字体大小
@property (nonatomic, strong) UIFont *rowFont;
@property (nonatomic, strong) UIColor *textColor;
/// 左间距
@property (nonatomic, assign) CGFloat rowIndent;
/// 总列数
@property (nonatomic, assign) int count;
/// 每一行的高度
@property (nonatomic, assign) CGFloat selectHeight;


- (void)reloadData;

/// 计算当前的row 并更新位置
- (void)determineCurrentRow;

// 循环队列
- (UIView *)dequeueRecycledView;
- (BOOL)isDisplayingViewForIndex:(NSUInteger)index;
- (void)tileViews;
- (void)configureView:(UIView *)view atIndex:(NSUInteger)index;

@end
