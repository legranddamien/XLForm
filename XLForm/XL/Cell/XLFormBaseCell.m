//
//  XLFormBaseCell.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLFormBaseCell.h"

@interface XLFormBaseCell ()

@end

@implementation XLFormBaseCell

- (id)init
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configure];
    }
    return self;
}


-(void)setRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    _rowDescriptor = rowDescriptor;
    self.showSelection = _rowDescriptor.showSelection;
    [self update];
}


- (void)configure
{
    //override
}

- (void)update
{
    // override
}

- (void)setShowSelection:(BOOL)showSelection
{
    if(_showSelection == showSelection) return;
    _rowDescriptor.showSelection = showSelection;
    _showSelection = showSelection;
    
//    CGFloat w = 0;
//    if(_showSelection)
//    {
//        w = 6;
//        if(_selectionView == nil)
//        {
//            UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.bounds.size.height)];
//            selectionView.backgroundColor = [UIColor darkGrayColor];
//            [self addSubview:selectionView];
//            _selectionView = selectionView;
//        }
//    }
//    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
//        _selectionView.frame = CGRectMake(0, 0, w, _selectionView.bounds.size.height);
//        self.indentationWidth = w;
//    } completion:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    if(_selectionView)
//    {
//        CGRect frame = _selectionView.frame;
//        if(frame.size.height != self.contentView.bounds.size.height)
//        {
//            frame.size.height = self.contentView.bounds.size.height;
//            _selectionView.frame = frame;
//        }
//    }
}

-(XLFormViewController *)formViewController
{
    id responder = self;
    while (responder){
        if ([responder isKindOfClass:[UIViewController class]]){
            return responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}


@end
