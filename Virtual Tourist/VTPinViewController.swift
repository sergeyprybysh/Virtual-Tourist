//
//  VTPinViewController.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/18/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class VTPinViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicatorMain: UIActivityIndicatorView!
    var pinCoordinates: CLLocationCoordinate2D? = nil //will remove it

    
    var data = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        setUpFlowLayout()
        setUpMap()
        getFlickrDataForPin()
    }
    
    func setUpFlowLayout() {
        let space: CGFloat = 2.0
        let dimention = (view.frame.size.width - (space * 2)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimention, dimention)
    }
    
    func getFlickrDataForPin() {
        activityIndicatorMain.center = collectionView.center
        activityIndicatorMain.startAnimating()
        view.addSubview(activityIndicatorMain)
        
        VTFlickrClient.sharedInstance().getPhotosForPin(String(pinCoordinates!.latitude), long: String(pinCoordinates!.longitude)) { (result, error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.activityIndicatorMain.stopAnimating()
                })
                return
            }
            self.data = result!
            self.activityIndicatorMain.stopAnimating()
        }
    }
    
    private func setUpMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pinCoordinates!.latitude, pinCoordinates!.longitude)
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: VTCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! VTCollectionViewCell
        return cell
    }
    
    private func getImageFromURL(urlString: String) -> UIImage? {
        let imageURL = NSURL(string: urlString)
        if let imageData = NSData(contentsOfURL: imageURL!) {
            return UIImage(data: imageData)
        }
       return nil
    }
    
}
