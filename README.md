#SumUp custom URL scheme

Using the custom SumUp URL scheme you can accept card payments from your iOS app or website through the SumUp iOS app.
 To get started you will need to create a SumUp account and get an affiliate key in our [Developer section](https://me.sumup.com/developers).

If you are going to open the SumUp app from your own iOS app, [SMPPaymentRequest](#smppaymentrequest) is a convenient way to do so. See the sample app project for details and examples. You might also want to take a look at the [SumUp iOS SDK](https://github.com/sumup/sumup-ios-sdk) to accept payments within your app.  
If you are planning to open the SumUp app using a URL, please find the parameters below.

## Base URL
`sumupmerchant://pay/1.0`

## Mandatory query parameters

| Key            | Comment |
| ---------------|:------- |
|`amount`        | The amount to charge. Please use `.` as a decimal separator. |
|`currency`      | The ISO 4217 code of currency to be charged. The currency needs to match the currency of the user that is logged into the SumUp app. For example EUR, GBP, BRL, CHF, PLN. |
|`affiliate-key` | Your affiliate key. It needs to be associated with the calling app's bundle identifier. |

## Optional query parameters


| Key                 | Comment |
| --------------------|:------- |
| `title`             | An optional title to be set on this transaction.|
|`callbackfail`       | URL to be opened when the transaction fails. See [Callback query parameters](#Callback-query-parameters).|
|`callbacksuccess`    | URL to be opened when the transaction succeeds. See [Callback query parameters](#Callback-query-parameters).|
|`receipt-email`      | Prefills the email textfield when asking the customer whether he wants a receipts. |
|`receipt-mobilephone`| Prefills the phone number textfield when asking the customer whether he wants a receipts. |
|`foreign-tx-id`      | An optional ID to be associated with this transaction. Please see our [API documentation](https://sumup.com/integration#transactionReportingAPIs) on how to retrieve a transaction using this ID. This ID has to be unique in the scope of a SumUp merchant account and its sub-accounts. It must not be longer than 128 characters and can only contain printable ASCII characters. If provided it will be appended to the callback URLs as a [query parameter](#Callback-query-parameters).* Supported by SumUp app version 1.53 and later.* |


## Callback query parameters

After the payment has been executed the SumUp app will open the `callbacksuccess` URL if the payment succeeded and the `callbackfail` URL if it did not. We will append the following query parameters if applicable:

| Key             | Possible values  | Comment                        |
| --------------- |:----------------:| :----------------------------- |
| `smp-status`    | success          | The transaction has succeeded. |
|                 | failed           | The transaction has failed.    |
|                 | invalidstate     | The transaction can not be accepted as the SumUp app is in an invalid state. Please ask the user to open the SumUp app and make sure he's ready to accept payments. |
| `smp-tx-code`   | TRANSACTION-CODE | The transaction code for this payment. Please see our [API documentation](https://sumup.com/integration#transactionReportingAPIs) to find out how to retreive details on this payment. *Supported by SumUp app version 1.53 and later.* |
| `foreign-tx-id` | YOUR-TX-ID       | Only if provided, see [Optional query parameters](#optional-query-parameters). |


## SMPPaymentRequest
If you are building your own iOS app you can use this class to conveniently open the SumUp app to accept a payment. It knows about all the URL parameters and makes accepting a payment as easy as:

```objc
SMPPaymentRequest *request;
NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];

request = [SMPPaymentRequest paymentRequestWithAmount:amount
                                             currency:@"EUR"
                                                title:@"My title"
                                         affiliateKey:@"YOUR-AFFILIATE-KEY"];

[request setCallbackURLSuccess:[NSURL URLWithString:@"samplepaymentapp://"]];
[request setCallbackURLFailure:[NSURL URLWithString:@"samplepaymentapp://"]];

/* This will open the following URL
 * sumupmerchant://pay/1.0?amount=10.00&currency=EUR&affiliate-key=YOUR-AFFILIATE-KEY
 * &title=My%20title
 * &callbackfail=samplepaymentapp%3A%2F%2F
 * &callbacksuccess=samplepaymentapp%3A%2F%2F
 */
[request openSumUpMerchantApp];
```
