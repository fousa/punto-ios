// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Feed.h instead.

#import <CoreData/CoreData.h>


extern const struct FeedAttributes {
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *link;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *notify;
	__unsafe_unretained NSString *uniqueIdentifier;
} FeedAttributes;

extern const struct FeedRelationships {
} FeedRelationships;

extern const struct FeedFetchedProperties {
} FeedFetchedProperties;








@interface FeedID : NSManagedObjectID {}
@end

@interface _Feed : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FeedID*)objectID;





@property (nonatomic, strong) NSDate* lastUpdated;



//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* link;



//- (BOOL)validateLink:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notify;



@property BOOL notifyValue;
- (BOOL)notifyValue;
- (void)setNotifyValue:(BOOL)value_;

//- (BOOL)validateNotify:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueIdentifier;



//- (BOOL)validateUniqueIdentifier:(id*)value_ error:(NSError**)error_;






@end

@interface _Feed (CoreDataGeneratedAccessors)

@end

@interface _Feed (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSDate*)value;




- (NSString*)primitiveLink;
- (void)setPrimitiveLink:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveNotify;
- (void)setPrimitiveNotify:(NSNumber*)value;

- (BOOL)primitiveNotifyValue;
- (void)setPrimitiveNotifyValue:(BOOL)value_;




- (NSString*)primitiveUniqueIdentifier;
- (void)setPrimitiveUniqueIdentifier:(NSString*)value;




@end
