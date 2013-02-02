/**
 * @file WakeOnLAN_AppDelegate.m
 *
 * @author Perry Spagnola 
 * @date 2/7/11 - created
 * @version 1.0
 * @brief The app delegate for the Wake On LAN application.
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

#import "WakeOnLAN_AppDelegate.h"
#import "StatusValueTransformer.h"
#import "ResolvedService.h"


@implementation WakeOnLAN_AppDelegate

@synthesize window;


/**
 * Returns the support directory for the application, used to store the Core Data
 * store file.  This code uses a directory named "WakeOnLAN" for
 * the content, either in the NSApplicationSupportDirectory location or (if the
 * former cannot be found), the system's temporary directory.
 * @return an NSString object containing the application support directory.
 */
- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"WakeOnLAN"];
}


/**
 * Creates, retains, and returns the managed object model for the application 
 * by merging all of the models found in the application bundle.
 * @see NSManagedObjectModel
 * @return the managed oject model object
 */ 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 * Returns the persistent store coordinator for the application.  This 
 * implementation will create and return a coordinator, having added the 
 * store for the application to it.  (The directory for the store is created, 
 * if necessary.)
 * @see NSPersistentStoreCoordinator
 * @return the persistent storage coordinator object
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}


/**
 * Returns the managed object context for the application (which is already
 * bound to the persistent store coordinator for the application.)
 * @see NSManagedObjectContext
 * @return the managed object context
 */
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}


/**
 * Returns the NSUndoManager for the application.  In this case, the manager
 * returned is that of the managed object context for the application.
 * @see NSUndoManager
 * @return the undo manager object
 */ 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
 * Performs the save action for the application, which is to send the save:
 * message to the application's managed object context.  Any encountered errors
 * are presented to the user.
 * @param sender  the object that sent the action
 * @see IBAction
 * @return the IBAction object
 */
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
	
	NSLog(@"called saveAction()...");
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
 * Performs the wake action for the application, which is to send the Wake on LAN
 * Magic Packet using the selected network node's MAC address.  Any encountered 
 * errors are presented to the user.
 * @param sender  the object that sent the action
 * @see IBAction
 * @return the IBAction object
 */
- (IBAction)wakeAction:(id)sender {
	
	/**
	 * Get the MAC address for the selected network node.
	 */
	NSArray *selected = [networkNodes selectedObjects];
	NSString *macAddr = [[selected valueForKey:@"macAddr"] objectAtIndex:0];
    NSLog(@"MAC Address: %@", macAddr);

	/**
	 * Convert the NString object to a char * for the send_wol() function. Use
	 * an explicit cast to get rid of the warning for losing the const context
	 * returned by UTF8String.
	 */
	char *str = (char *)[macAddr UTF8String];
	
	/**
	 * Some DEBUG output to make sure we are getting the correct MAC address.
	 */
    NSLog(@"MAC Address: %s", str);
	
	/**
	 * Build the Magic Packet and send it.
	 */
	send_wol(str);
	
	/**
	 * Test code for changing the status indicator in the table view.
	 * TBD: Move to a thread that monitors status of the network nodes.
	 *
	 * [networkNodes setValue:[NSNumber numberWithBool:[sender intValue]] forKeyPath:@"selection.status"];
     */
}


/**
 * Adds the selected service host from the Service Browser to the persistent store as a managed object.
 * Inserts a new managed object for the NetworkNode entity, and sets its values from the selected
 * resolved service in the Service Browser. Stores the service type, as well, and creates the
 * relationship between service and node.
 * @param sender  the object that sent the action
 * @see IBAction
 * @see NSManagedObject
 * @see NSEntityDescription
 * @return the IBAction object
 */
