//
//  MapViewController.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    var location = [CLLocationCoordinate2D]()
    var duration = [Double]()
    private var geodesic = MKGeodesicPolyline()
    private var taxi: MKPointAnnotation?
    private var distance = 0.0
    private var taxiPositionIndex = 0
    private var delayStep = 0.0
    private var animationStep = 0.0
    private var dictionary: Dictionary<String, Int>?
    
    lazy var mapView: MKMapView = {
        let map = MKMapView(frame: .zero)
        map.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(map)
        
        map.topAnchor.constraint(equalTo: navigationView.bottomAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        map.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        map.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        map.delegate = self
        return map
    }()
    
    private var drawingTimer: Timer?
    private var polyline: MKPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let route = location
        distance = CLLocation(latitude: route[route.count-1].latitude, longitude: route[route.count-1].longitude).distance(from: CLLocation(latitude: route[0].latitude, longitude: route[0].longitude))
        
        center(onRoute: route, fromDistance: distance)
        
        geodesic = MKGeodesicPolyline(coordinates: route, count: route.count)
        self.mapView.addOverlay(geodesic)
        taxi = MKPointAnnotation()
        taxi?.coordinate = route[0]
        if let tax = taxi {
            mapView.addAnnotation(tax)
        }
        taxiPositionIndex = 0
        animationStep = duration[taxiPositionIndex/2]
        mapView.setCamera(MKMapCamera(lookingAtCenter: geodesic.points()[taxiPositionIndex].coordinate, fromDistance: 4*distance, pitch: 0, heading: 0), animated: false)
        perform(#selector(updatePlanePosition), with: nil, afterDelay: 0)
    }
    
    
    //Action Methods
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

private extension MapViewController {
    
    func center(onRoute route: [CLLocationCoordinate2D], fromDistance m: Double) {
        if(route.count > 0){
            addPin(coordinate: route[route.count-1], title: "destination")
        }
    }
    
    @objc func updatePlanePosition() {
        
        self.taxiPositionIndex = self.taxiPositionIndex + 1
        
        if self.taxiPositionIndex >= self.geodesic.pointCount {
            //taxi has reached end, stop moving
            return
        }
        
        let nextMapPoint = self.geodesic.points()[self.taxiPositionIndex]
        
        //convert MKMapPoint to CLLocationCoordinate2D...
        let nextCoord = nextMapPoint.coordinate
        
        //update the taxi's coordinate...
        UIView.animate(withDuration: animationStep, delay: 0, options: .curveLinear, animations: {[weak self] in
            guard let self = self else {
                return
            }
            
            self.taxi?.coordinate = nextCoord
            
            if(!self.mapView.contains(coordinate: nextCoord)) {
                print("updating camera")
                self.mapView.setCenter(nextCoord, animated: false)
            }
            
            }, completion: {[weak self](success:Bool) in
                guard let self = self else {
                    return
                }
                if success {
                    
                    if self.taxiPositionIndex >= self.geodesic.pointCount {
                        //taxi has reached end, stop moving
                        return
                    }
                    if(self.taxiPositionIndex/2 < self.duration.count){
                        self.delayStep = 0.2 * self.duration[self.taxiPositionIndex/2]
                        self.animationStep = 0.8 * self.duration[self.taxiPositionIndex/2]
                    }
                    self.perform(#selector(self.updatePlanePosition), with: nil, afterDelay: self.delayStep)
                }
        })
        
    }
    
    func addPin(coordinate: CLLocationCoordinate2D, title: String){
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude:coordinate.longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let polylineRenderer = MKPolylineRenderer(overlay: polyline)
        polylineRenderer.strokeColor = .black
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
    
}

extension MKMapView {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.visibleMapRect.contains(MKMapPoint(coordinate))
    }
    
}
