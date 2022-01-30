// pinentry-tem - A barebones pinentry for macOS using Touch ID and Keychain.
// Author: Alexander Pushkov <alexander@notpushk.in>
// SPDX-License-Identifier: ISC

import Foundation
import LocalAuthentication
import Darwin.C

let keychainServiceName = "sh.ale.PinentryTem.password"
let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
let reason = "validate your Tem Shop purchase"

// Save the passphrase into Keychain.
func setPassword(password: String) -> Bool  {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: keychainServiceName,
        kSecValueData as String: password
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
}

// Get the passphrase from Keychain.
func getPassword() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: keychainServiceName,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess,
        let passwordData = item as? Data,
        let password = String(data: passwordData, encoding: String.Encoding.utf8)
    else { return nil }

    return password
}

func interact() {
    let context = LAContext()
    context.touchIDAuthenticationAllowableReuseDuration = 0

    var error: NSError?
    guard context.canEvaluatePolicy(policy, error: &error) else {
        print("ERR 83886179 Your Mac doesn't support deviceOwnerAuthenticationWithBiometrics")
        exit(EXIT_FAILURE)
    }

    print("OK hOI! welcom to... da TEM SHOP!!!")
    while let input = readLine() {
        if input.lowercased().hasPrefix("setpass") {
            // TODO: use a CLI option
            guard setPassword(password: "SUPERSECURE") else {
                print("ERR 83886179 ??????")
                continue
            }
            print("OK tem set password to 'SUPERSECURE'!!! (change it using Keychain Access)")
            continue
        }

        switch input.lowercased() {
            case "getpin":
                context.evaluatePolicy(policy, localizedReason: reason) { success, error in
                    if success && error == nil {
                        guard let password = getPassword() else {
                            print("ERR 83886179 you don hav da passwords,")
                            return
                        }
                        print("D \(password)")
                        print("OK thanks PURCHASE!")
                    } else {
                        let errorDescription = error?.localizedDescription ?? "Unknown error"
                        print("ERR 83886179 \(errorDescription)")
                    }
                }
            case "bye":
                print("OK bOI")
                exit(EXIT_SUCCESS)
            default:
                print("OK fdshfg")
        }
    }

    // on EOF, continue running until ^C
    dispatchMain()
}

setbuf(__stdoutp, nil)
interact()
