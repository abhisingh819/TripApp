//
//  TripTableViewCell.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var tripStartTime: UILabel!
    @IBOutlet weak var tripEndTime: UILabel!
    @IBOutlet weak var mapImgView: MapImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mapImgView.image = nil
    }
    
    func configureCell(_ trip: Trip, imageFromCache: NSCache<NSString,AnyObject>){
        tripStartTime.text = "Start Time : \(trip.start_time)"
        tripEndTime.text = "End Time : \(trip.end_time)"
        mapImgView.loadImage(imageFromCache: imageFromCache, coordinates: trip.simple_path, tripId: trip.trip_id)
    }

}
