//
//  Alertable.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import UIKit

extension UIViewController {
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let title = NSLocalizedString("OK", comment: "")
        
        alert.addAction(UIAlertAction(
            title: title,
            style: .default,
            handler: nil)
        )
        
        self.present(
            alert,
            animated: true,
            completion: completion
        )
    }
}
