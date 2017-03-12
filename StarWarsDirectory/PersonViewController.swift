//
//  DetailViewController.swift
//  StarWarsDirectory
//
//  Created by Toby Youngberg on 3/8/17.
//  Copyright © 2017 Toby Youngberg. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var birthday: UILabel?
    @IBOutlet weak var forceSensitive: UILabel?
    @IBOutlet weak var affiliationImage: UIImageView?
    
    var person: Person? {
        didSet {
            self.configureView()
        }
    }
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func configureView() {
        name?.text = person?.name
        
        birthday?.text = self.person?.birthdayString
        
        self.forceSensitive?.text = self.person?.forceSensitiveString
        
        self.affiliationImage?.image = self.person?.affiliationImage
        
        self.profileImage?.setProfileImage(person: person)
    }


}

