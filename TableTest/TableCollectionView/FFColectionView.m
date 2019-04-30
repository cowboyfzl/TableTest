//
//  FFColectionView.m
//  PropertyCRM
//
//  Created by blm on 2019/4/28.
//  Copyright © 2019 blm. All rights reserved.
//

#import "FFColectionView.h"

@interface FFColectionView ()<UIGestureRecognizerDelegate>

@end

@implementation FFColectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:touch.view];
    
    return[touch.view isDescendantOfView:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return view;
}
@end
