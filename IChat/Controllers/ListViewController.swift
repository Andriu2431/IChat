//
//  ListViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 10.09.2022.
//

import UIKit

// це дані які будуть в одному item - це дані про чат в вкладці people
struct MChat: Hashable {
    var userName: String
    var userImage: UIImage
    var lastMassage: String
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.id == rhs.id
    }
}

// енум з секціями
enum Section: Int, CaseIterable {
    case activeChats
}

// це екран коли юзер уже увійшов - екран де всі чати покзані
class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    // dataSourse буде складатись з секції та інформації про item
    var dataSourse: UICollectionViewDiffableDataSource<Section, MChat>?
    // відповідає за дані для dataSourse - чат в вкладці people
    let activeChats: [MChat] = [
        MChat(userName: "Alexey", userImage: UIImage(named: "human1")!, lastMassage: "How are you?"),
        MChat(userName: "Bob", userImage: UIImage(named: "human2")!, lastMassage: "How are you?"),
        MChat(userName: "Misha", userImage: UIImage(named: "human3")!, lastMassage: "How are you?"),
        MChat(userName: "Mila", userImage: UIImage(named: "human4")!, lastMassage: "How are you?")
    ]
    
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
    }
    
    // створюємо DataSourse - по яким секціям вертаємо ті чи інші контейнери
    private func createDataSourse() {
        dataSourse = UICollectionViewDiffableDataSource<Section,MChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind") }
            
            // в залежності від секції будемо повертати контейнер
            switch section {
            case .activeChats:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid", for: indexPath)
                cell.backgroundColor = .systemBlue
                return cell
            }
        })
    }
    
    // заповнює данними
    private func reloadData() {
        // слідкує за змінами
        var snapshot = NSDiffableDataSourceSnapshot<Section,MChat>()
        // додаємо секцію
        snapshot.appendSections([.activeChats])
        // передаємо дані в секію
        snapshot.appendItems(activeChats, toSection: .activeChats)
        // рейструємо snapshot
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
    
    // настройка CompositionalLayout - секція чатів
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            // section -> groups -> items -> size
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let gropSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .absolute(84))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: gropSize, subitems: [item])
            // зробимо відступи
            group.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 8, trailing: 0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
            return section
        }
        return layout
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
