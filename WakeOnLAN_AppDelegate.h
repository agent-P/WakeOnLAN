/**
 * @file WakeOnLAN_AppDelegate.h
 *
 * @author Perry Spagnola
 * @date 2/7/11 - created
 * @version 1.0
 * @brief Header file for the <code>interface</code> of the WakeOnLAN_AppDelegate class.
 *
 * @copyright Copyright 2011 Perry M. Spagnola. All rights reserved.
 *
 * @section LICENSE
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details at
 * http://www.gnu.org/copyleft/gpl.html
 */

#import <Cocoa/Cocoa.h>
#import "wol_lib.h"

@interface WakeOnLAN_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	IBOutlet NSArrayController *networkNodes;
	IBOutlet NSArrayController *serviceBrowser;

	
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)wakeAction:sender;
- (IBAction)addSelectedServiceHost:sender;
- (NSManagedObject *)managedObjectExistsFor:(NSString *)value forKey:(NSString *)keyName forEntity:(NSString *)entityName;

@end
