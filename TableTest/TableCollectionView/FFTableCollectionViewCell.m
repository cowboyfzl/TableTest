//
//  FFTableCollectionViewCell.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFTableCollectionViewCell.h"

@interface FFTableCollectionViewCell () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *LabelOffsets;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@end
NSInteger const FFTableCollectionViewWidth = 1;
CGFloat const FFTableCollectionViewCellLineOffst = 0.2;
@implementation FFTableCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _haveHeader = false;
    [self.contentView.layer addSublayer:self.borderLayer];
    // Initialization code
}

- (void)showDataWithModel:(FFTableCollectionModel *)model borderColor:(UIColor *)borderColor edge:(UIEdgeInsets )edge size:(CGSize )size {
    _contentLabel.textColor = model.textColor ?: [UIColor blackColor];
    _contentLabel.font = model.font?: [FFTableCollectionViewCell getPhoneFont];
    _contentLabel.text = model.content;
    self.contentView.backgroundColor = model.bgColor?: [UIColor whiteColor];
    _borderLayer.strokeColor = borderColor.CGColor ?: [UIColor lightGrayColor].CGColor;
    NSInteger i = 0;
    for (NSLayoutConstraint *constraint in _LabelOffsets) {
        switch (i) {
            case 0:
                constraint.constant = edge.right;
                break;
                
            case 1:
                constraint.constant = edge.left;
                break;
        }
        i += 1;
    }
    [self setFrameWithSize:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setFrameWithSize:(CGSize )size {
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (self.isHeader) {
        if (_currentMatrix.row == 0 && _currentMatrix.column == 0) {
            [path moveToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, size.height - (FFTableCollectionViewCellLineOffst * 2))];
            [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, FFTableCollectionViewCellLineOffst)];
            
            [path moveToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), FFTableCollectionViewCellLineOffst)];
            [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), size.height - (FFTableCollectionViewCellLineOffst * 2))];
        }
        
        if (_currentMatrix.row == 0 && _currentMatrix.column > 0) {
            [path moveToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), FFTableCollectionViewCellLineOffst)];
            [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), size.height - (FFTableCollectionViewCellLineOffst * 2))];
        }
        
        if (_currentMatrix.row > 0) {
            [self drawPath:path size:size];
        } else {
            if (_currentMatrix.row == _maxMatrix.row ) {
                [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst , size.height - (FFTableCollectionViewCellLineOffst * 2))];
            }
        }
        
    } else {
        [self drawPath:path size:size];
    }
    
    _borderLayer.path = path.CGPath;
}

- (void )drawPath:(UIBezierPath *)path size:(CGSize )size {
    if (_currentMatrix.column == 0) {
        [path moveToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, size.height - (FFTableCollectionViewCellLineOffst * 2))];
        [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, FFTableCollectionViewCellLineOffst)];
        [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), FFTableCollectionViewCellLineOffst)];
        if (!self.isLeft) {
            [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), size.height - FFTableCollectionViewCellLineOffst)];
        }
    }
    
    if (_currentMatrix.column > 0) {
        [path moveToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, FFTableCollectionViewCellLineOffst)];
        [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), FFTableCollectionViewCellLineOffst)];
        [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), size.height - (FFTableCollectionViewCellLineOffst * 2))];
    }
    
    if (_currentMatrix.row == _maxMatrix.row) {
        if (self.isLeft) {
            [path moveToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, size.height - (FFTableCollectionViewCellLineOffst * 2))];
            [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), size.height - (FFTableCollectionViewCellLineOffst * 2))];
        } else {
            [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst , size.height - (FFTableCollectionViewCellLineOffst * 2))];
        }
    }
}

+ (UIFont *)getPhoneFont {
    UIFont *font;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    ScreenType type = screenWidth;
    switch (type) {
        case ScreenType320:
            font = [UIFont systemFontOfSize:12];
            break;
            
        case ScreenType375:
            font = [UIFont systemFontOfSize:14];
            break;
            
        case ScreenType414:
            font = [UIFont systemFontOfSize:15];
            break;
    }
    return font;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        _borderLayer.borderWidth = FFTableCollectionViewWidth;
    }
    return _borderLayer;
}
@end
