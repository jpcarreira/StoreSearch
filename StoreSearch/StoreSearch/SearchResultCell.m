//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

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


// as table view cells can be reused, we'll cancel image download when the cell get's out of the way by scrolling
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.artworkImageView cancelImageRequestOperation];
    self.nameLabel.text = nil;
    self.artistNameLabel.text = nil;
}


# pragma mark - Instance methods

-(void)configureForSearchResult:(SearchResult *)searchResult
{
    // name label
    self.nameLabel.text = searchResult.name;
    
    // artist name label (also containing info about kind)
    NSString *artistName = searchResult.artistName;
    if(artistName == nil)
    {
        artistName = @"Unknown";
    }
    
    NSString *kind = [searchResult kindForDisplay];
    self.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
    
    // artwork image
    // (while the image is loading the image view will display the placeholder image added to the asset catalog)
    // (getting the 60x60 images, being lighter, will improve image download and overall app performance)
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

@end
