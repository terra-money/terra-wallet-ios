# terra-wallet-ios

## Build framework.
1. Select target 'Generic iOS Device'
2. Click Product - Archive
2. "TerraWalletSDK.framework" generated in project dir. <= Universial framework.

## Usage.
1. add "TerraWalletSDK.framework" into your project.
2. add "import TerraWalletSDK"
3. available below methods.
- TerraWalletSDK.getNewWallet()
- TerraWalletSDK.getNewWalletFromSeed(mnemonic:String, bip:Int)
- TerraWalletSDK.sign(message:Dictionary<String, Any>, sequence:String, account_number:String, chain_id:String, hexPrivateKey:String, hexPublicKey:String)
