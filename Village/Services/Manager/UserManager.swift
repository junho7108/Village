import KakaoSDKUser

final class UserManager {
    
    static let shared = UserManager()
    
    var user: User?
    
    private init() {
        
    }
}
