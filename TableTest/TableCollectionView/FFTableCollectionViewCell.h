//
//  FFTableCollectionViewCell.h
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTableCollectionModel.h"
#import "FFTableManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFTableCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) FFMatrix currentMatrix;
@property (nonatomic, assign) FFMatrix maxMatrix;
@property (nonatomic, getter=ishaveHeader) BOOL haveHeader;
- (void)showDataWithModel:(FFTableCollectionModel *)model borderColor:(UIColor *)borderColor edge:(UIEdgeInsets )edge size:(CGSize )size;
+ (UIFont *)getPhoneFont;
@end

NS_ASSUME_NONNULL_END
