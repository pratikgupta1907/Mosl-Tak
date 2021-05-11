//
//  ViewController.swift
//  Mosl Tak
//
//  Created by pratik gupta on 11/05/21.
//

import UIKit
import GoogleSignIn
import AuthenticationServices


class ViewController: UIViewController {
    
    let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
    let googleButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppleBtn()
        configurGoogleBtn()
    }
    
    func configurGoogleBtn() {
        googleButton.setTitle(" Sign in with Google", for: .normal)
        googleButton.setImage(#imageLiteral(resourceName: "google"), for: .normal)
        googleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        googleButton.setTitleColor(UIColor.black, for: .normal)
        googleButton.layer.borderColor = UIColor.black.cgColor
        googleButton.layer.borderWidth = 0.5
        googleButton.layer.cornerRadius = 12
        googleButton.addTarget(self, action: #selector(googlePressed), for: .touchUpInside)
        
        self.view.addSubview(googleButton)
        
        googleButton.translatesAutoresizingMaskIntoConstraints  = false
        NSLayoutConstraint.activate([
            googleButton.bottomAnchor.constraint(equalTo: authorizationButton.topAnchor, constant: -20),
            googleButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            googleButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            googleButton.heightAnchor.constraint(equalTo: authorizationButton.heightAnchor, multiplier: 1)
        ])
        
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    func configureAppleBtn() {
        authorizationButton.cornerRadius = 12
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        
        self.view.addSubview(authorizationButton)
        authorizationButton.translatesAutoresizingMaskIntoConstraints  = false
        NSLayoutConstraint.activate([
            authorizationButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            authorizationButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            authorizationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            authorizationButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06)
        ])
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController =
            ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    @objc func googlePressed() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func deatilScreenLoad(email: String) {
        let detailVC = UINavigationController(rootViewController: DetailVC())
        detailVC.navigationBar.topItem?.title = email
        self.present(detailVC, animated: true)
    }
    
}

extension ViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
     //   let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let email = user.profile.email
        
        deatilScreenLoad(email: email ?? "No email")
        
    }
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            let appProvider = ASAuthorizationAppleIDProvider()
            appProvider.getCredentialState(forUserID: userIdentifier) { (cState, error) in
                switch cState {
                
                    case .revoked:
                        print("revoked")
                    case .authorized:
                        print("authorized")
                    case .notFound:
                        print("notFound")
                    case .transferred:
                        print("transferred")
                    @unknown default:
                        print("default")
                }
            }
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            let username = passwordCredential.user
            let password = passwordCredential.password
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Failed")
    }
    
}

