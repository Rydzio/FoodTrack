//
//  AlertHandler.swift
//  FoodTrack
//
//  Created by Michał Rytych on 24/2/21.
//

import UIKit

extension UIViewController {
    
      func alert(present error: Error) {
        let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print(error.localizedDescription)
    }
    
    func alert(present error: String) {
      let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      print(error)
  }
}
