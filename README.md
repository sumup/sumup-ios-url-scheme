<div align="center">

# SumUp iOS URL Scheme

[![Documentation][docs-badge]](https://developer.sumup.com)
[![CI Status](https://github.com/sumup/sumup-ios-url-scheme/actions/workflows/ci.yml/badge.svg)](https://github.com/sumup/sumup-ios-url-scheme/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/sumup/sumup-ios-url-scheme)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS-000000)](https://developer.apple.com/ios/)

</div>

This repository documents the lightweight SumUp app-switch integration for iOS. It lets your app hand off a payment request to the SumUp merchant app through a custom URL scheme and receive the result through your own callback URL.

Use it when you want to:

- start a SumUp card-present payment from a native iOS app
- keep the integration surface very small
- receive the payment result back through your own URL scheme

The sample app in this repository can be used as a reference implementation for the integration contract. If you want to accept payments fully inside your app, use the [SumUp iOS SDK](https://github.com/sumup/sumup-ios-sdk) instead.

## Getting Started

1. Create a SumUp account.
2. Generate an affiliate key in [me.sumup.com/developers](https://me.sumup.com/developers).
3. Register a callback URL scheme for your app in `CFBundleURLTypes`.
4. Add `sumupmerchant` to `LSApplicationQueriesSchemes` so `canOpenURL("sumupmerchant://")` works.
5. Use a unique `foreign-tx-id` whenever possible for reconciliation and idempotency.

## URL Contract

The compatibility contract for existing integrators is the launch URL `sumupmerchant://pay/1.0` and the query parameter and callback parameter names documented below.

### Mandatory Query Parameters

| Key             | Comment                                                                                                                                        |
|-----------------|:-----------------------------------------------------------------------------------------------------------------------------------------------|
| `amount`        | The amount to charge. Use `.` as the decimal separator.                                                                                        |
| `currency`      | ISO 4217 currency code. It must match the currency of the merchant logged into the SumUp app, for example `EUR`, `GBP`, `BRL`, `CHF`, `PLN`. |
| `affiliate-key` | Your affiliate key. It must be associated with the calling app's bundle identifier.                                                        |

### Optional Query Parameters

| Key                   | Comment                                                                                                                                                                                                                                                                       |
|-----------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `title`               | Optional title for the transaction.                                                                                                                                                                                                                                            |
| `callbackfail`        | URL to open when the transaction fails. See [Callback query parameters](#callback-query-parameters).                                                                                                                                                                          |
| `callbacksuccess`     | URL to open when the transaction succeeds. See [Callback query parameters](#callback-query-parameters).                                                                                                                                                               |
| `receipt-email`       | Prefills the email field when the customer is asked about a receipt.                                                                                                                                                                                                          |
| `receipt-mobilephone` | Prefills the phone field when the customer is asked about a receipt.                                                                                                                                                                                                  |
| `foreign-tx-id`       | Optional ID associated with the transaction. It must be unique within the merchant account scope, no longer than 128 characters, and use printable ASCII characters only. Supported by SumUp app version 1.53 and later. Version 1.53.2 and later appends it to callback URLs when provided. |
| `skip-screen-success` | Set `skip-screen-success=true` to skip the success screen after a successful payment. Your application becomes responsible for displaying the result to the customer. Supported by SumUp app version 1.69 and later.                                                       |

### Callback Query Parameters

After the payment completes, the SumUp app opens `callbacksuccess` for a successful payment or `callbackfail` otherwise. The following query parameters may be appended:

| Key             | Possible values    | Comment                                                                                                                                 |
|-----------------|:------------------:|:----------------------------------------------------------------------------------------------------------------------------------------|
| `smp-status`    | `success`          | The transaction succeeded.                                                                                                              |
|                 | `failed`           | The transaction failed.                                                                                                                 |
|                 | `invalidstate`     | The SumUp app was not ready to accept a payment. Ask the merchant to open the SumUp app and make sure it is ready to accept payments. |
| `smp-tx-code`   | `TRANSACTION-CODE` | Transaction code for the payment. Supported by SumUp app version 1.53 and later.                                                            |
| `foreign-tx-id` | `YOUR-TX-ID`       | Present only when it was provided in the payment request. Supported by SumUp app version 1.53.2 and later.                             |

## Integration Options

### Build The URL Directly

If you are not using the helper framework, construct the launch URL yourself.
For example:

```text
sumupmerchant://pay/1.0?amount=10.00&currency=EUR&affiliate-key=YOUR-AFFILIATE-KEY&title=Coffee%20beans&callbacksuccess=samplepaymentapp%3A%2F%2F&callbackfail=samplepaymentapp%3A%2F%2F&foreign-tx-id=order-123
```

### Use `SMPPaymentRequest`

If you are integrating from Objective-C, `SMPPaymentRequest` provides a convenient wrapper around the same URL contract.

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

## Handle The Callback

On current iOS versions, handle the callback in your scene delegate or `application:openURL:options:` implementation. Parse query items with `NSURLComponents` instead of manually splitting strings.

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
- If you need richer in-app payment flows, migrate to the [SumUp iOS SDK](https://github.com/sumup/sumup-ios-sdk) rather than extending the URL contract.

## Community

- Questions: contact [integration@sumup.com](mailto:integration@sumup.com)
- Bugs: [open an issue](https://github.com/sumup/sumup-ios-url-scheme/issues/new)

[docs-badge]: https://img.shields.io/badge/SumUp-documentation-white.svg?logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgY29sb3I9IndoaXRlIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogICAgPHBhdGggZD0iTTIyLjI5IDBIMS43Qy43NyAwIDAgLjc3IDAgMS43MVYyMi4zYzAgLjkzLjc3IDEuNyAxLjcxIDEuN0gyMi4zYy45NCAwIDEuNzEtLjc3IDEuNzEtMS43MVYxLjdDMjQgLjc3IDIzLjIzIDAgMjIuMjkgMFptLTcuMjIgMTguMDdhNS42MiA1LjYyIDAgMCAxLTcuNjguMjQuMzYuMzYgMCAwIDEtLjAxLS40OWw3LjQ0LTcuNDRhLjM1LjM1IDAgMCAxIC40OSAwIDUuNiA1LjYgMCAwIDEtLjI0IDcuNjlabTEuNTUtMTEuOS03LjQ0IDcuNDVhLjM1LjM1IDAgMCAxLS41IDAgNS42MSA1LjYxIDAgMCAxIDcuOS03Ljk2bC4wMy4wM2MuMTMuMTMuMTQuMzUuMDEuNDlaIiBmaWxsPSJjdXJyZW50Q29sb3IiLz4KPC9zdmc+
