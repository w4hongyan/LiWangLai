import LocalAuthentication

enum BiometricService {
    enum AuthError: LocalizedError {
        case notAvailable
        case cancelled
        case failed

        var errorDescription: String? {
            switch self {
            case .notAvailable: "设备不支持面容/指纹识别"
            case .cancelled: "已取消验证"
            case .failed: "验证失败，请重试"
            }
        }
    }

    static var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return available
    }

    static var biometricTypeName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "面容 ID"
        case .touchID: return "触控 ID"
        default: return "生物识别"
        }
    }

   static func authenticate(reason: String = "验证身份以查看礼簿内容") async -> Result<Void, AuthError> {
       guard isAvailable else { return .failure(.notAvailable) }
       let context = LAContext()
       do {
           let success = try await context.evaluatePolicy(
               .deviceOwnerAuthentication,
               localizedReason: reason
           )
            return success ? .success(()) : .failure(.failed)
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .systemCancel, .appCancel:
                return .failure(.cancelled)
            default:
                return .failure(.failed)
            }
        } catch {
            return .failure(.failed)
        }
    }
}
