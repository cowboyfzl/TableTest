
//
//  FFCollectionHeaderView.m
//  TableTest
//
//  Created by fafa on 2018/12/31.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFCollectionHeaderView.h"
#import "FFTableCollectionViewCell.h"
@interface FFCollectionHeaderView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *headerCollecionView;
@property (nonatomic, weak) NSMutableArray<FFTableCollectionModel *> *datas;
@property (nonatomic, assign) UIEdgeInsets cellTextMargin;
@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, weak) UIColor *borderColor;
@property (nonatomic, weak) NSArray *sizes;
@property (nonatomic, assign) CollectionViewCellPosition collectionViewCellPosition;
@end

@implementation FFCollectionHeaderView

- (void)collectionHeaderViewWithCellTextMargin:(UIEdgeInsets )cellTextMargin margin:(UIEdgeInsets )margin borderColor:(UIColor *)borderColor collectionViewCellPosition:(CollectionViewCellPosition)collectionViewCellPosition {
    self.cellTextMargin = cellTextMargin;
    self.borderColor = borderColor;
    self.margin = margin;
    self.collectionViewCellPosition = collectionViewCellPosition;
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return _margin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [_sizes[indexPath.row]CGSizeValue];
    return size;
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
    
    CGFloat allSize = 0;
    for (NSNumber *size in _sizes) {
        allSize += [size CGSizeValue].width;
    }
    
    CGFloat offset = self.bounds.size.width - allSize - _margin.left - _margin.right;
    switch (_collectionViewCellPosition) {
        case CollectionViewCellPositionLeft:
            self.headerCollecionView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
            break;
        case CollectionViewCellPositionCenter:
            self.headerCollecionView.frame = CGRectMake(offset / 2, 0, self.bounds.size.width - offset, self.bounds.size.height);
            break;
        case CollectionViewCellPositionRight:
            self.headerCollecionView.frame = CGRectMake(offset, 0, self.bounds.size.width - offset, self.bounds.size.height);
            break;
    }
}

- (float)roundFloat:(float)price{
    return (floorf(price * 100 + 0.5)) / 100;
}

- (UICollectionView *)headerCollecionView {
    if (!_headerCollecionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
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
