//
//  ViewController.swift
//  TerraWalletSDK
//
//  Created by Felix on 04/10/2020.
//  Copyright (c) 2020 TerraFormLabs. All rights reserved.
//

import UIKit
import TerraWalletSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWallet()
        self.loadWallet()
        self.signMessage()
    }
    
    func createWallet() {
        let wallet:[String:String] = TerraWalletSDK.getNewWallet()
        print("getNewWallet")
        print("- hexPrivateKey : \(wallet[TerraWalletSDK.PRIVATE_KEY])")
        // ex) 99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c, 32bytes
        
        print("- hexPublicKey : \(wallet[TerraWalletSDK.PUBLIC_KEY])")
        // ex) 0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f, 33bytes
        print("- hexPublicKey(uncompressed) : \(wallet[TerraWalletSDK.PUBLIC_KEY_UNCOMPRESSED])")
        // ex)
        
        print("- terraAddress : \(wallet[TerraWalletSDK.ADDRESS])")
        // ex) terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6
        
        print("- mnemonic : \(wallet[TerraWalletSDK.MNEMONIC])")
        // ex) police head unfair frozen animal sketch peace budget orange foot fault quantum caution make reject fruit minimum east stuff leisure seminar ocean credit ridge, 24 words
        
        print("")
    }
    
    func loadWallet() {
        let mnemonicWords = "police head unfair frozen animal sketch peace budget orange foot fault quantum caution make reject fruit minimum east stuff leisure seminar ocean credit ridge"
        
        let wallet:[String:String] = TerraWalletSDK.getNewWalletFromSeed(mnemonicWords, bip: 330)
        // also, you can use 'TerraWalletSDK.getNewWalletFromSeed(mnemonic: mnemonicWords)'
        // default bip is 330
        print("Load Wallet : \(mnemonicWords)")
        print("- hexPrivateKey : \(wallet[TerraWalletSDK.PRIVATE_KEY])")
        // ex) 99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c, 32bytes
        // if mnemonic is wrong, Return value will be ""
        
        print("- hexPublicKey : \(wallet[TerraWalletSDK.PUBLIC_KEY])")
        // ex) 0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f, 33bytes
        // if mnemonic is wrong, Return value will be ""
        print("- hexPublicKey(uncompressed) : \(wallet[TerraWalletSDK.PUBLIC_KEY_UNCOMPRESSED])")
        // ex)
        
        print("- terraAddress : \(wallet[TerraWalletSDK.ADDRESS])")
        // ex) terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6
        // if mnemonic is wrong, Return value will be ""
        print("")
    }
    
    func signMessage() {
    
        
        let txString = "{\"msg\":[{\"type\":\"bank/MsgSend\",\"value\":{\"from_address\":\"terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6\",\"to_address\":\"terra1y56xnxa2aaxtuc3rpntgxx0qchyzy2wp7dqgy3\",\"amount\":[{\"denom\":\"uluna\",\"amount\":\"50\"}]}}],\"fee\":{\"amount\":[{\"denom\":\"uluna\",\"amount\":\"50\"}],\"gas\":\"200000\"},\"signatures\":null,\"memo\":\"memo\"}"

        guard let txData = txString.data(using: .utf8),
            let txJson = try? JSONSerialization.jsonObject(with: txData, options: []),
            let tx =  txJson as? [String: Any] else {
            return
        }
        
        let sequence = "15" // for Testnet, https://soju-lcd.terra.dev/auth/accounts/{YOUR ADDRESS}
        let accountNumber = "406" // for Testnet, https://soju-lcd.terra.dev/auth/accounts/{YOUR ADDRESS}
        let chainId = "soju-0013" // for Testnet, https://soju-lcd.terra.dev/blocks/latest
        
        let hexPrivateKey = "99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c"
        let hexPublicKey  = "0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f"
        
    
        let requestBody:[String:Any] = TerraWalletSDK.sign(tx,
                                                           sequence: sequence,
                                                           account_number: accountNumber,
                                                           chain_id: chainId,
                                                           hexPrivateKey: hexPrivateKey,
                                                           hexPublicKey: hexPublicKey)
        // if something wrong, Return value will be [:]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []),
            let jsonString = String(data:jsonData, encoding: .utf8) else {
            return
        }
        
        print("sign")
        print("- requestBody : \(jsonString)")
        print("")
        // you can send a 'requestBody' to
        // 'https://soju-lcd.terra.dev/txs' POST
    }
}
