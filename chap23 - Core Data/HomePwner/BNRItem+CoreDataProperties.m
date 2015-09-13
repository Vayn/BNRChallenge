//
//  BNRItem+CoreDataProperties.m
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/12.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BNRItem+CoreDataProperties.h"

@implementation BNRItem (CoreDataProperties)

@dynamic itemName;
@dynamic serialNumber;
@dynamic valueInDollars;
@dynamic dateCreated;
@dynamic itemKey;
@dynamic thumbnail;
@dynamic orderingValue;
@dynamic assetType;

@end
