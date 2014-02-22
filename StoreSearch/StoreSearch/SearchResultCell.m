//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"

@implementation SearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// awakeFromNib is called immediatly after this cell object is created from the nib so it's a good method for additional initialization
// awakeFromNis is called after initWithCoder so it is called after the creation of all objects of the nib
-(void)awakeFromNib
{
    // calling the super method (always good idea when overriding a method)
    [super awakeFromNib];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedView.backgroundColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:0.5f];
    self.selectedBackgroundView = selectedView;
}


# pragma mark - Instance methods

-(void)configureForSearchResult:(SearchResult *)searchResult
{
    self.nameLabel.text = searchResult.name;
    
    NSString *artistName = searchResult.artistName;
    if(artistName == nil)
    {
        artistName = @"Unknown";
    }
    
    NSString *kind = [self kindForDisplay:searchResult.kind];
    self.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
}


// "translates" 'kind' from iTunes store to user-friendly text
-(NSString *)kindForDisplay:(NSString *)kind
{
    if([kind isEqualToString:@"album"])
    {
        return @"Album";
    }
    else if([kind isEqualToString:@"audiobook"])
    {
        return @"Audio Book";
    }
    else if([kind isEqualToString:@"book"])
    {
        return @"Book";
    }
    else if([kind isEqualToString:@"ebook"])
    {
        return @"E-Book";
    }
    else if([kind isEqualToString:@"feature-movie"])
    {
        return @"Movie";
    }
    else if([kind isEqualToString:@"music-video"])
    {
        return @"Music Video";
    }
    else if([kind isEqualToString:@"software"])
    {
        return @"App";
    }
    else if([kind isEqualToString:@"song"])
    {
        return @"Song";
    }
    else if([kind isEqualToString:@"tv-episode"])
    {
        return @"TV Episode";
    }
    else
    {
        return kind;
    }
}

@end
