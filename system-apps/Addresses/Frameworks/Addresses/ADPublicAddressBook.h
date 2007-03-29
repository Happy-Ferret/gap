// ADPublicAddressBook.h (this is -*- ObjC -*-)
// 
// \author: Bj�rn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.1 $
// $Date: 2007/03/29 22:36:04 $

#ifndef ADPUBLICADDRESSBOOK_H
#define ADPUBLICADDRESSBOOK_H

/* system includes */
/* (none) */

/* my includes */
#include "ADAddressBook.h"

@interface ADPublicAddressBook: ADAddressBook
{
  BOOL _readOnly;
  ADAddressBook *_book;
}

- initWithAddressBook: (ADAddressBook*) book
	     readOnly: (BOOL) ro;
@end

@protocol ADSimpleAddressBookServing
- (ADAddressBook*) addressBookForReadOnlyAccessWithAuth: (id) auth;
- (ADAddressBook*) addressBookForReadWriteAccessWithAuth: (id) auth;
@end

#endif /* ADPUBLICADDRESSBOOK_H */
