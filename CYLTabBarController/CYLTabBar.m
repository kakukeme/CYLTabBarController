//
//  CYLTabBar.m
//  CYLCustomTabBarDemo
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 10/20/15.
//  Copyright © 2015 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLTabBar.h"

@interface CYLTabBar ()

/** 发布按钮 */
@property (nonatomic, strong) UIButton<CYLPlusButtonSubclassing> *plusButton;

@end

@implementation CYLTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (instancetype)sharedInit {
    if (CYLExternPushlishButton) {
        self.plusButton = CYLExternPushlishButton;
        [self addSubview:(UIButton *)self.plusButton];
    }
    [self setBackgroundImage:[self imageWithColor:[UIColor whiteColor]]];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CYLExternPushlishButton) {
        return;
    }
    CGFloat barWidth = self.frame.size.width;
    CGFloat barHeight = self.frame.size.height;
    
    CGFloat tabBarButtonW = (CGFloat) barWidth / (CYLTabbarItemsCount + 1);
    NSInteger buttonIndex = 0;
    CGFloat multiplerInCenterY;
    if ([[self.plusButton class] respondsToSelector:@selector(multiplerInCenterY)]) {
        multiplerInCenterY = [[self.plusButton class] multiplerInCenterY];
    } else {
        CGSize sizeOfPlusButton = self.plusButton.frame.size;
        CGFloat heightDifference = sizeOfPlusButton.height - self.bounds.size.height;
        if (heightDifference < 0) {
            multiplerInCenterY = 0.5;
        } else {
            CGPoint center = CGPointMake(self.bounds.size.height / 2.0f, self.bounds.size.height / 2.0f);
            center.y = center.y - heightDifference / 2.0f;
            multiplerInCenterY = center.y / self.bounds.size.height;
        }
    }
    
    self.plusButton.center = CGPointMake(barWidth * 0.5, barHeight * multiplerInCenterY);
    
    NSUInteger plusButtonIndex;
    if ([[self.plusButton class] respondsToSelector:@selector(indexOfPlusButtonInTabBar)]) {
        if (CYLTabbarItemsCount % 2 == 0) {
            [NSException raise:@"CYLTabBarController" format:@"If the count of CYLTabbarControllers is not odd,there's no need to realizse `+indexOfPlusButtonInTabBar` in your custom plusButton class.【中文】如果CYLTabbarControllers的个数不是奇数，会自动居中，你无需在你自定义的plusButton中实现`+indexOfPlusButtonInTabBar`，来指定plusButton的位置"];
        }
        plusButtonIndex = [[self.plusButton class] indexOfPlusButtonInTabBar];
        //仅修改self.plusButton的x,ywh值不变
        self.plusButton.frame = CGRectMake(plusButtonIndex * tabBarButtonW,
                                           CGRectGetMinY(self.plusButton.frame),
                                           CGRectGetWidth(self.plusButton.frame),
                                           CGRectGetHeight(self.plusButton.frame)
                                           );
    } else {
        if (CYLTabbarItemsCount % 2 != 0) {
            [NSException raise:@"CYLTabBarController" format:@"If the count of CYLTabbarControllers is odd,you must realizse `+indexOfPlusButtonInTabBar` in your custom plusButton class.【中文】如果CYLTabbarControllers的个数是奇数，你必须在你自定义的plusButton中实现`+indexOfPlusButtonInTabBar`，来指定plusButton的位置"];
        }
        plusButtonIndex = CYLTabbarItemsCount / 2.0;
    }
    /* NOTE: If the `self.title of ViewController` and `the correct title of tabBarItemsAttributes` are different, Apple will delete the correct tabBarItem from subViews, and then trigger `-layoutSubviews`, therefore subViews will be in disorder. So we need to rearrange them.*/
    NSArray *sortedSubviews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView * view1, UIView * view2) {
        CGFloat view1_x = view1.frame.origin.x;
        CGFloat view2_x = view2.frame.origin.x;
        if (view1_x > view2_x) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    for (UIView *childView in sortedSubviews) {
        //调整加号按钮后面的UITabBarItem的位置
        if ([childView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (buttonIndex == plusButtonIndex) {
                buttonIndex++;
            }
            //仅修改childView的x和宽度,yh值不变
            childView.frame = CGRectMake(buttonIndex * tabBarButtonW,
                                         CGRectGetMinY(childView.frame),
                                         tabBarButtonW,
                                         CGRectGetHeight(childView.frame)
                                         );
            buttonIndex++;
        }
    }
    //bring the plus button to top
    [self bringSubviewToFront:self.plusButton];
}

/*
 *
 Capturing touches on a subview outside the frame of its superview
 *
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        UIView *result = [super hitTest:point withEvent:event];
        if (result) {
            return result;
        } else {
            for (UIView *subview in self.subviews.reverseObjectEnumerator) {
                CGPoint subPoint = [subview convertPoint:point fromView:self];
                result = [subview hitTest:subPoint withEvent:event];
                if (result) {
                    return result;
                }
            }
        }
    }
    return nil;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    NSParameterAssert(color != nil);
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
