//
//  FixedTableViewTableViewCell.h
//  PropertyCRM
//
//  Created by fafa on 2019/3/17.
//  Copyright © 2019 blm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTableCollectionModel.h"
#import "FFTableManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface FixedTableViewTableViewCell : UITableViewCell
- (void)showDataWithModel:(FFTableCollectionModel *)model borderColor:(UIColor *)borderColor edge:(UIEdgeInsets )edge size:(CGSize )size currentRow:(NSInteger)currentRow maxRow:(NSInteger)maxRow;
+ (UIFont *)getPhoneFont;
@end

NS_ASSUME_NONNULL_END
