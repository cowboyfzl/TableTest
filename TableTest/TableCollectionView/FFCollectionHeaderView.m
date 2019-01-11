
//
//  FFCollectionHeaderView.m
//  TableTest
//
//  Created by fafa on 2018/12/31.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFCollectionHeaderView.h"
#import "FFTableCollectionViewCell.h"
@interface FFCollectionHeaderView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *headerCollecionView;
@property (nonatomic, strong) NSMutableArray<FFTableCollectionModel *> *datas;
@property (nonatomic, assign) NSInteger textWidth;
@property (nonatomic, assign) UIEdgeInsets cellTextMargin;
@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) NSArray *sizes;
@end

@implementation FFCollectionHeaderView

- (void)collectionHeaderViewWithTextWidth:(CGFloat )textWidth cellTextMargin:(UIEdgeInsets )cellTextMargin margin:(UIEdgeInsets )margin borderColor:(UIColor *)borderColor {
    self.textWidth = textWidth;
    self.cellTextMargin = cellTextMargin;
    self.borderColor = borderColor;
    self.margin = margin;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_headerCollecionView registerNib:[UINib nibWithNibName:NSStringFromClass([FFTableCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class])];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FFTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class]) forIndexPath:indexPath];
    cell.currentMatrix = MatrixMake(0, indexPath.row % _datas.count);
    cell.maxMatrix = MatrixMake(0, _datas.count);
    [cell showDataWithModel:_datas[indexPath.row] borderColor:_borderColor edge:_cellTextMargin size:[_sizes[indexPath.row]CGSizeValue]];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return _margin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_sizes[indexPath.row]CGSizeValue];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FFMatrix matrix = MatrixMake(0, indexPath.row % _datas.count);
    if (self.selectBlock) {
        self.selectBlock(matrix);
    }
}

- (void)showDataWithModel:(NSMutableArray<FFTableCollectionModel *> *)models sizes:(NSArray *)sizes isHover:(BOOL )isHover {
    _sizes = sizes;
    _datas = models;
    [self.headerCollecionView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headerCollecionView.frame = self.bounds;
}

- (UICollectionView *)headerCollecionView {
    if (!_headerCollecionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _headerCollecionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _headerCollecionView.delegate = self;
        _headerCollecionView.dataSource = self;
        _headerCollecionView.backgroundColor = [UIColor whiteColor];
        _headerCollecionView.scrollEnabled = false;
        [_headerCollecionView registerNib:[UINib nibWithNibName:NSStringFromClass([FFTableCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class])];
        [self addSubview:_headerCollecionView];
    }
    return _headerCollecionView;
}

@end
