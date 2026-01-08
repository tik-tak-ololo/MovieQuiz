//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 07.12.2025.
//

import UIKit

final class AlertPresenter {
    
    func presentAlert(viewController: UIViewController, alertModel: AlertModel) {
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.closure()
        }
        
        alert.addAction(action)
        
        alert.view.accessibilityIdentifier = alertModel.accessibilityIdentifier
        
        viewController.present(alert, animated: true)
        
    }
    
}
