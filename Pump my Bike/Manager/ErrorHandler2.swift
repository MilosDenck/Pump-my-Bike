//
//  ErrorHandler2.swift
//  Pump my Bike
//
//  Created by Milos Denck on 09.06.25.
//

import Foundation


class ErrorHandler2: ObservableObject {
    @Published var errorMessage: String?
    @Published var isShowingError: Bool = false
    @Published var errorTitle: String?
    
    func showError(message: String, title: String? = nil) {
        self.errorMessage = message
        self.errorMessage = title
        self.isShowingError = true
    }
}
