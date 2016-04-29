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
    var pinCoordinates: CLLocationCoordinate2D? = nil

    
    var data = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        setUpFlowLayout()
        setUpMap()
        getFlickrDataForPin()
    }
    
    func setUpFlowLayout() {
        let space: CGFloat = 1.0
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
            self.activityIndicatorMain.stopAnimating()
            self.data = result!
            self.collectionView.reloadData()
        }
    }
    
    private func setUpMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pinCoordinates!.latitude, pinCoordinates!.longitude)        
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let centeredRegion = MKCoordinateRegion(center: pinCoordinates!, span: span)
        
        mapView.zoomEnabled = false;
        mapView.scrollEnabled = false;
        mapView.userInteractionEnabled = false;
        mapView.setRegion(centeredRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: VTCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! VTCollectionViewCell
        let imageObject = data[indexPath.row]
        let imageStringURL = imageObject[VTFlickrClient.FlickrResponseKeys.urlm] as! String
        
        let activityIndicator = cell.activityIndicator
        activityIndicator.center = cell.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        if let image = getImageFromURL(imageStringURL) {
            cell.image.image = image
        } else {
            print("There will be a placeholder")
        }
        activityIndicator.stopAnimating()
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
