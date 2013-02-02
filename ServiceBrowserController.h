/**
 * @file ServiceBrowserController.h
 * 
 * @author Perry Spagnola
 * @date 2/19/11 - created
 * @version 1.0
 * @brief Header file for the <code>interface</code> of the ServiceBrowserController class.
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
#import "ResolvedService.h"



@interface ServiceBrowserController : NSObject {
//    BOOL isConnected;
    NSNetServiceBrowser *browser;
    NSNetService *connectedService;
    NSMutableArray *services;
    NSMutableArray *foundServices;
	ResolvedService *resolvedService;
	int serviceCount;
	
    IBOutlet NSArrayController *servicesController;
	IBOutlet NSArrayController *serviceTypes;
	IBOutlet NSArrayController *networkNodes;
	IBOutlet NSProgressIndicator *scanProgressIndicator;
}

@property (readwrite, retain) NSNetServiceBrowser *browser;
@property (readonly, retain) NSMutableArray *services;
@property (readonly, retain) NSMutableArray *foundServices;
//@property (readonly, assign) BOOL isConnected;
@property (readwrite, retain) NSNetService *connectedService;
@property (readwrite, retain) ResolvedService *resolvedService;
@property (readwrite, assign) int serviceCount;

-(IBAction)scan:(id)sender;

@end
