
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "KnCDocument.h"
@interface KnCBackupUtil : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSURL *ubiquitousURL;

-(void)iCloudBackupWordSeed:(void (^)(BOOL success, NSString * message))completion;
-(BOOL)emailBackup:(NSString*)key delegate:(UIViewController<MFMailComposeViewControllerDelegate>*)sender;
-(void)allBackups:(void (^)(BOOL success, NSArray *seeds, NSString *message))completion;
-(void)openDocument:(NSString*)fileName completionCallback:(void (^)(BOOL success, KnCDocument * document, NSString *message))completion;
-(NSString*)decryptDocumentContent:(KnCDocument*)document withKey:(NSString*)key;
-(NSString*)decrypt:(NSString*)content withKey:(NSString*)key;
@end
