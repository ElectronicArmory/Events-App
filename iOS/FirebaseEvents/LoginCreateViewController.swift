//
//  LoginCreateViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit



class LoginCreateViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cornerRadius = CGFloat(18.0)
        
        loginButton.layer.cornerRadius = cornerRadius
        
        createAccountButton.layer.cornerRadius = cornerRadius
        createAccountButton.layer.borderWidth = 1.0
        createAccountButton.layer.borderColor = UIColor.white.cgColor
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginTapped(_ sender: Any) {
        self.navigationController?.pushViewController((storyboard?.instantiateViewController(withIdentifier: "LoginViewController"))!, animated: true)
    }
    
    
    @IBAction func CreateTapped(_ sender: Any) {
        self.navigationController?.pushViewController((storyboard?.instantiateViewController(withIdentifier: "CreateAccountViewController"))!, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

