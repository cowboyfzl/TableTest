//
//  FixedTableViewTableViewCell.m
//  PropertyCRM
//
//  Created by fafa on 2019/3/17.
//  Copyright © 2019 blm. All rights reserved.
//

#import "FixedTableViewTableViewCell.h"
#import "FFTableCollectionViewCell.h"
@interface FixedTableViewTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *textLRMargins;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@end

@implementation FixedTableViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView.layer addSublayer:self.borderLayer];
    // Initialization code
}

- (void)showDataWithModel:(FFTableCollectionModel *)model borderColor:(UIColor *)borderColor edge:(UIEdgeInsets )edge size:(CGSize )size currentRow:(NSInteger)currentRow maxRow:(NSInteger)maxRow {
    _contentLabel.textColor = model.textColor ?: [UIColor blackColor];
    _contentLabel.font = model.font?: [FFTableCollectionViewCell getPhoneFont];
    _contentLabel.text = model.content;
    self.contentView.backgroundColor = model.bgColor?: [UIColor whiteColor];
    _borderLayer.strokeColor = borderColor.CGColor ?: [UIColor lightGrayColor].CGColor;
    NSInteger i = 0;
    for (NSLayoutConstraint *constraint in _textLRMargins) {
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
    
    [self setFrameWithSize:size currentRow:currentRow maxRow:maxRow];
}

- (void)setFrameWithSize:(CGSize )size currentRow:(NSInteger)currentRow maxRow:(NSInteger)maxRow {
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (currentRow != maxRow - 1) {
        [path moveToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, size.height - (FFTableCollectionViewCellLineOffst * 2))];
        [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, FFTableCollectionViewCellLineOffst)];
        [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), FFTableCollectionViewCellLineOffst)];
    } else {
        [path moveToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), size.height - (FFTableCollectionViewCellLineOffst * 2))];
        [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, size.height - (FFTableCollectionViewCellLineOffst * 2))];
        [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, FFTableCollectionViewCellLineOffst)];
        [path addLineToPoint:CGPointMake(size.width - (FFTableCollectionViewCellLineOffst * 2), FFTableCollectionViewCellLineOffst)];
    }
    
    _borderLayer.path = path.CGPath;
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
