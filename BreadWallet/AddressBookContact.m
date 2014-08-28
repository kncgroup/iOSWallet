

#import "AddressBookContact.h"

@implementation AddressBookContact

-(id)initWithContact:(AddressBookContact*)contact
{
    self = [super init];
    if(self){
        self.phone = contact.phone;
        self.name = contact.name;
        self.address = contact.address;
        self.source = contact.source;
    }
    return self;
}

@end
