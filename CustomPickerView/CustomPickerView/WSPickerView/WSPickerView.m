//
//  WSPickerView.m
//  CustomPickerView
//
//  Created by wsq on 15/11/29.
//  Copyright (c) 2015年 wsq. All rights reserved.
//

#import "WSPickerView.h"

@implementation WSPickerView

- (void)setSelectedRow:(int)selectedRow {
    if (selectedRow >= rowsCount)
        return;
    
    currentRow = selectedRow;
    [contentView setContentOffset:CGPointMake(0.0, _selectHeight * currentRow) animated:NO];
}

- (void)setRowFont:(UIFont *)rowFont {
    _rowFont = rowFont;
    
    for (UILabel *aLabel in visibleViews) {
        aLabel.font = _rowFont;
    }
    
    for (UILabel *aLabel in recycledViews) {
        aLabel.font = _rowFont;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (UILabel *aLabel in visibleViews) {
        aLabel.textColor = _textColor;
    }
    
    for (UILabel *aLabel in recycledViews) {
        aLabel.textColor = _textColor;
    }
    
}

- (void)setRowIndent:(CGFloat)rowIndent {
    _rowIndent = rowIndent;
    
    for (UILabel *aLabel in visibleViews) {
        CGRect frame = aLabel.frame;
        frame.origin.x = _rowIndent;
        frame.size.width = self.frame.size.width - _rowIndent;
        aLabel.frame = frame;
    }
    
    for (UILabel *aLabel in recycledViews) {
        CGRect frame = aLabel.frame;
        frame.origin.x = _rowIndent;
        frame.size.width = self.frame.size.width - _rowIndent;
        aLabel.frame = frame;
    }
}

-(void)setCount:(int)count {
    _count = count;
}

-(void)setSelectHeight:(CGFloat)selectHeight {
    _selectHeight = selectHeight;
}


#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rowFont = [UIFont boldSystemFontOfSize:24.0];
        _rowIndent = 0;
        
        currentRow = 0;
        rowsCount = 0;
        
        self.selectHeight = 21.0;
        
        visibleViews = [[NSMutableSet alloc] init];
        recycledViews = [[NSMutableSet alloc] init];
        
        contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.delegate = self;
        [self addSubview:contentView];
    }
    return self;
}


- (void)reloadData {
    
    UIImage *glassImage = [UIImage imageNamed:@"bx_sel"];
    UIImageView *glassImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, _selectHeight, self.frame.size.width - 20, _selectHeight)];
    glassImageView.image = glassImage;
    [self addSubview:glassImageView];
    
    currentRow = 0;
    rowsCount = 0;
    
    for (UIView *aView in visibleViews)
        [aView removeFromSuperview];
    
    for (UIView *aView in recycledViews)
        [aView removeFromSuperview];
    
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
    
    rowsCount = [_dataSource numberOfRowsInPickerView:self];
    [contentView setContentOffset:CGPointMake(0.0, _selectHeight*2) animated:NO];
    contentView.contentSize = CGSizeMake(contentView.frame.size.width, _selectHeight * rowsCount + _count * _selectHeight);
    [self tileViews];
}



#pragma maek - 计算当前的row 并更新位置
- (void)determineCurrentRow {
    CGFloat delta = contentView.contentOffset.y;
    
    // 四舍五入 得出整数
    int position = round(delta / _selectHeight);
    
    if (position >= self.count) {
        position = self.count;
        currentRow = position;
    }else if (position <= 0){
        position = 1;
    }
    
    currentRow = position;
    // 选中的位置
    [contentView setContentOffset:CGPointMake(0.0, _selectHeight * position) animated:YES];
    // 选中的下标
    [_delegate pickerView:self didSelectRow:currentRow - 1];
    
}


- (UIView *)dequeueRecycledView {
    UIView *aView = [recycledViews anyObject];
    
    if (aView)
        [recycledViews removeObject:aView];
    return aView;
}


- (BOOL)isDisplayingViewForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (UIView *aView in visibleViews) {
        int viewIndex = aView.frame.origin.y / _selectHeight - 2;
        if (viewIndex == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}


- (void)tileViews {
    
    // 计算哪些页面是可见的
    CGRect visibleBounds = contentView.bounds;
    int firstNeededViewIndex = floorf(CGRectGetMinY(visibleBounds) / _selectHeight) - 2;
    NSInteger lastNeededViewIndex  = floorf((CGRectGetMaxY(visibleBounds) / _selectHeight)) - 2;
    
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);
    lastNeededViewIndex  = MIN(lastNeededViewIndex, rowsCount - 1);
    
    // 回收不再可见页
    for (UIView *aView in visibleViews) {
        int viewIndex = aView.frame.origin.y / _selectHeight - 2;
        if (viewIndex < firstNeededViewIndex || viewIndex > lastNeededViewIndex) {
            [recycledViews addObject:aView];
            [aView removeFromSuperview];
        }
    }
    
    [visibleViews minusSet:recycledViews];
    
    // 添加循环的Label
    for (int index = firstNeededViewIndex; index <= lastNeededViewIndex; index++) {
        if (![self isDisplayingViewForIndex:index]) {
            UILabel *label = (UILabel *)[self dequeueRecycledView];
            if (label == nil) {
                label = [[UILabel alloc] initWithFrame:CGRectMake(_rowIndent, 0, self.frame.size.width - _rowIndent, _selectHeight)];
                label.backgroundColor = [UIColor clearColor];
                label.font = self.rowFont;
                label.textColor = _textColor;
                label.textAlignment = NSTextAlignmentCenter;
            }
            [self configureView:label atIndex:index];
            [contentView addSubview:label];
            [visibleViews addObject:label];
        }
    }
}

- (void)configureView:(UIView *)view atIndex:(NSUInteger)index {
    UILabel *label = (UILabel *)view;
    label.text = [_dataSource pickerView:self titleForRow:index];
    CGRect frame = label.frame;
    frame.origin.y = _selectHeight * (2 + index);
    label.frame = frame;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tileViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self determineCurrentRow];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self determineCurrentRow];
}

@end
