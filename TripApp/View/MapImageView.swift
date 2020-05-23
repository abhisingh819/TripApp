//
//  MapImageView.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit
import MapKit

class MapImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var mapString:String?
    
    func loadImage(imageFromCache: NSCache<NSString, AnyObject>, coordinates:[Trip.Path], tripId:String) {
        mapString = tripId
        self.image = nil
        
        if let imageToCache = imageFromCache.object(forKey: tripId as NSString) as? UIImage {
            self.image = imageToCache
            return;
        }
        
        createMapImage(coordinates: coordinates, completionHandler: {[weak self](mapImage: UIImage?) in
            guard let StrongSelf = self else {
                return
            }
            if(StrongSelf.mapString == tripId) {
                if let returnedImage = mapImage {
                    StrongSelf.image = returnedImage
                    imageFromCache.setObject(returnedImage as AnyObject, forKey: tripId as NSString)
                }
            }
            
        })
        
    }

}

extension MapImageView {
    
    //Snapshot creation methods
    
    private func createMapImage(coordinates:[Trip.Path], completionHandler:@escaping (UIImage?)->()){
        
        let options = MKMapSnapshotter.Options()

        var locations = [CLLocationCoordinate2D]()
        
        for coordinate in coordinates {
            locations.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        let region = MKCoordinateRegion(polyline.boundingMapRect)
        
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = CGSize(width: self.bounds.width, height: self.bounds.height)

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start {[weak self] snapshot, error in
            guard let snapshot = snapshot,let strongSelf = self else {
                print("Snapshot error: \(String(describing: error))")
                completionHandler(nil)
                return
            }

            completionHandler(strongSelf.drawLineOnImage(snapshot: snapshot, loc: locations))
        }

    }
    
    private func drawLineOnImage(snapshot: MKMapSnapshotter.Snapshot, loc: [CLLocationCoordinate2D]) -> UIImage {
        let image = snapshot.image

        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, 0)

        // draw original image into the context
        image.draw(at: CGPoint.zero)

        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()

        // set stroking width and color of the context
        context!.setLineWidth(2.0)
        context!.setStrokeColor(UIColor.red.cgColor)

        context!.move(to: snapshot.point(for: loc[0]))
        for i in 0...loc.count-1 {
          context!.addLine(to: snapshot.point(for: loc[i]))
          context!.move(to: snapshot.point(for: loc[i]))
        }

        // apply the stroke to the context
        context!.strokePath()

        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()

        // end the graphics context
        UIGraphicsEndImageContext()

        return resultImage!
    }
    
}
