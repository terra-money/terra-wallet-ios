import Foundation
import TrezorCrypto

class KeyPair {
    private var node: HDNode
    
    init(node: HDNode) {
        self.node = node
    }
    
    public var privateKey: Data {
        return Data(bytes: withUnsafeBytes(of: &node.private_key) { ptr in
            return ptr.map({ $0 })
        })
    }
  
    public var publicKey: Data {
        guard let curve = node.curve.pointee.params else {
            return Data()
        }
        return Utils.ecdsa(data: privateKey, curve:curve)
    }
  
    public var terraAddress: String {

        //sha256
        let hashed = Utils.sha256(data: publicKey)

        //ripemd160
        let ripemd160Result = Utils.ripemd160Encode(data: hashed)
      
        //bech32
        let words = Utils.toWords(data: ripemd160Result, inBits: 8, outBits: 5)!
        let bech32Result = Utils.bech32(prefix: "terra", data: words)
      
        return String(data: bech32Result, encoding: .utf8)!
    }
  
}
