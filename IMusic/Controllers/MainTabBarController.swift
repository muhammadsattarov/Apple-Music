


import UIKit
import SwiftUI

protocol MainTabBarControllerDelegate: AnyObject {
    func minimizedTrackDetailConstroller()
    func maximizingTrackDetailContorller(viewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {
    
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private let searchVC = SearchViewController()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
    
    // MARK: - Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

// MARK: - Setup Views
private extension MainTabBarController {
    
    func setupViews() {
        
        view.backgroundColor = .white
        tabBar.backgroundColor = .white
        tabBar.tintColor = .accentColor
        
        setupTrackDetailView()
        
        var library = Library()
        
        searchVC.tabbarDelegate = self
        library.tabbarDelegate = self
        
        let hostingVC = UIHostingController(rootView: library)
        hostingVC.tabBarItem.title = "Library"
        hostingVC.tabBarItem.image = UIImage(named: "library")
        setViewControllers([
            hostingVC,
            generateViewController(
                rootViewController: searchVC,
                image: UIImage(named: "search"),
                title: "Search"
            )
        ], animated: false)
    }
    
    
    private func generateViewController(rootViewController: UIViewController,
                                        image: UIImage?,
                                        title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        return navigationVC
    }
    
    private func setupTrackDetailView() {
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        trackDetailView.delegate = searchVC
        trackDetailView.tabbarDelegate = self
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.isActive = true
        
        trackDetailView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        trackDetailView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
}

// MARK: - MainTabBarControllerDelegate
extension MainTabBarController: MainTabBarControllerDelegate {
    
    func maximizingTrackDetailContorller(viewModel: SearchViewModel.Cell?) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut) {
                self.tabBar.alpha = 0
                self.trackDetailView.miniTrackView.alpha = 0
                self.trackDetailView.maximizedStackView.alpha = 1
                self.view.layoutIfNeeded()
            }
        guard let viewModel = viewModel else { return }
        trackDetailView.configure(with: viewModel)
    }
    
    func minimizedTrackDetailConstroller() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut) {
                self.tabBar.alpha = 1
                self.trackDetailView.miniTrackView.alpha = 1
                self.trackDetailView.maximizedStackView.alpha = 0
                self.view.layoutIfNeeded()
            }
    }
}
