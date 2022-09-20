//
//  PeopleViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 10.09.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// контроллер де будуть всі користувачі - розписано в ListViewController
class PeopleViewController: UIViewController {
    
    // дані декодовані з файлу activeChats для активних чатів
//    let users = Bundle.main.decode([MUser].self, from: "users.json")
    // масив юзерів
    var users = [MUser]()
    // наглядач за змінами в firebase
    private var usersListener: ListenerRegistration?

    var collectionView: UICollectionView!
    var dataSourse: UICollectionViewDiffableDataSource<Section, MUser>!
    
    // енум з секціями
    enum Section: Int, CaseIterable {
        case  users
        func description(userCount: Int) -> String {
            switch self {
            case .users:
                return "\(userCount) people nearby"
            }
        }
    }
    
    private let currentUser: MUser
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }

    deinit {
        // видаляємо наглядача
        usersListener?.remove()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    
        setupSearchBar()
        setupCollectionView()
        createDataSourse()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOut))

        // в наглядача передаємо юзерів яких вже маємо, отримуємо відповідь з новими юзерами
        usersListener = ListenerService.shared.usersObserver(users: users, completion: { result in
            switch result {
            case .success(let users):
                // обновляємо масив з юзерами
                self.users = users
                self.reloadData(with: nil)
            case .failure(let error):
                self.showAlert(with: "Error!", and: error.localizedDescription)
            }
        })
    }
    
    // вихід з акаунта
    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                // пробуємо вийти з акаунта
                try Auth.auth().signOut()
                UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
            } catch {
                print("Error sing out: \(error.localizedDescription)")
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // настройка collectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        // рейструємо клас нашої секції - рейструємо хедер
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
    }
    
    // метод створює search bar
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        // в navigationBar вставляємо searchController
        navigationItem.searchController = searchController
        // не ховаємо searchController під час скролінгу
        navigationItem.hidesSearchBarWhenScrolling = false
        // не приховує панель навігації під час скролінгу
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    // заповнює данними dataSourse
    private func reloadData(with searchText: String?) {
        // фільтруємо по пошуку
        let filtred = users.filter { (user) -> Bool in
            user.contains(filter: searchText)
        }
        // слідкує за змінами
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        // додаємо секцію
        snapshot.appendSections([.users])
        // передаємо дані в секії
        snapshot.appendItems(filtred, toSection: .users)
        // рейструємо snapshot
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: Data Sourse
extension PeopleViewController {
    private func createDataSourse() {
        dataSourse = UICollectionViewDiffableDataSource<Section,MUser>(collectionView: collectionView, cellProvider: { collectionView, indexPath, user in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind") }
            
            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
            }
        })
        // налаштовуємо та повертаємо хедер
        dataSourse?.supplementaryViewProvider = { collectionView, kind, indexPath in
            // рейструємо хедер
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can not create new section header") }
            // отримаємо секцію
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknow section kind") }
            // беремо всі обєкти в секції users
            let items = self.dataSourse.snapshot().itemIdentifiers(inSection: .users)
            // заповнюємо даними хедер
            sectionHeader.configurate(text: section.description(userCount: items.count),
                                      font: .systemFont(ofSize: 36, weight: .light),
                                      textColor: .label)
            return sectionHeader
        }
    }
}

// MARK: Setup layout
extension PeopleViewController {
    // в залежності від секції будемо вертати відповідний layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind") }
            
            switch section {
            case .users:
                return self.createUsersSection()
            }
        }
        // робимо відстань між секціями
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    private func createUsersSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 15, bottom: 0, trailing: 15)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    // метод створює хедер
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        // розімр хедера
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        // створюємо його зверху
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        return sectionHeader
    }
}

// MARK: UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    // коли ми вписуємо щось в searchController
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}

// MARK: UICollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {
    // метод спацьовує коли ми нажимаємо на якийсь контейнер
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // шукаємо юзера на якого тапнули
        guard let user = self.dataSourse.itemIdentifier(for: indexPath) else { return }
        // передаємо юзера 
        let profileVC = ProfileViewController(user: user)
        // презентуємо екран з вже готовими даними про юзера якому хочемо надіслати повідомлення
        present(profileVC, animated: true, completion: nil)
    }
}

// MARK: SwiftUI

import SwiftUI

struct PeopleVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let tabBarVC = MainTabBarController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
