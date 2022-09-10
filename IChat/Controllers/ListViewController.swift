//
//  ListViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 10.09.2022.
//

import UIKit

// це дані які будуть в одному item - це дані про чат в вкладці people
struct MChat: Hashable, Decodable {
    var username: String
    var userImageString: String
    var lastMessage: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.id == rhs.id
    }
}

// енум з секціями
enum Section: Int, CaseIterable {
    case  waitingChats, activeChats
}

// це екран коли юзер уже увійшов - екран де всі чати покзані
class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    // dataSourse буде складатись з секції та інформації про item
    var dataSourse: UICollectionViewDiffableDataSource<Section, MChat>?
    // дані декодовані з файлу activeChats для активних чатів
    let activeChats = Bundle.main.decode([MChat].self, from: "activeChats.json")
    // дані декодовані з файлу waitingChats для неактивних чатів
    let waitingChats = Bundle.main.decode([MChat].self, from: "waitingChats.json")
    
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
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellid")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellid2")
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid", for: indexPath)
                cell.backgroundColor = .systemYellow
                return cell
            case .waitingChats: // не активні чати
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid2", for: indexPath)
                cell.backgroundColor = .systemBlue
                return cell
            }
        })
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
        // зробимо відступи
        group.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 8, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        return section
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
