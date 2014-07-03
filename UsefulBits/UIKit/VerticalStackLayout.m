  //  Copyright (c) 2011, Kevin O'Neill
  //  All rights reserved.
  //
  //  Redistribution and use in source and binary forms, with or without
  //  modification, are permitted provided that the following conditions are met:
  //
  //  * Redistributions of source code must retain the above copyright
  //   notice, this list of conditions and the following disclaimer.
  //
  //  * Redistributions in binary form must reproduce the above copyright
  //   notice, this list of conditions and the following disclaimer in the
  //   documentation and/or other materials provided with the distribution.
  //
  //  * Neither the name UsefulBits nor the names of its contributors may be used
  //   to endorse or promote products derived from this software without specific
  //   prior written permission.
  //
  //  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  //  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  //  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  //  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
  //  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  //  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  //  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  //  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  //  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  //  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "VerticalStackLayout.h"

#import "NSArray+Blocks.h"
#import "NSArray+Access.h"
#import "UIView+Size.h"

#import "UsefulQuartzFunctions.h"

@implementation VerticalStackLayout

@synthesize padding = padding_;
@synthesize contentInsets = contentInsets_;

+ (id)instance;
{
  return [[[[self class] alloc] init] autorelease];
}

- (id)init;
{
  return [self initWithPadding:0 contentInsets:UIEdgeInsetsZero];
}

- (id)initWithPadding:(CGFloat)padding contentInsets:(UIEdgeInsets)insets;
{
  if ((self = [super init]))
  {
    [self setPadding:padding];
    [self setContentInsets:insets];
  }
  
  return self;
}

- (void)layout:(UIView *)view bounds:(CGRect)bounds action:(void (^) (UIView *subview, CGRect subviewFrame))action;
{
  if ([[view subviews] count] == 0) return;
  
  CGRect content_bounds = UIEdgeInsetsInsetRect(bounds, [self contentInsets]);
  CGFloat width = CGRectGetWidth(content_bounds);
  
  CGFloat subview_height = [[[[view subviews] trunk] reduce: ^ id (id height, id subview) {
    CGSize subview_size = [subview sizeThatFits:CGSizeMake(width, 0)];
    CGRect subview_frame = CGRectMake(CGRectGetMinX(content_bounds), [height floatValue], (width > 0) ? width : subview_size.width, subview_size.height);
    
    action(subview, subview_frame);
    
    CGFloat bottom = ceilf(CGRectGetMaxY(subview_frame) + [self padding]);

    return [NSNumber numberWithFloat:bottom];
  } initial:[NSNumber numberWithFloat:CGRectGetMinY(content_bounds)]] floatValue];
  
  UIView *last = [[view subviews] last];
  CGSize last_size = [last sizeThatFits:CGSizeMake(width, 0.)];
  CGRect last_frame = CGRectMake(CGRectGetMinX(content_bounds), subview_height, (width > 0) ? width : last_size.width, last_size.height);

  action(last, last_frame);
}

- (CGSize)sizeThatFits:(CGSize)size view:(UIView *)view;
{
  __block CGRect bounds = CGRectZero;

  [self layout:view bounds:CGRectMakeSized(size) action:^ (UIView *subview, CGRect subviewFrame) {
    bounds = CGRectUnion(bounds, subviewFrame);
  }];
  
  bounds = UB_UIEdgeInsetsOutsetRect(bounds, [self contentInsets]);
  CGSize bounding_size = CGRectIntegral(bounds).size;
  
  return CGSizeMake((size.width > 0) ? size.width : bounding_size.width, MAX(size.height, bounding_size.height));
}

- (void)layoutSubviews:(UIView *)view
{
  [self layout:view bounds:[view bounds] action:^ (UIView *subview, CGRect subviewFrame) {
    [subview setFrame:subviewFrame];
  }];
}

@end