-(IBAction)addSelectedServiceHost:(id)sender {
	
	/**
	 * Retrieve the array of selected objects from the service browser. Note that
	 * the object we want is at index 0.
	 */
	NSArray *selectedResolvedServices = [serviceBrowser selectedObjects];
	NSString *host = [[selectedResolvedServices objectAtIndex:0] valueForKey:@"host"];
	
	/**
	 * Check to see if the managed object for this network node already exists.
	 * If it doesn't, create it.
	 */
	NSManagedObject *newNetworkNode = [self managedObjectExistsFor:host forKey:@"host" forEntity:@"NetworkNode"];
	if (newNetworkNode == nil) {
		/**
		 * Managed Object doesn't exist yet. Insert a new managed object to save the selected service host.
		 */
		newNetworkNode = [NSEntityDescription insertNewObjectForEntityForName:@"NetworkNode" inManagedObjectContext:managedObjectContext];
		
		/**
		 * Set values for the managed object's attributes. Note that we are updating from the first object in the array.
		 */
		[newNetworkNode setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"host"] forKey:@"host"];
		[newNetworkNode setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"domain"] forKey:@"domain"];
		[newNetworkNode setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"ipAddr"] forKey:@"ipAddr"];
		[newNetworkNode setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"macAddr"] forKey:@"macAddr"];
		[newNetworkNode setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"icon"] forKey:@"icon"];
	}

	/**
	 * Check to see if the managed object for this network node's service already exists.
	 * If it doesn't, create it.
	 */
	NSString *serviceID = [[selectedResolvedServices objectAtIndex:0] valueForKey:@"type"];
	NSManagedObject *newService = [self managedObjectExistsFor:serviceID forKey:@"identifier" forEntity:@"Service"];
	if (newService == nil) {
		NSLog(@"DEBUG: service == nil...");
		/**
		 * Managed Object doesn't exist yet. Insert a new managed object to save the selected service.
		 */
		newService = [NSEntityDescription insertNewObjectForEntityForName:@"Service" inManagedObjectContext:managedObjectContext];
		[newService setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"type"] forKey:@"identifier"];
		[newService setValue:[(ResolvedService*) [selectedResolvedServices objectAtIndex:0] valueForKey:@"name"] forKey:@"name"];
		//NSLog(@"network node: %@", newNetworkNode);
		NSSet *netNodeRelationships = [NSSet setWithObject:newNetworkNode];
		
		//NSLog(@"network node relationships: %@", netNodeRelationships);
		[newService setValue:netNodeRelationships forKey:@"networkNodes"];
	}
	else {
		/**
		 * Managed Object for service exists. Check to see if the managed object for this
		 * network node already has a relationship to this specific Bonjour service.
		 */
		NSSet *existingServiceIDs = [newNetworkNode valueForKeyPath:@"services.identifier"];
		if (![existingServiceIDs containsObject:[newService valueForKey:@"identifier"]]) {
			/**
			 * Doesn't have the relationship to the service. Get the existing set of
			 * services, if any, and add the new service to the set. Set the new
			 * set object as the value for the services relationship for this network node.
			 */
			NSLog(@"existingServices does not contains service: %@", [newService valueForKey:@"identifier"]);
			NSSet *existingServices = [newNetworkNode valueForKeyPath:@"services"];
			NSSet *new = [existingServices setByAddingObject:newService];
			[newNetworkNode setValue:new forKey:@"services"];
		}
	}
}


/**
 * Checks to see if a managed object exists. The managed object is defined by
 * its entity name, a specific key and its corresponding value.
 * @param value the value to test for
 * @param keyName the key path of the value to test for
 * @param entityName the name of the entity in which to look for the key value pair
 * @return the managed object, if it is found, <code>nil</code> if not 
 */
-(NSManagedObject *) managedObjectExistsFor:(NSString *)value forKey:(NSString *)keyName forEntity:(NSString *)entityName {
	
	NSManagedObject *managedObject = nil;
	
	/**
	 * Create a fetch request to retrieve the argument defined entity for this context
	 * if it exists.
	 */
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	/**
	 * Create the predicate for the fetch request that specifies the host of
	 * the selected resolved service to add.
	 */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@)", keyName, value];
	// DEBUG: NSLog(@"predicate: %@", predicate);
	[request setPredicate:predicate];
	
	/**
	 * Attempt to fetch the NetworkNode managed object.
	 */
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	// DEBUG: NSLog(@"array: %@", array);
	if ([array count] != 0) {
		/**
		 * Array count for the fetch request return is not zero (0). Found an instance.
		 * Set the return value to the first object in the array.
		 */
		managedObject = [array objectAtIndex:0];
		if ([array count] > 1) {
			/**
			 * Array count for the fetch request return is greater than one (1). Found
			 * more than one instance. Should only be one. Log the anomoly.
			 */
			NSLog(@"%@: %@, has more than one instance.", entityName, value);
		}
	}
	
	return managedObject;
}


/**
 * Implementation of the applicationShouldTerminateAfterLastWindowClosed: method, used 
 * here to handle the terminating of the application when the last open window is closed.
 * @param theApplication pointer to the NSApplication object
 * @return always returns YES
 */
-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	/**
	 * Get the array of Network Node objects.
	 */
	NSArray *array = [networkNodes arrangedObjects];
	for (int i=0; i<[array count]; i++) {
		// DEBUG: NSLog(@"node: %@", [[array objectAtIndex:i] host]);
		/**
		 * Iterate through the array, and set the status of each node to <code>NO</code>.
		 */
		[[array objectAtIndex:i]setValue:NO forKey:@"status"];
	}
	
	return YES;
}


/**
 * Implementation of the applicationShouldTerminate: method, used here to
 * handle the saving of changes in the application managed object context
 * before the application terminates.
 * @param sender  the object that sent the terminate
 * @see NSApplicationTerminateReply
 * @return the terminate reply object
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        /**
		 * TO DO: 
		 * The error handling simply presents error information in a panel with an 
		 * "Ok" button, which does not include any attempt at error recovery (meaning, 
		 * attempting to fix the error.)  As a result, this implementation will 
		 * present the information to the user and then follow up with a panel asking 
		 * if the user wishes to "Quit Anyway", without saving the changes.
		 * This process should be altered to include application-specific 
		 * recovery steps. 
         */  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
 * Implementation of dealloc, to release the retained variables.
 */ 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}

@end
