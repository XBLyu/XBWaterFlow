//
//  XBWaterflowView.h
//  XBWaterFlow
//
//  Created by Mac on 15/11/2.
//  Copyright (c) 2015年 Moobye. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "XBWaterflowViewCell.h"

@class XBWaterflowView;

typedef enum {
    XBWaterflowViewMarginTypeTop,
    XBWaterflowViewMarginTypeLeft,
    XBWaterflowViewMarginTypeBottom,
    XBWaterflowViewMarginTypeRight,
    XBWaterflowViewMarginTypeColumn,// 列间距
    XBWaterflowViewMarginTypeRow    // 行间距
} XBWaterflowViewMarginType;



#pragma mark 数据源
@protocol XBWaterflowViewDataSourse <NSObject>

@required
/**
 *  返回cell总数（数据组数）
 */
- (NSInteger)numberOfCellsInWaterflowView:(XBWaterflowView *)waterflowView;

/**
 *  返回index对应的waterflowViewCell
 */
- (XBWaterflowViewCell *)waterflowView:(XBWaterflowView *)waterflowView cellAtIndex:(NSInteger)index;

@optional
/**
 *  返回列数
 */
- (NSInteger)numberOfColumnsInWaterflowView:(XBWaterflowView *)waterflowView;

@end

#pragma mark 代理
@protocol XBWaterflowViewDelegate <UIScrollViewDelegate>

@optional

/**
 *  返回index对应cell高度
 */
- (CGFloat)waterflowView:(XBWaterflowView *)waterflow heightAtIndex:(NSInteger)index;

/**
 *  响应点击cell方法
 */
- (void)waterflowView:(XBWaterflowView *)tableView didSelectAtIndex:(NSInteger)index;

/**
 *  返回间距
 */
- (CGFloat)waterflowView:(XBWaterflowView *)waterflow marginForType:(XBWaterflowViewMarginType)type;

@end

/**
 *  继承自UIScrollView的瀑布流控件
 */
@interface XBWaterflowView : UIScrollView

@property (nonatomic, assign) id<XBWaterflowViewDataSourse> dataSourse;

@property (nonatomic, assign) id<XBWaterflowViewDelegate>   delegate;

/**
 *  刷新数据（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）
 */
- (void)reloadData;

/**
 *  根据标识去缓存池查找可循环利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
