# SumUp Custom URL Scheme

This repository documents the lightweight SumUp app-switch integration for iOS.
It lets your app hand off a payment request to the SumUp merchant app through a
custom URL scheme and receive the result through your own callback URL.

If you want to accept payments fully inside your app, use the
[SumUp iOS SDK](https://github.com/sumup/sumup-ios-sdk) instead. This repository
is specifically about the app-switch contract.

## When To Use This Integration

Use the custom URL scheme when:

- your app already has its own checkout flow and only needs to hand off the
  card-present payment step to the SumUp merchant app
- you want the smallest possible integration surface
- your app can handle returning from an external app through a callback URL

To get started, create a SumUp account and obtain an affiliate key in the
[Developer section](https://me.sumup.com/developers).

## iOS Integration Checklist

Before opening the SumUp app from your iOS app:

1. Register a callback URL scheme for your app in `CFBundleURLTypes`.
2. Add `sumupmerchant` to `LSApplicationQueriesSchemes` so
   `canOpenURL("sumupmerchant://")` works.
3. Use a unique `foreign-tx-id` for reconciliation and idempotency whenever
   possible.
4. Handle both success and failure callbacks and treat missing callback fields as
   optional for backward compatibility.

The sample app in this repository shows an Objective-C integration updated for a
modern iOS app lifecycle.

## Base URL

`sumupmerchant://pay/1.0`

This URL and the query parameter names below are the compatibility contract for
existing integrators.

## Mandatory Query Parameters

| Key | Comment |
| --- | :--- |
| `amount` | The amount to charge. Use `.` as the decimal separator. |
| `currency` | ISO 4217 currency code. It must match the currency of the merchant logged into the SumUp app, for example `EUR`, `GBP`, `BRL`, `CHF`, `PLN`. |
| `affiliate-key` | Your affiliate key. It must be associated with the calling app's bundle identifier. |

## Optional Query Parameters

| Key | Comment |
| --- | :--- |
| `title` | Optional title for the transaction. |
| `callbackfail` | URL to open when the transaction fails. See [Callback query parameters](#callback-query-parameters). |
| `callbacksuccess` | URL to open when the transaction succeeds. See [Callback query parameters](#callback-query-parameters). |
| `receipt-email` | Prefills the email field when the customer is asked about a receipt. |
| `receipt-mobilephone` | Prefills the phone field when the customer is asked about a receipt. |
| `foreign-tx-id` | Optional ID associated with the transaction. It must be unique within the merchant account scope, no longer than 128 characters, and use printable ASCII characters only. Supported by SumUp app version 1.53 and later. Version 1.53.2 and later appends it to callback URLs when provided. |
| `skip-screen-success` | Set `skip-screen-success=true` to skip the success screen after a successful payment. Your application becomes responsible for displaying the result to the customer. Supported by SumUp app version 1.69 and later. |

## Callback Query Parameters

After the payment completes, the SumUp app opens `callbacksuccess` for a
successful payment or `callbackfail` otherwise. The following query parameters
may be appended:

| Key | Possible values | Comment |
| --- | :---: | :--- |
| `smp-status` | `success` | The transaction succeeded. |
|  | `failed` | The transaction failed. |
|  | `invalidstate` | The SumUp app was not ready to accept a payment. Ask the merchant to open the SumUp app and make sure it is ready to accept payments. |
| `smp-tx-code` | `TRANSACTION-CODE` | Transaction code for the payment. Supported by SumUp app version 1.53 and later. |
| `foreign-tx-id` | `YOUR-TX-ID` | Present only when it was provided in the payment request. Supported by SumUp app version 1.53.2 and later. |

## Building The URL Directly

If you are not using the helper framework, construct the launch URL yourself.
For example:

```text
sumupmerchant://pay/1.0?amount=10.00&currency=EUR&affiliate-key=YOUR-AFFILIATE-KEY&title=Coffee%20beans&callbacksuccess=samplepaymentapp%3A%2F%2F&callbackfail=samplepaymentapp%3A%2F%2F&foreign-tx-id=order-123
```

## `SMPPaymentRequest`

If you are integrating from Objective-C, `SMPPaymentRequest` still provides a
convenient wrapper around the URL contract.

```objc
SMPPaymentRequest *request;
NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];

request = [SMPPaymentRequest paymentRequestWithAmount:amount
                                             currency:@"EUR"
                                                title:@"My title"
                                         affiliateKey:@"YOUR-AFFILIATE-KEY"];

request.callbackURLSuccess = [NSURL URLWithString:@"samplepaymentapp://"];
request.callbackURLFailure = [NSURL URLWithString:@"samplepaymentapp://"];
request.foreignTransactionID = @"order-123";

// Optional: add skip-screen-success=true
request.skipScreenOptions = SMPSkipScreenOptionSuccess;

[request openSumUpMerchantApp];
```

## Modern Callback Handling Example

On current iOS versions, handle the callback in your scene delegate or
`application:openURL:options:` implementation. Parse query items with
`NSURLComponents` instead of manually splitting strings.

```swift
func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    guard let context = urlContexts.first else { return }

    let components = URLComponents(url: context.url, resolvingAgainstBaseURL: false)
    let queryItems = components?.queryItems ?? []

    let status = queryItems.first(where: { $0.name == "smp-status" })?.value
    let txCode = queryItems.first(where: { $0.name == "smp-tx-code" })?.value

    print("status:", status ?? "nil", "txCode:", txCode ?? "nil")
}
```

## Compatibility Notes

- Keep using `sumupmerchant://pay/1.0`. Existing integrators rely on that path.
- Preserve the current query parameter and callback parameter names.
- Do not assume all callback parameters are present on older SumUp app versions.
- If you need richer in-app payment flows, migrate to the
  [SumUp iOS SDK](https://github.com/sumup/sumup-ios-sdk) rather than extending
  the URL contract.

## Community

- **Questions?** Contact the integration team at <a href="mailto:integration@sumup.com">integration@sumup.com</a>.
- **Found a bug?** [Open an issue](https://github.com/sumup/sumup-ios-url-scheme/issues/new) with as much detail as possible.
