//
//  AddNewItemViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 15/2/21.
//

import UIKit

class AddNewItemViewController: UIViewController {
    
    @IBOutlet weak var productNameTextField: UITextField!
        @IBOutlet weak var datePicked: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
