//
//  LoginViewController.swift
//  Networking
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    
    lazy var customFBLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80, width: view.frame.width - 64, height: 50)
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        setupViews()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
        view.addSubview(customFBLoginButton)
        view.addSubview(googleLoginButton)
    }

}

// MARK: Facebook SDK

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        guard FBSDKAccessToken.currentAccessTokenIsActive() else { return }
        singIntoFirebase()
        print("Successfully logged in with facebook...")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("Did log out of facebook")
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func handleCustomFBLogin() {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.singIntoFirebase()
            }
        }
    }
    
    private func singIntoFirebase() {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
            
            if let error = error {
                print("Something went wrong with our facebook user: ", error)
                return
            }
            
            print("Successfully logged in with our FB user: ")
            self.fetchFacebookFields()
        }
    }
    private func fetchFacebookFields() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])?.start(completionHandler: { (_, result, error) in
            if let error = error {
                print(error)
            }
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print(self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
            }
        })
    }
    
    private func saveIntoFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        let values = [uid: userData]
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in
            if let error = error {
                print(error)
                return
            }
            print("Successfully saved user into firebase database")
            self.openMainViewController()
        }
    }
}
// MARK: Google SDK
extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Failed to log into Google: ", error)
            return
        }
        print("Successfully loged into Google")
        if let userName = user.profile.name, let userEmail = user.profile.email {
            let userData = ["name": userName, "email": userEmail]
            userProfile = UserProfile(data: userData)
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if let error = error {
                print("Something went wrong with our Google user: ", error)
                return
            }
            print("Successfully logged into Firebase with Google")
            self.saveIntoFirebase()
            
        }
    }
}
