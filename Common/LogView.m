//
//  LogView.m
//  TapdaqExamples
//
//  Created by Dmitry Dovgoshliubnyi on 02/04/2019.
//

#import "LogView.h"
NSString *const LogViewCellIdentifier = @"LogViewCellIdentifier";

@interface LogEntry : NSObject
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *message;
@end
@implementation LogEntry
@end

@interface LogEntryCell : UITableViewCell
@property (strong, nonatomic) UILabel *labelMessage;
@end

@implementation LogEntryCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier  {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.labelMessage = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelMessage.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessage.font = [UIFont monospacedDigitSystemFontOfSize:9 weight:UIFontWeightMedium];
    self.labelMessage.numberOfLines = 0;
    [self.contentView addSubview:self.labelMessage];
    
    id views = @{ @"labelMessage" : self.labelMessage };
    id verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[labelMessage]|" options:0 metrics:@{} views:views];
    id horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[labelMessage]|" options:0 metrics:@{} views:views];
    [self.contentView addConstraints:verticalConstraints];
    [self.contentView addConstraints:horizontalConstraints];
}
@end


@interface LogView () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *logEntries;
@end

@implementation LogView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)log:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    LogEntry *entry = [[LogEntry alloc] init];
    entry.message = message;
    entry.date = NSDate.date;
    
    @synchronized (self.logEntries) {
        [self.logEntries addObject:entry];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.logEntries.count > 0) {
            NSIndexPath *bottomMostIndexPath = [NSIndexPath indexPathForRow:[self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0] - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:bottomMostIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
   
}

- (void)setup {
    self.logEntries = NSMutableArray.array;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:LogEntryCell.class forCellReuseIdentifier:LogViewCellIdentifier];
    [self addSubview:self.tableView];
    id views = @{ @"tableView" : self.tableView };
    id verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:@{} views:views];
    id horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:@{} views:views];
    [self addConstraints:verticalConstraints];
    [self addConstraints:horizontalConstraints];
}
- (void)didMoveToWindow {
    [super didMoveToWindow];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogEntryCell *cell = (LogEntryCell *)[tableView dequeueReusableCellWithIdentifier:LogViewCellIdentifier];
    LogEntry *entry = self.logEntries[indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = NSLocale.currentLocale;
    formatter.dateFormat = @"HH:mm:ss.SS";
    cell.labelMessage.text = [NSString stringWithFormat:@"%@: %@",[formatter stringFromDate:entry.date], entry.message];
    
    return cell;
}

@end
