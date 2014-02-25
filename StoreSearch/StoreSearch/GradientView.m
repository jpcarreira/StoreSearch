//
//  GradientView.m
//  StoreSearch
//
//  Created by João Carreira on 23/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // setting the background to fully transparent
        self.backgroundColor = [UIColor clearColor];
        
        // auto-resizing
        // (we can't use auto-layout because we don't have a nib)
        // this will make the current view change its width and height proporcionally when the superview
        // it belongs to changes its size as well (due to rotation to portrait/landscape)
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}


// this draws the gradient on top of the background set in initWithFrame:
- (void)drawRect:(CGRect)rect
{
    // two components: black color mostly transparent and black color less transparent
    const CGFloat components[8] = { 0.0f, 0.0f, 0.0f, 0.3f,
                                    0.0f, 0.0f, 0.0f, 0.7f };
    
    // being a circular grandient, we'll use 0 for the centre of the circunference and 1.0 for it's radius
    const CGFloat locations[2] = { 0.0f, 1.0f };

    // loading components and locations to the respective data structures
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
    
    // releasing the space
    CGColorSpaceRelease(space);
    
    // getting the center point of a rectangle (in this case, the view)
    CGFloat x = CGRectGetMidX(self.bounds);
    CGFloat y = CGRectGetMidY(self.bounds);
    
    // view center
    CGPoint point = CGPointMake(x, y);
    
    // maximum point in the view
    CGFloat radius = MAX(x, y);
    
    // drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // drawing the gradient
    CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, kCGGradientDrawsAfterEndLocation);
    
    // releasing the gradient
    CGGradientRelease(gradient);
}


@end
