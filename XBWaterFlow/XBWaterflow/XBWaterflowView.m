//
//  XBWaterflowView.m
//  XBWaterFlow
//
//  Created by Mac on 15/11/2.
//  Copyright (c) 2015年 Moobye. All rights reserved.
//

#import "XBWaterflowView.h"
#import "XBWaterflowViewCell.h"

#define XBWaterflowViewDefaultCellH 70
#define XBWaterflowViewDefaultNumberOfColumns 70
#define XBWaterflowViewDefaultMargin 8

@interface XBWaterflowView ()

/**
 *  所有cell的frame数据
 */
@property (nonatomic, strong) NSMutableArray *cellFrames;
/**
 *  存储正在展示的cell
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;

#warning 缓存池
/**
 *  缓存池（用Set，存放离开屏幕的cell）
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;


@end

@implementation XBWaterflowView
#warning 解决了.h中代理声明时的问题:Auto property synthesis will not synthesize property 'delegate'; it will be implemented by its superclass, use @dynamic to acknowledge intention
@dynamic delegate;

#pragma mark - init
- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells
{
    if (_reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
    
//    UITableView *tabelView = [UITableView alloc] dequeueReusableCellWithIdentifier:]
}




#pragma mark - publicInterface
/**
 *  单元格重用，按照identifier返回单元格
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    __block XBWaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(XBWaterflowViewCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}


/**
 *  即将加载到superView时刷新数据
 */
- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 刷新数据
    [self reloadData];
}

/**
 *  刷新数据
 *  1.计算每个cell的frame
 */
- (void)reloadData {
    // cell总数
    NSInteger numberOfCells = [self.dataSourse numberOfCellsInWaterflowView:self];
    // 总列数
    NSInteger numberOfColumns = [self numberOfCloumns];
    // 间距
    CGFloat cellTopM    = [self marginForType:XBWaterflowViewMarginTypeTop];
    CGFloat cellLeftM   = [self marginForType:XBWaterflowViewMarginTypeLeft];
    CGFloat cellBottomM = [self marginForType:XBWaterflowViewMarginTypeBottom];
    CGFloat cellRightM  = [self marginForType:XBWaterflowViewMarginTypeRight];
    CGFloat cellColumnM = [self marginForType:XBWaterflowViewMarginTypeColumn];
    CGFloat cellRowM    = [self marginForType:XBWaterflowViewMarginTypeRow];
    // cell宽度
    CGFloat cellW = (self.width - cellLeftM - cellRightM - (numberOfColumns - 1) * cellColumnM) / numberOfColumns;
    
    // C语言数组存放 每列最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = cellTopM;
    }
    
    // cell的frame
    for (int i = 0; i < numberOfCells; i++) {
        // cell的高度
        CGFloat cellH = [self cellHeightAtIndex:i];
        
        // cell处在第几列(最短的一列)
        NSUInteger cellColumn = 0;
        // cell所处那列的最大Y值(最短那一列的最大Y值)
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        // 求出最短的一列
        for (int j = 1; j<numberOfColumns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        CGFloat cellX = cellLeftM + cellColumn * (cellColumnM + cellW);
        CGFloat cellY = maxYOfCellColumn == cellTopM ? cellTopM : (maxYOfCellColumn + cellRowM);
        
        // 得到cell 的frame 并储存在数组cellFrames 中
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        // 更新存储列最大Y值的数组
//        maxYOfColumns[cellColumn] = CGRectGetMinY(cellFrame);
        maxYOfColumns[cellColumn] = cellY + cellH;
}
    
    // 设置contentSize
    CGFloat contentH = maxYOfColumns[0];
    for (int j = 1; j<numberOfColumns; j++) {
        if (maxYOfColumns[j] > contentH) {
            contentH = maxYOfColumns[j];
        }
    }
    contentH += cellBottomM;
    self.contentSize = CGSizeMake(0, contentH);
    
}


/**
 *  UIScrollView滚动调用此方法
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 判读是否在屏幕上
    for (int i = 0; i < self.cellFrames.count; i++) {
        // 取出i对应cell 的 frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        XBWaterflowViewCell *cell = self.displayingCells[@(i)];
        if ([self isInScreen:cellFrame]) {// 在屏幕里
            // 优先取数组里cell
            if (cell == nil) {
                cell = [self.dataSourse waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                // 存入字典
                self.displayingCells[@(i)] = cell;
            }
            [self addSubview:cell];
        } else {// 不在屏幕
            if (cell) {
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                // 加入缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
}

#pragma mark - privateMethod
/**
 *  判读cell在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame {
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y + self.height);
}

/**
 *  cellMargin 间距
 */
- (CGFloat)marginForType:(XBWaterflowViewMarginType)type {
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    } else {
        return XBWaterflowViewDefaultMargin;
    }
}

/**
 *  cell高度
 */
- (CGFloat)cellHeightAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    } else {
        return XBWaterflowViewDefaultCellH;
    }
}

/**
 *  总列数
 */
- (NSInteger)numberOfCloumns {
    if ([self.dataSourse respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSourse numberOfColumnsInWaterflowView:self];
    } else {
        return XBWaterflowViewDefaultNumberOfColumns;
    }
}

#pragma mark － 点击事件
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 判读代理有没有实现 代理方法
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) {
        return;
    }
    
    // 获得触摸点
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    XBLog(@"%@",NSStringFromCGPoint(point));
    
//    __block NSInteger selectedCellIndex = NULL;
    __block NSNumber *selectedCellIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id index, XBWaterflowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectedCellIndex = index;
            *stop = YES;
        }
    }];
    
    if (selectedCellIndex) {
        [self.delegate waterflowView:self didSelectAtIndex:selectedCellIndex.unsignedIntegerValue];
    }
}

@end
