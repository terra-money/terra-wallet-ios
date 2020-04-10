import Foundation
import CommonCrypto
import TrezorCrypto

extension Data {
    var hex: String {
        return self.map { b in String(format: "%02x", b) }.joined()
    }

    var bytes: [UInt8] {
        self.map { (v) -> UInt8 in
          return v
        }
    }
}

extension String {
  var hexToData: Data {
      var hex = self
      var data = Data()
      while(hex.count > 0) {
          let subIndex = hex.index(hex.startIndex, offsetBy: 2)
          let c = String(hex[..<subIndex])
          hex = String(hex[subIndex...])
          var ch: UInt32 = 0
          Scanner(string: c).scanHexInt32(&ch)
          var char = UInt8(ch)
          data.append(&char, count: 1)
      }
      return data
  }
}

class Utils {
  
    static func generate(mnemonic:String = generateMnemonic(), bip:Int = 330) -> (hexPrivateKey:String, hexPublicKey:String, terraAddress:String, mnemonic:String) {
        if mnemonic_check(mnemonic) != 0 {
            let path = "m/44'/\(bip)'/0'/0/index"
            let index = 0
            
            var seed = Data(repeating: 0, count: 64)
            seed.withUnsafeMutableBytes { seedPtr in
                mnemonic_to_seed(mnemonic, "", seedPtr, nil)
            }
            
            if let keyPair = KeyDerivation.getKeyPair(seed: seed, path: path, index: index) {
                return (keyPair.privateKey.hex, keyPair.publicKey.hex, keyPair.terraAddress, mnemonic)
            }
        }
      
        return ("","","","")
    }
    
    private static func generateMnemonic() -> String {
        if let generated = mnemonic_generate(Int32(256)) {
          return String(cString: generated)
        } else {
          return ""
        }
    }
  
    static func ecdsa(data:Data, curve:UnsafePointer<ecdsa_curve>) -> Data {
        var hashed = Data(repeating: 0, count: 33)
        data.withUnsafeBytes { ptr in
            hashed.withUnsafeMutableBytes { keyPtr in
              ecdsa_get_public_key33(curve, ptr, keyPtr)
            }
        }

        return hashed
    }
  
    static func sha256(data:Data) -> Data {
        var hashed = Data(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            hashed.withUnsafeMutableBytes { keyPtr in
                _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), keyPtr)
            }
        }
        return hashed
    }
  
    static func ripemd160Encode(data:Data) -> Data {
        var ripemd160Result = Data(repeating: 0, count: Int(RIPEMD160_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            ripemd160Result.withUnsafeMutableBytes { keyPtr in
                ripemd160(ptr, CC_LONG(data.count), keyPtr)
            }
        }
        return ripemd160Result
    }
  
    static func bech32(prefix:String, data:Data) -> Data {
        let prefix = prefix.data(using: .utf8)!
        var result = Data(repeating: 0, count: 44)
      
        data.withUnsafeBytes { (ptr) in
            prefix.withUnsafeBytes { (ptrPrefix) in
                result.withUnsafeMutableBytes { (keyPtr) in
                  bech32_encode(keyPtr, ptrPrefix, ptr, 32)
                }
            }
        }
        return result
    }
  
    static func toWords(data:Data, inBits:UInt64, outBits:UInt64) -> Data? {
        let data = Array(data)
        var value:UInt64 = 0
        var bits:UInt64 = 0
        let maxV:UInt8 = (1 << outBits) - 1
        var result:[UInt8] = []
        
        for i in 0..<data.count {
            value = (value << inBits) | UInt64(data[i])
            bits += inBits
            
            while (bits >= outBits) {
              bits -= outBits
              //maxV가 UInt8이므로 &연산을 거치고 나면 결과는 무조건 UInt8이 된다.
              result.append(UInt8((value >> bits) & UInt64(maxV)))
            }
        }
      

        if (bits > 0) {
          //maxV가 UInt8이므로 &연산을 거치고 나면 결과는 무조건 UInt8이 된다.
          result.append(UInt8((value << (outBits - bits)) & UInt64(maxV)))
        }

        return Data(result)
    }
}
