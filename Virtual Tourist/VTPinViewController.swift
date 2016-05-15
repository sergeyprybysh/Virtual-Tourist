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
import CoreData

class VTPinViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicatorMain: UIActivityIndicatorView!
    
    var pin: PinObject!

    
    var data = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchedResultsController.delegate = self
        activityIndicatorMain.hidden = true
        setUpFlowLayout()
        setUpMap()
        
        fetchResults()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if pin.images.isEmpty {
            getFlickrDataForPin()
        }
    }
    
    func setUpFlowLayout() {
        let space: CGFloat = 1.0
        let dimention = (view.frame.size.width - (space * 2)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimention, dimention)
    }
    
    private func fetchResults() {
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print(error)
        }
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "ImageObject")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func getFlickrDataForPin() {
        activityIndicatorMain.center = collectionView.center
        activityIndicatorMain.hidden = false
        activityIndicatorMain.startAnimating()
        view.addSubview(activityIndicatorMain)
        
        VTFlickrClient.sharedInstance().getPhotosForPin(String(pin.latitude), long: String(pin.longitude)) { (result, error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentAlertWithError(error!)
                    self.activityIndicatorMain.stopAnimating()
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorMain.stopAnimating()
            self.activityIndicatorMain.hidden = true
            
            for record in result! {
                let imageURL = record[VTFlickrClient.FlickrResponseKeys.urlm] as! String
                let image = ImageObject(imageURL: imageURL, context: self.sharedContext)
                image.pin = self.pin
            }
                
            self.fetchResults()
            self.collectionView.reloadData()
            })
        }
    }
    
    private func setUpMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let centeredRegion = MKCoordinateRegion(center: pin.coordinate, span: span)
        
        mapView.zoomEnabled = false;
        mapView.scrollEnabled = false;
        mapView.userInteractionEnabled = false;
        mapView.setRegion(centeredRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: VTCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! VTCollectionViewCell
        
        let image = fetchedResultsController.objectAtIndexPath(indexPath) as! ImageObject
        
        configureImageCell(cell, image: image)
        
        return cell
    }
    
    //TODO: Handle delete
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func configureImageCell(cell: VTCollectionViewCell, image: ImageObject) {
        
        cell.image.image = nil
        cell.image.image = UIImage(named: "imagePlaceholder")
        
        if false {
            //Do verification that image exists
        }
        else {
            
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            VTFlickrClient.sharedInstance().getImageWithURL(image.imageURL) {
                (imageData, error) -> Void in
                guard error == nil else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentAlertWithError(error!)
                        cell.image.image = UIImage(named: "noImage")
                        cell.activityIndicator.stopAnimating()
                    })
                    return
                }
                
                let image = UIImage(data: imageData!)
                cell.image.image = image
                cell.activityIndicator.hidden = true
                cell.activityIndicator.stopAnimating()
            }
        }
    }
    
    func presentAlertWithError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func getImageFromURL(urlString: String) -> UIImage? {
        let imageURL = NSURL(string: urlString)
        if let imageData = NSData(contentsOfURL: imageURL!) {
            return UIImage(data: imageData)
        }
       return nil
    }
}

