//
//  ViewController.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "ViewController.h"
#import "FFTableManager.h"
#import "HeaderCollectionReusableView.h"
@interface ViewController () <FFTableManagerDataSource, FFTableManagerDelegate>
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *twoDatas;
@property (nonatomic, strong) NSMutableArray *headeraaa;
@property (nonatomic, strong) NSMutableArray *headerbbb;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) FFTableManager *manager;
@end
static NSInteger const Column = 6;
static NSInteger const Row = 30;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView layoutIfNeeded];
    FFTableManager *manager = [FFTableManager shareFFTableManagerWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height - 20) sView:self.scrollView];
    manager.delegate = self;
    manager.dataSource = self;
    manager.averageItem(true).isShowAll(false);
    [manager reloadData];
    _manager = manager;
    [[manager didSelectWithBlock:^(UICollectionView * _Nonnull collectionView, FFMatrix matrix, NSInteger section) {
        
    }] didSelectHeaderWithBlock:^(UICollectionView * _Nonnull collectionView, FFMatrix matrix, NSInteger section) {
        
    }];
   
    _scrollView.contentSize = CGSizeMake(0, [manager getTableHeight]);
}

- (NSInteger)ffTableManagerNumberOfSection:(FFTableManager *)FFTableManager {
    return 2;
}

- (NSInteger)ffTableManager:(FFTableManager *)FFTableManager columnSection:(NSInteger)section {
    switch (section) {
        case 0:
            return Column;
            break;
            
        case 1:
            return Column - 1;
            break;
    }
    return 0;
}

- (NSInteger)ffTableManager:(FFTableManager *)FFTableManager rowWithNumberSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.datas.count;
            break;
            
        case 1:
            return self.twoDatas.count;
            break;
    }
    return 0;
}

//- (NSArray *)ffTableManager:(FFTableManager *)FFTableManager itemWidtWeightCoefficienthWithSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return @[@1.5,@1.5,@1,@1,@1,@1];
//            break;
//            
//        case 1:
//            return @[@1.5,@1.5,@1,@1,@1];
//            break;
//    }
//    return nil;
//}

//- (CGFloat )ffTableManagerItemWidthWithColumn:(NSInteger )column Section:(NSInteger )section margin:(UIEdgeInsets )margin {
//    CGFloat w = self.view.bounds.size.width - margin.left - margin.right;
//    CGFloat cellWidth = w / Column;
//    switch (column) {
//        case 0:
//            return cellWidth * 2;
//            break;
//
//        default:
//        {
//            CGFloat width = (w - cellWidth * 2) / (Column  - 1);
//            return width;
//        }
//            break;
//    }
//}

//- (Class)ffTableManager:(FFTableManager *)FFTableManager registClassWithSection:(NSInteger)section {
//    return [HeaderCollectionReusableView class];
//}
//
//- (CGFloat )ffTableManager:(FFTableManager *)FFTableManager headerHeightWithSction:(NSInteger )section {
//    return 100;
//}

- (void )ffTableManager:(FFTableManager *)FFTableManager setCollectionHeaderView:(UICollectionReusableView *)ffTableCollectionView section:(NSInteger)section {
    HeaderCollectionReusableView *view = (HeaderCollectionReusableView *)ffTableCollectionView;
    view.label.text = @"挨家挨户就开始";
}

- (nonnull FFTableCollectionModel *)ffTableManagerSetData:(nonnull FFTableManager *)FFTableManager section:(NSInteger )section matrix:(FFMatrix)matrix {
    switch (section) {
        case 0:
            return self.datas[matrix.row][matrix.column];
            break;
            
        case 1:
            return self.twoDatas[matrix.row][matrix.column];
            break;
    }
    return nil;
}

- (NSMutableArray<FFTableCollectionModel *> *)ffTableManagerHeaderViewSetData:(FFTableManager *)FFTableManager section:(NSInteger)section {
    switch (section) {
        case 0:
            return self.headeraaa;
            break;
            
        default:
            return self.headerbbb;
            break;
    }
}

- (NSMutableArray *)addData:(NSInteger )row {
    NSMutableArray *arraa = [NSMutableArray array];
    for (NSInteger i = 0; i < 7; i++) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSInteger j = 0; j < Column; j++) {
            UIColor *color = [UIColor blueColor];
            UIColor *bgColor = [UIColor whiteColor];
            NSString *aaa = [NSString stringWithFormat:@"%@%ld", @"添加的数据", (long)row];
            FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:color font:[UIFont systemFontOfSize:14] bgColor:bgColor type:@"" select:false];
            [arr addObject:model];
        }
        [arraa addObject:arr];
    }
   
    return arraa;
}

- (NSMutableArray *)headeraaa {
    if (!_headeraaa) {
        _headeraaa = [NSMutableArray array];
        for (NSString *aaa in @[@"姓名", @"部门", @"目标拜访", @"实际完成", @"最后一次跟进", @"完成率"]) {
            FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] bgColor:[UIColor whiteColor] type:@"" select:false];
            [_headeraaa addObject:model];
        }
    }
    return _headeraaa;
}

- (NSMutableArray *)headerbbb {
    if (!_headerbbb) {
        _headerbbb = [NSMutableArray array];
        for (NSString *aaa in @[@"姓名", @"部门", @"目标拜访", @"实际完成", @"最后一次跟进"]) {
            FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] bgColor:[UIColor whiteColor] type:@"" select:false];
            [_headerbbb addObject:model];
        }
    }
    return _headerbbb;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
        
        for (NSInteger i = 0; i < Row; i++) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger j = 0; j < Column; j++) {
                UIColor *color;
                UIColor *bgColor;
                NSString *aaa = @"sjldhakjshkh";
                if (i == 2 && j == 3) {
                    aaa = @"是考虑到哈科技收到货卡接收到卡换句话说的";
                    color = [UIColor greenColor];
                    bgColor=  [UIColor redColor];
                }
                FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:color font:[UIFont systemFontOfSize:14] bgColor:bgColor type:@"aaa" select:false];
                [arr addObject:model];
            }
            [_datas addObject:arr];
        }
    }
    return _datas;
}

- (NSMutableArray *)twoDatas {
    if (!_twoDatas) {
        _twoDatas = [NSMutableArray array];
        
        for (NSInteger i = 0; i < Row; i++) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger j = 0; j < Column - 1; j++) {
                UIColor *color;
                UIColor *bgColor;
                NSString *aaa = @"sjldhakjshkh";
                if (i == 2 && j == 3) {
                    aaa = @"是考虑到哈科技收到货卡接收到卡换句话说的";
                    color = [UIColor greenColor];
                    bgColor=  [UIColor redColor];
                }
                FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:color font:[UIFont systemFontOfSize:14] bgColor:bgColor type:@"aaa" select:false];
                [arr addObject:model];
            }
            [_twoDatas addObject:arr];
        }
    }
    return _twoDatas;
}

@end
