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
@property (nonatomic, strong) NSMutableArray *headeraaa;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) FFTableManager *manager;
@end
static NSInteger const Column = 6;
static NSInteger const Row = 50;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView layoutIfNeeded];
    FFTableManager *manager = [FFTableManager shareFFTableManagerWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height - 20) sView:self.scrollView];
    manager.delegate = self;
    manager.dataSource = self;
    manager.averageItem(false).isShowAll(false);
    [manager reloadData];
    _manager = manager;
    [[manager didSelectWithBlock:^(UICollectionView *collectionView, FFMatrix matrix, NSInteger section, FFTableCollectionModel *model) {
        if (matrix.column == 0 && [model.type  isEqual: @"aaa"]) {
            if (model.isSelect) {
                [self.datas removeObjectsInRange:NSMakeRange(matrix.row + 1, [self addData:matrix.row + 1].count)];
            } else {
                NSArray *a = [self addData:matrix.row + 1];
                [self.datas insertObjects:a atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(matrix.row + 1, a.count)]];
            }
            model.select = !model.isSelect;
            NSInteger index = matrix.row * Column;
            [collectionView reloadData];
        }
    }] didSelectHeaderWithBlock:^(UICollectionView *collectionView, FFMatrix matrix, NSInteger section, FFTableCollectionModel *model) {
        NSLog(@"%lu....%lu!!!!%lu",matrix.column, matrix.row, section);
    }];
}

- (NSInteger)ffTableManagerColumnSection:(NSInteger)section {
    return Column;
}

- (NSInteger)ffTableManagerRowWithNumberSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat )ffTableManagerItemWidthWithColumn:(NSInteger )column Section:(NSInteger )section margin:(UIEdgeInsets )margin {
    CGFloat w = self.view.bounds.size.width - margin.left - margin.right;
    CGFloat cellWidth = w / Column;
    switch (column) {
        case 0:
            return cellWidth * 2;
            break;
            
        default:
        {
            CGFloat width = (w - cellWidth * 2) / (Column  - 1);
            return width;
        }
            break;
    }
}

- (Class)ffTableManagerRegistClassWithSection:(NSInteger)section {
    return [HeaderCollectionReusableView class];
}

- (void )ffTableManagerSetCollectionHeaderView:(UICollectionReusableView *)ffTableCollectionView section:(NSInteger)section {
    
}

- (CGFloat)ffTableManagerHeaderHeightWithSction:(NSInteger)section {
    return 200;
}

- (nonnull FFTableCollectionModel *)ffTableManagerSetData:(nonnull FFTableManager *)FFTableManager matrix:(FFMatrix)matrix {
    return self.datas[matrix.row][matrix.column];
}

- (NSMutableArray<FFTableCollectionModel *> *)ffTableManagerHeaderViewSetData:(FFTableManager *)FFTableManager section:(NSInteger)section {
    return self.headeraaa;
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

@end
