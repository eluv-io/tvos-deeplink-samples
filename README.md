# Eluvio Deeplink sample for AppleTV
This sample demonstrates how to deeplink into the Eluvio Media Wallet app on AppleTV. Note currently only works with Eluvio Media Wallet 1.0.7 or greater.

## Currently supported URIs
* The Eluvio Media Wallet has defined a deep link scheme elvwallet:// when installed
* Link to a specific SKU: elvwallet://items?contract={contract_address}&marketplace={marketplace_id}&sku={sku}&back_link=\(backlink)"
* Link to play a video from the content fabric: elvwallet://play?contract={contract_address}
* Link to mint a bundle with entitlements: elvwallet://mint?marketplace={marketplace_id}&sku={sku}&entitlement={entitlement}&back_link=\(backlink)"
* see [Linker.swift](EluvioDeepLinkSample/EluvioDeepLinkSample/Linker.swift)

## Back links
Add a `back_link=yourapp://uri` query param to any deeplink request to enable a button in the Media Wallet app that will send the user back to your app.

## Auth Token (TODO)
* Eluvio fabric token or a JWT Token
* Add a `authorization=acspxxxxxxxx` query param to any deeplink request to use the Sample's logged in user's wallet for any method. Currently does not switch users yet inside of the Media Wallet and will use the current'ly logged in user. Note you need to log in the Media Wallet first and any minting operation will depend on this user's wallet.


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


## Customization for Dev
* Change these values inside of [ContentView.swift](EluvioDeepLinkSample/EluvioDeepLinkSample/ContentView.swift)
```
    let MARKETPLACE = "iq__"
    let SKU = ""
    let JWT_ACCESS_TOKEN = "ey__"
    let ENTITLEMENT = """
    {"tenant_id":"", ...}
    """
    let ENTITLEMENT_SIGNATURE = "mje__"
```

1. Use [this sample](https://appsvc.svc.eluv.io/sample-purchase) to generate dummy values for testing.  
2. Read about [Media Wallet Retailer Integration](https://hub.doc.eluv.io/mediawallet/retailer_integration/) to get these values from your own system.
Note: "purchase_id" is unique per tenant, not user, so while testing make sure not to use simple purchase_ids like "1" that may have been used by others before you, try to make them unique to yourself.
 

## Media Wallet App Store
* If you would like to link to the Media Wallet on the App store (once deep links are supported), use this url: https://apps.apple.com/in/app/eluvio-media-wallet/id1591550411


