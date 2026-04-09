import Flutter
import UIKit
import iZettleSDK

public class SwiftZettlePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zettle", binaryMessenger: registrar.messenger())
    let instance = SwiftZettlePlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
      registrar.addApplicationDelegate(instance)
  }

    private func topController() -> UIViewController {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow?.rootViewController ?? UIViewController()
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let pluginResponse = ZettlePluginResponse(methodName: call.method)

      guard let method = call.method as String? else {
          pluginResponse.status = false
          pluginResponse.message = ["result": "Invalid method"]
          result(pluginResponse.toDict())
          return
      }

      switch (method) {
        case "init":
          guard let args = call.arguments as? [String:Any] else {
              pluginResponse.status = false
              pluginResponse.message = ["result": "Invalid arguments"]
              result(pluginResponse.toDict())
              return
          }
          let initResult = _init(args)
          pluginResponse.status = initResult
          pluginResponse.message = ["result": initResult]
          result(pluginResponse.toDict())

        case "requestPayment":
          guard let args = call.arguments as? [String:Any] else {
              pluginResponse.status = false
              pluginResponse.message = ["result": "Invalid arguments"]
              result(pluginResponse.toDict())
              return
          }
          _requestPayment(args) { success, message in
              pluginResponse.status = success
              pluginResponse.message = message
              result(pluginResponse.toDict())
          }
      case "requestRefund":
        guard let args = call.arguments as? [String:Any] else {
            pluginResponse.status = false
            pluginResponse.message = ["result": "Invalid arguments"]
            result(pluginResponse.toDict())
            return
        }
        _requestRefund(args) { success, message in
            pluginResponse.status = success
            pluginResponse.message = message
            result(pluginResponse.toDict())
        }
      case "showSettings":
        _showSettings()
          pluginResponse.status = true
          pluginResponse.message = [:]
          result(pluginResponse.toDict())
        default:
          pluginResponse.status = false
          pluginResponse.message = ["result": "Method not implemented"]
          result(pluginResponse.toDict())
      }
    }
    
    func _init(_ options: [String:Any]) -> Bool {
        guard let clientID = options["iosClientId"] as? String,
              let callbackURL = options["redirect"] as? String,
              let url = URL(string: callbackURL) else {
            return false
        }

        do {
            let authenticationProvider = try iZettleSDKAuthorization(
                clientID: clientID,
                callbackURL: url)

            iZettleSDK.shared().start(with: authenticationProvider)

            return true
        } catch {
            return false
        }
    }

    func _requestPayment(_ payment: [String:Any], completion: @escaping ((Bool, [String:Any?]) -> Void)) {
        let enableTipping = (payment["enableTipping"] as? Bool) ?? true
        guard let reference = payment["reference"] as? String,
              let amountValue = payment["amount"] as? Double else {
            completion(false, ["status": "failed"])
            return
        }
        let amount = NSDecimalNumber(value: amountValue)
        
        iZettleSDK.shared().charge(amount: amount, enableTipping: enableTipping, reference: reference, presentFrom: topController()) { payment, error in
            
            if (error != nil) {
                completion(false, [
                    "status": "failed",
                ])
            } else if (payment == nil) {
                completion(false, [
                    "status": "canceled",
                ])
            } else if let payment = payment {
                completion(true, [
                    "status": "completed",
                    "amount": payment.amount,
                    "gratuityAmount": payment.gratuityAmount,
                    "cardType": payment.cardBrand,
                    "cardPaymentEntryMode": payment.entryMode,
                    "cardholderVerificationMethod": nil,
                    "tsi": payment.tsi,
                    "tvr": payment.tvr,
                    "applicationIdentifier": payment.aid,
                    "cardIssuingBank": nil,
                    "maskedPan": payment.obfuscatedPan,
                    "panHash": payment.panHash,
                    "applicationName": payment.applicationName,
                    "authorizationCode": payment.authorizationCode,
                    "installmentAmount": payment.installmentAmount,
                    "nrOfInstallments": payment.numberOfInstallments,
                    "mxFiid": payment.mxFIID,
                    "mxCardType": payment.mxCardType,
                    "reference": payment.referenceNumber,
                ])
            }
        }
    }
    
    func _requestRefund(_ refund: [String:Any], completion: @escaping ((Bool, [String:Any?]) -> Void)) {
        guard let reference = refund["reference"] as? String,
              let refundValue = refund["refundAmount"] as? Double else {
            completion(false, ["status": "failed"])
            return
        }
        let receiptNumber = refund["receiptNumber"] as? String
        let refundAmount = NSDecimalNumber(value: refundValue)

        iZettleSDK.shared().refund(amount: refundAmount, ofPayment: reference, withRefundReference: receiptNumber, presentFrom: topController()) { payment, error in
            if (error != nil) {
                completion(false, [
                    "status": "failed",
                ])
            } else if (payment == nil) {
                completion(false, [
                    "status": "canceled",
                ])
            } else {
                completion(true, [
                    "status": "completed",
                ])
            }

        }
    }

    func _showSettings() {
        iZettleSDK.shared().presentSettings(from: topController())
    }
}

public class ZettlePluginResponseWrapper: NSObject {
    var response: ZettlePluginResponse!
    var result: FlutterResult!

    init(result: @escaping FlutterResult) {
        self.result = result
    }

    
    func flutterResult() {
        result(response.toDict())
    }
}

public class ZettlePluginResponse: NSObject {
    var methodName: String
    var status: Bool = false
    var message: [String:Any?]?

    init(methodName: String) {
        self.methodName = methodName
    }


    func toDict() -> [String:Any?] {
        return [
            "status": status,
            "message": message,
            "methodName": methodName
        ]
    }
}
