//
//  ViewController.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "ViewController.h"
#import "FFTableManager.h"

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
    self.scrollView.contentSize = CGSizeMake(0, [manager getTableHeight]);
    _manager = manager;
    
    [[manager didSelectWithBlock:^(FFMatrix matrix, NSInteger section) {
        NSLog(@"%lu....%lu!!!!%lu",matrix.column, matrix.row, section);
    }] didSelectHeaderWithBlock:^(FFMatrix matrix, NSInteger section) {
        NSLog(@"%lu....%lu!!!!%lu",matrix.column, matrix.row, section);
    }];
    
    
}

- (NSInteger)ffTableManagerNumberOfSection {
    return 1;
}

- (NSInteger)ffTableManagerColumnSection:(NSInteger)section {
    return Column;
}

- (NSInteger)ffTableManagerRowWithNumberSection:(NSInteger)section {
    return Row;
}

- (nonnull FFTableCollectionModel *)ffTableManagerSetData:(nonnull FFTableManager *)FFTableManager matrix:(FFMatrix)matrix {
    return self.datas[matrix.row][matrix.column];
}

- (NSMutableArray<FFTableCollectionModel *> *)ffTableManagerHeaderViewSetData:(FFTableManager *)FFTableManager section:(NSInteger)section {
    return self.headeraaa;
}

- (NSMutableArray *)headeraaa {
    if (!_headeraaa) {
        _headeraaa = [NSMutableArray array];
        for (NSString *aaa in @[@"asdasd", @"萨达撒大所多", @"爱上框架的哈萨克接电话", @"sakldjlaksdj", @"sakldjlaksdj", @"sakldjlaksdj"]) {
            FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] bgColor:[UIColor whiteColor]];
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
                FFTableCollectionModel *model = [FFTableCollectionModel tableCollectionModelWithContent:aaa textColor:color font:[UIFont systemFontOfSize:14] bgColor:bgColor];
                [arr addObject:model];
            }
            [_datas addObject:arr];
        }
    }
    return _datas;
}

@end
