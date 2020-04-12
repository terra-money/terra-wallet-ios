import XCTest
import TerraWalletSDK

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        //test generating and recover from generated.
        walletGenerateAndRecoverTest()
        
        //test transfer
        transferTest()
        
        //test marketswap
        marketSwapTest()
    }
    
    func walletGenerateAndRecoverTest() {
        let count = 100
        var wallets = Array<(privateKey:String, publicKey:String, address:String, mnemonic:String)>()
        
        
        // generate
        for i in 0..<count {
            let wallet = TerraWalletSDK.getNewWallet()
            
            guard let privateKey = wallet[TerraWalletSDK.PRIVATE_KEY],
                let publicKey = wallet[TerraWalletSDK.PUBLIC_KEY],
                let address = wallet[TerraWalletSDK.ADDRESS],
                let mnemonic = wallet[TerraWalletSDK.MNEMONIC] else {
                XCTFail("generated[\(i)], failed to generate.")
                return
            }
            
            if privateKey.count != 64 {
                XCTFail("generated[\(i)], privateKey is wrong.")
                return
            }
            
            if publicKey.count != 66 {
                XCTFail("generated[\(i)], publicKey is wrong.")
                return
            }
            
            if mnemonic.split(separator: " ").count != 24 {
                XCTFail("generated[\(i)], mnemonic is wrong.")
                return
            }
            
            
            //success generating.
            let obj = (privateKey, publicKey, address, mnemonic)
            wallets.append(obj)
        }
        
        
        // recover from generated above.
        
        if wallets.count != count {
            XCTFail("items generated not enough.")
        }
        
        for i in 0..<wallets.count {
            let wallet = TerraWalletSDK.getNewWalletFromSeed(wallets[i].mnemonic, bip: 330)
            
            guard let privateKey = wallet[TerraWalletSDK.PRIVATE_KEY],
                let publicKey = wallet[TerraWalletSDK.PUBLIC_KEY],
                let address = wallet[TerraWalletSDK.ADDRESS] else {
                XCTFail("recovered[\(i)], failed to recover.")
                return
            }
            
            //check privateKey(recovered and generated is equal)
            if wallets[i].privateKey != privateKey {
                XCTFail("recovered[\(i)], privateKey is wrong.")
                return
            }
            
            //check publicKey(recovered and generated is equal)
            if wallets[i].publicKey != publicKey {
                XCTFail("recovered[\(i)], publicKey is wrong.")
                return
            }
            
            //check address(recovered and generated is equal)
            if wallets[i].address != address {
                XCTFail("recovered[\(i)], address is wrong.")
                return
            }
        }
        
        XCTAssert(true, "PASS")
    }
    
    func transferTest() {
        print("TRANSFER TEST START")
        let expectation = XCTestExpectation(description: "transfer test")
        
        let hexPrivateKey = "99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c"
        let hexPublicKey = "0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f"
        let address = "terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6"
        let chainId = "soju-0013"
        
        
        let toAddress = "terra1y56xnxa2aaxtuc3rpntgxx0qchyzy2wp7dqgy3"
        let transferBalance = "1000000" //1Luna
        
        self.getAccountInfo(address: address) { (luna, accountNumber, sequence) in
            if let lunaValue = Int(luna), lunaValue > 1000 {
                
            } else {
                XCTFail("not enough luna balance.")
                return
            }
            
            if accountNumber == "" {
                XCTFail("account number is not valid")
                return
            }
            
            if sequence == "" {
                XCTFail("sequence is not valid")
                return
            }
            
            
            self.makeTransferMessage(from: address, to: toAddress, accountNumber: accountNumber, chainId: chainId, sequence: sequence, transferBalance: transferBalance) { message in
                
                if message.isEmpty {
                    XCTFail("makeTransferMessage is wrong.")
                }
                
                let signed = TerraWalletSDK.sign(message, sequence: sequence, account_number: accountNumber, chain_id: chainId, hexPrivateKey: hexPrivateKey, hexPublicKey: hexPublicKey)
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: signed, options: []) else {
                    XCTFail("signed message is wrong.")
                    return
                }
                
                self.broadcast(message: jsonData) { (success) in
                    if !success {
                        XCTFail("broadcast failed.")
                    } else {
                        print("TRANSFER SUCCESS.")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 30.0)
    }
    
    func marketSwapTest() {
        print("SWAP TEST START")
        let expectation = XCTestExpectation(description: "market swap test")
        
        let hexPrivateKey = "99b555956f56a2889c78594cfac8d8aa6d0a6e75bd3ccfefb5248b6b83d8096c"
        let hexPublicKey = "0352105a7248e226cbb913aad4d5997cf03db9e6caf03dd9a1d168442325d4ff1f"
        let address = "terra14aqr0fwhsh334qpeu39wuzdt9hkw2pwvwnyvh6"
        let chainId = "soju-0013"
        
        
        let toCurrency = "usdr" //SDT
        let swapBalance = "1000000" //1Luna
        
        self.getAccountInfo(address: address) { (luna, accountNumber, sequence) in
            if let lunaValue = Int(luna), lunaValue > 1000 {
                
            } else {
                XCTFail("not enough luna balance.")
                return
            }
            
            if accountNumber == "" {
                XCTFail("account number is not valid")
                return
            }
            
            if sequence == "" {
                XCTFail("sequence is not valid")
                return
            }
            
            
            self.makeMarketSwapMessage(from: address, toCurrency: toCurrency, accountNumber: accountNumber, chainId: chainId, sequence: sequence, swapBalance: swapBalance) { message in
                
                if message.isEmpty {
                    XCTFail("makeMarketSwapMessage is wrong.")
                }
                
                let signed = TerraWalletSDK.sign(message, sequence: sequence, account_number: accountNumber, chain_id: chainId, hexPrivateKey: hexPrivateKey, hexPublicKey: hexPublicKey)
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: signed, options: []) else {
                    XCTFail("signed message is wrong.")
                    return
                }
                
                self.broadcast(message: jsonData) { (success) in
                    if !success {
                        XCTFail("broadcast failed.")
                    } else {
                        print("MARKET SWAP SUCCESS.")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    private func getAccountInfo(address:String, callback: @escaping (String, String, String)->()) {
        
        dataTask(url: "/auth/accounts/\(address)", httpMethod: "GET") { (data, response, error) in
            var luna = ""
            var accountNumber = ""
            var sequence = ""
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dic = json as? [String:Any] {
                
                let result = dic["result"] as? [String: Any]
                let value = result?["value"] as? [String: Any]
                
                if let coins = value?["coins"] as? [[String: Any]] {
                    for coin in coins {
                        if let denom = coin["denom"] as? String, denom == "uluna" {
                            luna = (coin["amount"] as? String) ?? ""
                        }
                    }
                    
                }
                
                accountNumber = (value?["account_number"] as? String) ?? ""
                sequence = (value?["sequence"] as? String) ?? ""
            }
            
            callback(luna, accountNumber, sequence)
        }
    }
    
    private func makeTransferMessage(from:String, to:String, accountNumber:String, chainId:String, sequence:String, transferBalance:String, callback: @escaping ([String:Any])->()) {
        
        let requestJson = "{\"base_req\": {\"from\": \"\(from)\",\"memo\": \"Sent via terra-wallet-ios xctest\",\"chain_id\": \"\(chainId)\",\"account_number\": \"\(accountNumber)\",\"sequence\": \"\(sequence)\",\"gas\": \"200000\",\"gas_adjustment\": \"1.2\",\"fees\": [{\"denom\": \"uluna\",\"amount\": \"50\"}],\"simulate\": false},\"coins\": [{\"denom\": \"uluna\",\"amount\": \"\(transferBalance)\"}]}"
        
        dataTask(url: "/bank/accounts/\(to)/transfers", data: requestJson.data(using: .utf8)) { (data, response, error) in
            var message = Dictionary<String, Any>()
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dic = json as? [String:Any],
                let msg = dic["value"] as? [String : Any] {
                message = msg
            }
            
            callback(message)
        }
    }
    
    private func makeMarketSwapMessage(from:String, toCurrency:String, accountNumber:String, chainId:String, sequence:String, swapBalance:String, callback: @escaping ([String:Any])->()) {
        
        let requestJson = "{\"base_req\": {\"from\": \"\(from)\",\"memo\": \"Sent via terra-wallet-ios xctest\",\"chain_id\": \"\(chainId)\",\"account_number\": \"\(accountNumber)\",\"sequence\": \"\(sequence)\",\"gas\": \"200000\",\"gas_adjustment\": \"1.2\",\"fees\": [{\"denom\": \"uluna\",\"amount\": \"50\"}],\"simulate\": false},\"offer_coin\": {\"denom\": \"uluna\",\"amount\": \"\(swapBalance)\"},\"ask_denom\": \"\(toCurrency)\"}"
        
        
        dataTask(url: "/market/swap", data: requestJson.data(using: .utf8)) { (data, response, error) in
            var message = Dictionary<String, Any>()
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dic = json as? [String:Any],
                let msg = dic["value"] as? [String : Any] {
                message = msg
            }
            
            callback(message)
        }
    }
    
    private func broadcast(message:Data, callback:@escaping(Bool)->()) {
        dataTask(url: "/txs", data: message) { (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                callback(true)
            } else {
                if let data = data {
                    print(String(data: data, encoding:.utf8))
                }
                callback(false)
            }
        }
    }
    
    private func dataTask(url:String, httpMethod:String = "POST", data:Data? = nil, callback:@escaping (Data?, URLResponse?, Error?)->()) {
        let url = URL(string: "https://soju-lcd.terra.dev\(url)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = ["Content-Type" : "application/json"]
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            callback(data, response, error)
        }.resume()
    }
}
