# terra-wallet-ios

## Build framework.
1. Select target 'Generic iOS Device'
2. Click Product - Archive
2. "TerraWalletSDK.framework" generated in project dir. <= Universial framework.

## Usage.
1. Add "TerraWalletSDK.framework" into your project.
2. See below example.

~~~swift
import TerraWalletSDK

class Example {
    func createWallet() {
        let wallet:[String:String] = TerraWalletSDK.getNewWallet()
        
        let hexPrivateKey = wallet[TerraWalletSDK.PRIVATE_KEY]
        // ex) 99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c, 32bytes
        
        let hexPublicKey = wallet[TerraWalletSDK.PUBLIC_KEY]
        // ex) 0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f, 33bytes
        
        let terraAddress = wallet[TerraWalletSDK.ADDRESS]
        // ex) terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6
        
        let mnemonic = wallet[TerraWalletSDK.MNEMONIC]
        // ex) police head unfair frozen animal sketch peace budget orange foot fault quantum caution make reject fruit minimum east stuff leisure seminar ocean credit ridge, 24 words
    }
    
    func loadWallet(mnemonicWords:String) {
        let wallet:[String:String] = TerraWalletSDK.getNewWalletFromSeed(mnemonic: mnemonicWords, bip: 330)
        // also, you can use 'TerraWalletSDK.getNewWalletFromSeed(mnemonic: mnemonicWords)'
        // default bip is 330
        
        let hexPrivateKey = wallet[TerraWalletSDK.PRIVATE_KEY]
        // ex) 99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c, 32bytes
        // if mnemonic is wrong, Return value will be ""
        
        let hexPublicKey = wallet[TerraWalletSDK.PUBLIC_KEY]
        // ex) 0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f, 33bytes
        // if mnemonic is wrong, Return value will be ""
        
        let terraAddress = wallet[TerraWalletSDK.ADDRESS]
        // ex) terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6
        // if mnemonic is wrong, Return value will be ""
    }
    
    func signMessage(tx:[String: Any],
                    sequence:String,
                    accountNumber:String,
                    chainId:String, 
                    hexPrivateKey:String,
                    hexPublicKey:String) -> [String: Any] {
    
        // Parameter Info (for Testnet, https://soju-lcd.terra.dev)
        
        // tx
        // transfer ex) "{\"msg\":[{\"type\":\"bank/MsgSend\",\"value\":{\"from_address\":\"terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6\",\"to_address\":\"terra1y56xnxa2aaxtuc3rpntgxx0qchyzy2wp7dqgy3\",\"amount\":[{\"denom\":\"uluna\",\"amount\":\"50\"}]}}],\"fee\":{\"amount\":[{\"denom\":\"uluna\",\"amount\":\"50\"}],\"gas\":\"200000\"},\"signatures\":null,\"memo\":\"memo\"}"
        
        // sequence, accountNumber
        // https://soju-lcd.terra.dev/auth/accounts/{YOUR ADDRESS}
        
        // chainId (ex: 'soju-0013')
        // https://soju-lcd.terra.dev/blocks/latest
        
        // hexPrivateKey, ex) 99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c
        // hexPublicKey,  ex) 0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f
    
    
        let requestBody:[String:Any] = TerraWalletSDK.sign(message: tx,
                                                           sequence: sequence,
                                                           account_number: accountNumber,
                                                           chain_id: chainId,
                                                           hexPrivateKey: hexPrivateKey,
                                                           hexPublicKey: hexPublicKey)
        // if something wrong, Return value will be [:]
        return requestBody
        
        // you can send a 'requestBody' to 
        // 'https://soju-lcd.terra.dev/txs' POST
    }
}
~~~

## License

MIT License

Copyright (c) 2020 TerraFormLabs Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
