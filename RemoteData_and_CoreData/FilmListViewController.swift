//
//  ViewController.swift
//  RemoteData_and_CoreData
//
//  Created by David on 01/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit
import CoreData

class FilmListViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseId)
        return tv
    }()
    
    let visualEffectsView: UIVisualEffectView = {
        let visualEffectsView = UIVisualEffectView(effect: nil)
        return visualEffectsView
    }()
    
    var dataProvider: DataProvider!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Film> = {
        let fetchRequest = NSFetchRequest<Film>(entityName: "Film")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "episodeId", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataProvider.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top, width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)

        dataProvider.fetchFilms { (error) in
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 5, animations: {
                            self.visualEffectsView.removeFromSuperview()
                        })
                    }
                })
                alertController.addAction(dismissAction)
                DispatchQueue.main.async {
                    self.visualEffectsView.frame = self.view.bounds
                    self.view.addSubview(self.visualEffectsView)
                    UIView.animate(withDuration: 5, animations: {
                        self.visualEffectsView.effect = UIBlurEffect(style: .dark)
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
            }
        }
    }


}

extension FilmListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseId, for: indexPath)
        let film = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = film.title
        cell.detailTextLabel?.text = film.director
        return cell
    }
}

extension FilmListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}

extension UITableViewCell {
    class var reuseId: String {
        return String(describing: self)
    }
}
