//
//  MainTabBarController.swift
//  IChat
//
//  Created by Andrii Malyk on 10.09.2022.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let currentUser: MUser
    
    init(currentUser: MUser = MUser(username: "777", email: "777", avatarStringURL: "777", description: "777", sex: "777", id: "777")) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // чати
        let listViewController = ListViewController(currentUser: currentUser)
        // люди
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        
        // картинки для tabBar
        tabBar.tintColor = #colorLiteral(red: 0.5568627451, green: 0.3529411765, blue: 0.968627451, alpha: 1) // колір кнопок знизу
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .medium) // щоб фото були жирніші
        guard let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfiguration),
              let convImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfiguration) else { return }
        
        // тут будуть контролери для TabBar
        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: "People", image: peopleImage),
            generateNavigationController(rootViewController: listViewController, title: "Conversations", image: convImage)
        ]
    }
    
    // метод буде створювати navController
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        navigationVC.navigationBar.barTintColor = .mainWhite()
        return navigationVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
