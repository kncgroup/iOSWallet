
#import <UIKit/UIKit.h>

@interface KnCRequestPaymentViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *qrImageView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *btcField;
@property (nonatomic, weak) IBOutlet UITextField *fiatField;
@property (nonatomic, weak) IBOutlet UIButton *btcButton;
@property (nonatomic, weak) IBOutlet UIButton *fiatButton;


@end
