//
//  ViewController.m
//  XBWaterFlow
//
//  Created by Mac on 15/11/2.
//  Copyright (c) 2015年 Moobye. All rights reserved.
//

#import "ViewController.h"
#import "XBWaterflowView.h"
#import "XBWaterflowViewCell.h"

@interface ViewController () <XBWaterflowViewDataSourse,XBWaterflowViewDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加waterflowView
    XBWaterflowView *waterflowView = [[XBWaterflowView alloc] init];
    
    waterflowView.frame = self.view.bounds;
    waterflowView.dataSourse = self;
    waterflowView.delegate = self;
    
    
    
    [self.view addSubview:waterflowView];
    
    
//    XBLogTestMethod;
//    XBLog(@"%lu",(unsigned long)waterflowView.subviews.count);

}

#pragma mark dataSourse methods
- (NSInteger)numberOfCellsInWaterflowView:(XBWaterflowView *)waterflowView {
    return 2000;
}

- (NSInteger)numberOfColumnsInWaterflowView:(XBWaterflowView *)waterflowView {
    return 3;
}

- (XBWaterflowViewCell *)waterflowView:(XBWaterflowView *)waterflowView cellAtIndex:(NSInteger)index {
    static NSString *ID = @"cell";
#warning －－－－－－－单元格cell的重用，掌握好 －－－－－－
//    XBWaterflowViewCell *cell = [[XBWaterflowView alloc] dequeueReusableCellWithIdentifier:ID];//错误
    XBWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[XBWaterflowViewCell alloc] init];
        cell.backgroundColor = XBRandomColorRGBA;
        cell.identifier = ID;
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = 10;
        label.frame = CGRectMake(0, 0, 50, 20);
        [cell addSubview:label];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:10];
    label.text = [NSString stringWithFormat:@"%ld",(long)index];
    
    // 看内存验证是否重用
//    XBLog(@"%ld,%p",(long)index,cell);
    
    return cell;
}

#pragma mark delegate methods
- (CGFloat)waterflowView:(XBWaterflowView *)waterflow heightAtIndex:(NSInteger)index {
    switch (index % 3) {
        case 0: return 150;
        case 1: return 100;
        case 2: return 180;
        default: return 110;
    }
}

- (CGFloat)waterflowView:(XBWaterflowView *)waterflow marginForType:(XBWaterflowViewMarginType)type {
    switch (type) {
        case XBWaterflowViewMarginTypeLeft:
        case XBWaterflowViewMarginTypeRight:
        case XBWaterflowViewMarginTypeTop:
        case XBWaterflowViewMarginTypeBottom:
            return 10;
        default:
            return 10;
    }
}

- (void)waterflowView:(XBWaterflowView *)tableView didSelectAtIndex:(NSInteger)index {
    XBLog(@"第%@个cell被点击啦",[NSString stringWithFormat:@"%ld",(long)index]);
}

@end
