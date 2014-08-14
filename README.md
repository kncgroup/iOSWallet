![K](/images/kncwallet.png) KnC Wallet
----------------------------------

An [SPV](https://en.bitcoin.it/wiki/Thin_Client_Security#Header-Only_Clients),
[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
deterministic bitcoin wallet for iOS.

KnC Wallet is open source and available under the terms of the MIT license.

**WARNING:** installation on jailbroken devices is strongly discouraged

Any jailbreak app can grant itself keychain entitlements to your wallet seed and
rob you by self-signing as described [here](http://www.saurik.com/id/8) and
including `<key>application-identifier</key><string>com.kncwallet.*</string>` in
its .entitlements file.
