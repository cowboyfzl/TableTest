//
//  FFMainScrollView.m
//  PropertyCRM
//
//  Created by blm on 2019/4/28.
//  Copyright © 2019 blm. All rights reserved.
//

#import "FFMainScrollView.h"

@interface FFMainScrollView () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) BOOL isScroll;
@end

@implementation FFMainScrollView

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    FFMainScrollView *scrollView = [super allocWithZone:zone];
    scrollView.isScroll = true;
    scrollView.delegate = scrollView;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    return scrollView;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = self.contentSize.width - self.bounds.size.width;
    if (self.contentOffset.x < 0) {
        self.contentOffset = CGPointZero;
    }
    
    if (self.contentOffset.x >= offset) {
        _isScroll = false;
        self.contentOffset = CGPointMake(offset - 1, 0);
    } else if (self.contentOffset.x < (offset - 1)) {
         _isScroll = true;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        UIScrollView *view = (UIScrollView *)gestureRecognizer.view;
        CGPoint velocity = [pan velocityInView:self];
        if(velocity.x > 0) {
            return view.contentOffset.x <= 1;
        } else {
            
            return self.contentSize.width - self.bounds.size.width - 1 <= view.contentOffset.x;
        }
    }
    return false;
//
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (_isScroll && [touch.view isDescendantOfView:self]) {
//        return true;
//    } else {
//        return false;
//    }
//}
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    _isScroll = [view isDescendantOfView:self];
//    return view;
//}

@end
