//
//  XLFormDateCell.m
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


#import "XLForm.h"
#import "XLFormRowDescriptor.h"
#import "XLFormDateCell.h"


@interface XLFormDateCell()

@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) XLFormDatePickerCell *datePickerCell;
@property (nonatomic, strong) NSDate *dateToPutOnDatePicker;

@end

@implementation XLFormDateCell
{
    UIColor * _beforeChangeColor;
}


- (UIView *)inputView
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime]){
        if (self.rowDescriptor.value){
            [self.datePicker setDate:self.rowDescriptor.value];
        }
        [self setModeToDatePicker:self.datePicker];
        return self.datePicker;
    }
    return [super inputView];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)resignFirstResponder
{
    //self.detailTextLabel.textColor = _beforeChangeColor;
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
    {
        NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
        XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
        if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
            XLFormSectionDescriptor * formSection = [self.formViewController.form.formSections objectAtIndex:nextRowPath.section];
            [formSection removeFormRow:nextFormRow];
        }
    }
    return [super resignFirstResponder];
}

#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
    self.formDatePickerMode = XLFormDateDatePickerModeGetFromRowDescriptor;
}

-(void)update
{
    [super update];
    
    self.accessoryType =  UITableViewCellAccessoryNone;
    [self.textLabel setText:self.rowDescriptor.title];
    //self.textLabel.textColor  = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.selectionStyle = self.rowDescriptor.disabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@%@", self.rowDescriptor.title, self.rowDescriptor.required && self.rowDescriptor.sectionDescriptor.formDescriptor.addAsteriskToRequiredRowsTitle ? @"*" : @""];
    [self setTextToDetail:[self valueDisplayText]];
    //self.detailTextLabel.text = [self valueDisplayText];
    //self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
}
- (void)updateDatePickerDate:(NSDate *)date forController:(XLFormViewController *)controller
{
    NSIndexPath * selectedRowPath = [controller.form indexPathOfFormRow:self.rowDescriptor];
    NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:(selectedRowPath.row + 1) inSection:selectedRowPath.section];
    XLFormRowDescriptor * datePickerCellDescriptor = [controller.form formRowAtIndex:nextRowPath];
    XLFormDatePickerCell * datePickerCell = nil;
    
    if(datePickerCellDescriptor)
    {
        datePickerCell = (XLFormDatePickerCell *)[datePickerCellDescriptor cellForFormController:controller];
    }
    
    if(datePickerCell == nil)
    {
        _dateToPutOnDatePicker = date;
    }
    else
    {
        [datePickerCell.datePicker setDate:date animated:YES];
    }
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
    {
        if ([self isFirstResponder]){
            [self resignFirstResponder];
        }
        else{
            [self becomeFirstResponder];
            _beforeChangeColor = self.detailTextLabel.textColor;
            //self.detailTextLabel.textColor = self.formViewController.view.tintColor;
            NSIndexPath * selectedRowPath = [controller.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:(selectedRowPath.row + 1) inSection:selectedRowPath.section];
            XLFormSectionDescriptor * formSection = [controller.form.formSections objectAtIndex:nextRowPath.section];
            XLFormRowDescriptor * datePickerRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeDatePicker];
            XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[datePickerRowDescriptor cellForFormController:controller];
            [self setModeToDatePicker:datePickerCell.datePicker];
            
            BOOL valueChanged = NO;
            
            if(_dateToPutOnDatePicker)
            {
                [datePickerCell.datePicker setDate:_dateToPutOnDatePicker];
                _dateToPutOnDatePicker = nil;
            }
            else if (self.rowDescriptor.value){
                if(((NSDate *)self.rowDescriptor.value).timeIntervalSince1970 < datePickerCell.datePicker.minimumDate.timeIntervalSince1970)
                {
                    [datePickerCell.datePicker setDate:datePickerCell.datePicker.minimumDate];
                    [self datePickerValueChanged:datePickerCell.datePicker];
                }
                else
                {
                    [datePickerCell.datePicker setDate:self.rowDescriptor.value];
                }
            }
            else
            {
                valueChanged = YES;
            }
            
            [datePickerCell.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            [formSection addFormRow:datePickerRowDescriptor afterRow:self.rowDescriptor];
            
            _datePickerCell = datePickerCell;
            if(valueChanged) [self datePickerValueChanged:datePickerCell.datePicker];
        }
        [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime])
    {
        [self becomeFirstResponder];
        [controller.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return YES;
}

#pragma mark - helpers

- (void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
}

-(NSString *)valueDisplayText
{
    return self.rowDescriptor.value ? [self formattedDate:self.rowDescriptor.value] : self.rowDescriptor.noValueDisplayText;
}


- (NSString *)formattedDate:(NSDate *)date
{
    if(self.dateFormatter == nil && self.rowDescriptor.cellConfig && self.rowDescriptor.cellConfig[@"dateFormatter"])
    {
        self.dateFormatter = self.rowDescriptor.cellConfig[@"dateFormatter"];
    }
    
    if (self.dateFormatter){
        return [self.dateFormatter stringFromDate:date];
    }
    
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline]){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline]){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

-(void)setModeToDatePicker:(UIDatePicker *)datePicker
{
    if ((([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate]) && self.formDatePickerMode == XLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == XLFormDateDatePickerModeDate){
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ((([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime]) && self.formDatePickerMode == XLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == XLFormDateDatePickerModeTime){
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else{
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    if (self.minuteInterval)
        datePicker.minuteInterval = self.minuteInterval;
    
    if (self.minimumDate)
        datePicker.minimumDate = self.minimumDate;
    
    if (self.maximumDate)
        datePicker.maximumDate = self.maximumDate;
    
    if (self.timeZone)
    {
        datePicker.timeZone = self.timeZone;
        datePicker.calendar = [NSCalendar currentCalendar];
        [_dateFormatter setTimeZone:self.timeZone];
    }
}

#pragma mark - Properties

-(UIDatePicker *)datePicker
{
    if (_datePicker) return _datePicker;
    _datePicker = [[UIDatePicker alloc] init];
    [self setModeToDatePicker:_datePicker];
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return _datePicker;
}


#pragma mark - Target Action

- (void)datePickerValueChanged:(UIDatePicker *)sender
{
    [self setTextToDetail:[self formattedDate:sender.date]];
    
    self.rowDescriptor.value = sender.date;
    [self setNeedsLayout];
    
}

- (void)setTextToDetail:(NSString *)text
{
    if(text == nil)
    {
        self.detailTextLabel.text = text;
    }
    else
    {
        NSDictionary *attributes;
        
        if(_showError)
        {
            attributes = @{NSStrikethroughStyleAttributeName : @1, NSForegroundColorAttributeName : [UIColor colorWithRed:0.890 green:0.204 blue:0.141 alpha:1.000]};
        }
        else
        {
            attributes = @{NSStrikethroughStyleAttributeName : @0, NSForegroundColorAttributeName : [UIColor colorWithWhite:0.133 alpha:1.000]};
        }
        
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
}

-(void)setFormDatePickerMode:(XLFormDateDatePickerMode)formDatePickerMode
{
    _formDatePickerMode = formDatePickerMode;
    if ([self isFirstResponder]){
        if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
        {
            NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
            XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
            if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
                XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[nextFormRow cellForFormController:self.formViewController];
                [self setModeToDatePicker:datePickerCell.datePicker];
            }
        }
    }
}

@end
