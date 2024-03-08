# Eluvio Deeplink sample for AppleTV
This sample demonstrates how to deeplink into the Eluvio Media Wallet app on AppleTV. Note currently only works with Beta versions of Eluvio Media Wallet 1.0.6+.

## Currently supported URIs
* The Eluvio Media Wallet has defined a deep link scheme elvwallet:// when installed
* Link to a specific SKU: elvwallet://items?contract={contract_address}&marketplace={marketplace_id}&sku={sku}&back_link=\(backlink)"
* Link to play a video from the content fabric: elvwallet://play?contract={contract_address}
* Link to mint a bundle with entitlements: elvwallet://mint?marketplace={marketplace_id}&sku={sku}&entitlement={entitlement}&back_link=\(backlink)"
* see [Linker.swift](EluvioDeepLinkSample/EluvioDeepLinkSample/Linker.swift)

## Back links
Add a `back_link=yourapp://uri` query param to any deeplink request to enable a button in the Media Wallet app that will send the user back to your app.


## Entitlements
The expected format of the entitlement is a serialized json string
```
eg.

{
  "entitlement": {
    "tenant_id": "iten,
    "marketplace_id": "iq__",
    "items": [
      {
        "sku": "XXXXX",
        "amount": 1
      }
    ],
    "user": "0xaaaa",
    "purchase_id": "pid_abcd1234"
  },
  "signature": "mje_xxxx"
}
```
This sample uses a demo backend api to retrieve a signed entitlement. In production, it is the responsibility of the implementation app to generate and sign the entitlement with the correct purchase information using the tenant (retailer) key


## Media Wallet App Store
* If you would like to link to the Media Wallet on the App store (once deep links are supported), use this url: https://apps.apple.com/in/app/eluvio-media-wallet/id1591550411


