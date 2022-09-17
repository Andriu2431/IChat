//
//  ListViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 10.09.2022.
//

import UIKit

// це екран коли юзер уже увійшов - екран де всі чати покзані
class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    // dataSourse буде складатись з секції та інформації про item
    var dataSourse: UICollectionViewDiffableDataSource<Section, MChat>?
    // дані для активних чатів
    let activeChats = [MChat]()
    // дані очікуючих чатів
    let waitingChats = [MChat]()
    
    // енум з секціями
    enum Section: Int, CaseIterable {
        case  waitingChats, activeChats
        
        // в залежності від секції верне строку
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting chats"
            case .activeChats:
                return "Active chats"
            }
        }
    }
    
    private let currentUser: MUser
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupSearchBar()
        
        createDataSourse()
        reloadData()
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
        
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
    }
    
    // заповнює данними dataSourse
    private func reloadData() {
        // слідкує за змінами
        var snapshot = NSDiffableDataSourceSnapshot<Section,MChat>()
        // додаємо секцію
        snapshot.appendSections([.waitingChats, .activeChats])
        // передаємо дані в секії
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        snapshot.appendItems(activeChats, toSection: .activeChats)
        // рейструємо snapshot
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: Data Sourse
extension ListViewController {
    
    // створюємо DataSourse - по яким секціям вертаємо ті чи інші контейнери
    private func createDataSourse() {
        dataSourse = UICollectionViewDiffableDataSource<Section,MChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind") }
            
            // в залежності від секції будемо повертати контейнер
            switch section {
            case .activeChats: // активні чати
                return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chat, for: indexPath)
            case .waitingChats: // не активні чати
                return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chat, for: indexPath)
            }
        })
        // налаштовуємо та повертаємо хедер
        dataSourse?.supplementaryViewProvider = { collectionView, kind, indexPath in
            // рейструємо хедер
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can not create new section header") }
            // отримаємо секцію
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknow section kind") }
            // заповнюємо даними хедер
            sectionHeader.configurate(text: section.description(),
                                      font: .laoSangamMN20(),
                                      textColor: UIColor(red:0.57, green:0.57, blue:0.57, alpha:1.0))
            return sectionHeader
        }
    }
}

// MARK: Setup layout
extension ListViewController {
    
    // в залежності від секції будемо вертати відповідний layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind") }
            
            switch section {
            case .activeChats:
                return self.createActiveChats()
            case .waitingChats:
                return self.createWaitingChats()
            }
        }
        // робимо відстань між секціями
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    // метод вертає NSCollectionLayoutSection для не активних чатів
    private func createWaitingChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let gropSize = NSCollectionLayoutSize(widthDimension: .absolute(88),
                                              heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: gropSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        // відстань між групами
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        // як буде скролитись
        section.orthogonalScrollingBehavior = .continuous
        
        // створюємо хедер
        let sectionHeader = createSectionHeader()
        // вставляємо його в масив хедерів
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    // метод вертає NSCollectionLayoutSection для активних чатів
    private func createActiveChats() -> NSCollectionLayoutSection {
        // section -> groups -> items -> size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let gropSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: gropSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        
        // створюємо хедер
        let sectionHeader = createSectionHeader()
        // вставляємо його в масив хедерів
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
extension ListViewController: UISearchBarDelegate {
    // коли ми вписуємо щось в searchController
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}


// MARK: SwiftUI
import SwiftUI

struct ListVCProvider: PreviewProvider {
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
