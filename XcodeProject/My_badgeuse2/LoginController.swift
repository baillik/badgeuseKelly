//
//  LoginController.swift
//  My_badgeuse2
//
//  Created by Killian BAILLIF on 12/04/2017.
//  Copyright © 2017 Killian BAILLIF. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    
    @IBOutlet weak var inputLogin: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func connection(_ sender: Any) {
        
        self.label.center = CGPoint(x: 90, y: 100)
        self.label.textAlignment = .center
        self.label.backgroundColor = UIColor.red
        self.label.textColor = UIColor.white
        self.label.font = UIFont(name: self.label.font.fontName, size: 23)
        self.label.text = "Not Allowed"
        
        let userLogin: String = inputLogin.text!
        let userPass:  String = inputPassword.text!
        
        if (userLogin.isEmpty || userPass.isEmpty)
        {
            
            // display alert
            let alertController = UIAlertController(title: "Alert", message: "All fields required", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let json = ["login": userLogin, "password": userPass]
        
        //create the url with URL
        let url = URL(string: "https://auth.etna-alternance.net/identity")!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            self.view.addSubview(self.label)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json.count != 0) {
                        // Check if the user have an accompte on etna
                        let login : String = json["login"] as! String
                        let url = URL(string: "https://auth.etna-alternance.net/api/users/\(login)")
                        URLSession.shared.dataTask(with: url!, completionHandler: {
                            (alert, response, error) in
                            if(error != nil){
                                print("error")
                                self.view.addSubview(self.label)
                            }else{
                                do{
                                    
                                    // Try the group of the user
                                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                                        let groups = (json["groups"] as? NSArray) {
                                        let student: String = "student"
                                        for group in groups {
                                            if ((group as! String).caseInsensitiveCompare(student) == ComparisonResult.orderedSame) {
                                                nbconnection.countco = 2
                                                self.performSegue(withIdentifier: "MainPage", sender: self)
                                            }
                                        }
                                    }
                                    else {
                                        self.view.addSubview(self.label)
                                    }
                                }catch let error as NSError{
                                    print(error)
                                    self.view.addSubview(self.label)
                                }
                            }
                        }).resume()
                    }
                    else {
                        self.view.addSubview(self.label)
                    }
                }
                else {
                    self.view.addSubview(self.label)
                }
                
                
            } catch let error {
                print(error.localizedDescription)
                self.view.addSubview(self.label)
            }
        })
        task.resume()
    }
    
}