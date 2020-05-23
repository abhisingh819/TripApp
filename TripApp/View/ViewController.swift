//
//  ViewController.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var tripTableView: UITableView!
    private var tripDataSource = [Trip]()
    private var tripPresenter : TripViewPresenter?
    private var cache = NSCache<NSString,AnyObject>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripPresenter = TripViewPresenter(view: self)
        tripPresenter?.updateModalToView()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

extension ViewController: TripView {
    
    func update(trip: [Trip]) {
        tripDataSource = []
        tripDataSource.append(contentsOf: trip)
        tripTableView.reloadData()
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tripTableView.dequeueReusableCell(withIdentifier: "tripCell") as? TripTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(tripDataSource[indexPath.row], imageFromCache: cache);
        return cell
    }
    
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let mapViewController = storyboard.instantiateViewController(identifier: "mapViewContoller") as? MapViewController {
            if let presenter = tripPresenter {
                mapViewController.location.append(contentsOf:presenter.createCoordinates(paths: tripDataSource[indexPath.row].simple_path))
                
                mapViewController.duration.append(contentsOf: presenter.getTripDuration(path: tripDataSource[indexPath.row].simple_path))
            }
            self.present(mapViewController, animated: true, completion: nil)
        }
    }
    
}

