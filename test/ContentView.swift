//
//  ContentView.swift
//  test
//
//  Created by Alexandru Antonica on 08.04.2023.
//

import SwiftUI
import AlertToast

struct ErrorToast: ViewModifier {
    
    let actionCompletedViewModel: ActionCompletedViewModel
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: .constant(actionCompletedViewModel.error != nil), duration: 2, tapToDismiss: true,
                   alert: {
                let errorMessage = "test description"
                let errorTitle = "test title"
                
                return AlertToast(displayMode: .alert, type: .error(.red), title: errorTitle, subTitle: errorMessage)
            }, onTap: {
                actionCompletedViewModel.handleErrorAndClear()
            })
    }
}

extension View {
    
    func errorToast(actionCompletedViewModel: ActionCompletedViewModel) -> some View {
        modifier(ErrorToast(actionCompletedViewModel: actionCompletedViewModel))
    }
}

class ActionCompletedViewModel: ObservableObject {
    
    @Published var error: Error?
    
    func assignError(error: Error) {
        DispatchQueue.main.async {[weak self] in
            let _ = print(error)

            self?.error = error
        }
    }
    
    
    func handleErrorAndClear() {
        self.error = nil
    }
}

class AViewModel: ActionCompletedViewModel {
    
    static let shared = AViewModel()
    
    private override init() {}
    
    func doAction() {
        someOtherAction() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_): print("success")
                case .failure(let error): self.assignError(error: error)
                }
            }
        }
    }
    
    func someOtherAction(_ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.failure(NSError(domain: "qwe", code: 1)))
    }
    
}

struct ContentView: View {
    
    let aViewModel = AViewModel.shared
    
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Button("Press") {
                aViewModel.doAction()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    let _ = print(aViewModel.error)
                }
            }
        }
        .errorToast(actionCompletedViewModel: aViewModel)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
