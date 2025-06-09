
import Foundation


class ErrorHandler2: ObservableObject {
    
    @Published var errorMessage: String?
    @Published var isShowingError: Bool = false
    @Published var errorTitle: String?
    
    func showError(message: String, title: String? = nil) {
        self.errorMessage = message
        self.errorTitle = title
        self.isShowingError = true
    }
}
