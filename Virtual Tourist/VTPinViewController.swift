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

class VTPinViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorMain: UIActivityIndicatorView!
    
    var pin: PinObject!
    
    var selectedIndexes = [NSIndexPath]()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchedResultsController.delegate = self
        activityIndicatorMain.hidden = true
        newCollectionButton.enabled = false
        
        setUpFlowLayout()
        setUpMap()
        
        fetchResults()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if (fetchedResultsController.fetchedObjects?.count == 0) {
            getFlickrDataForPin()
        }
        else {
           newCollectionButton.enabled = true
        }
    }
    
    
    func setUpFlowLayout() {
        
        let space: CGFloat = 0.5
        let dimention = (view.frame.size.width - 3) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimention, dimention)
        flowLayout.sectionInset = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)

    }
    
    
    private func fetchResults() {
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print(error)
        }
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "ImageObject")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    
    
    
    @IBAction func tapNewCollectionButton(sender: AnyObject) {

        if selectedIndexes.isEmpty {
            
            for item in fetchedResultsController.fetchedObjects! {
                let indexPath = fetchedResultsController.indexPathForObject(item)
                sharedContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath!) as! ImageObject)
            }
            
            getFlickrDataForPin()
        }
        
        else {
            for item in selectedIndexes {
                sharedContext.deleteObject(fetchedResultsController.objectAtIndexPath(item) as! ImageObject)
            }
            
            selectedIndexes.removeAll()
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.updateNewCollectionButton()
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
    }
    
    
    func getFlickrDataForPin() {
        
        activityIndicatorMain.center = collectionView.center
        activityIndicatorMain.hidden = false
        activityIndicatorMain.startAnimating()
        view.addSubview(activityIndicatorMain)
        var page: String!
        if (pin.maxPage == 0) {
            page = "1"
        }
        else {
            page = String(arc4random_uniform(UInt32(Int(pin.maxPage!))))
        }
        
        VTFlickrClient.sharedInstance().getPhotosForPin(String(pin.latitude), long: String(pin.longitude), page: page) { (result, pageMax, error) -> Void in
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
            
            self.pin.maxPage = self.definePageMax(pageMax!)
                
            for record in result! {
                let imageURL = record[VTFlickrClient.FlickrResponseKeys.urlm] as! String
                let id = record[VTFlickrClient.FlickrResponseKeys.id] as! String
                let image = ImageObject(imageURL: imageURL, imageId: id, context: self.sharedContext)
                image.pin = self.pin
            }
                
            CoreDataStackManager.sharedInstance().saveContext()
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
    
    
    func updateNewCollectionButton() {
        
        if selectedIndexes.isEmpty {
            newCollectionButton.title = AppStrings.newCollection
        }
        else {
            newCollectionButton.title = AppStrings.removeSelectedPictures
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: VTCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! VTCollectionViewCell
        
        configureImageCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VTCollectionViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        configureImageCell(cell, indexPath: indexPath)
        
        updateNewCollectionButton()
        
    }
    
    
    func configureImageCell(cell: VTCollectionViewCell, indexPath: NSIndexPath) {
        
        let image = fetchedResultsController.objectAtIndexPath(indexPath) as! ImageObject
        
        cell.image.image = nil        
        cell.activityIndicator.hidden = true
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.image.alpha = 0.3
        } else {
            cell.image.alpha = 1.0
        }
        
        if image.imageForPin != nil {
            cell.image.image = image.imageForPin
        }
            
        else {
            cell.image.image = UIImage(named: "imagePlaceholder")
            cell.activityIndicator.hidden = false
            cell.activityIndicator.center = cell.image.center
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
                dispatch_async(dispatch_get_main_queue(), {
                let dowloadedImage = UIImage(data: imageData!)
                image.imageForPin = dowloadedImage
                cell.image.image = dowloadedImage
                cell.activityIndicator.hidden = true
                cell.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    
    func presentAlertWithError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func definePageMax(max: NSNumber) -> NSNumber {
        let value = Int(max)
        if value < 25 {
            return max
        }
        else {
         return 25
        }
    }
    
}


//MARK: Used ColorCollection App as an example 

extension VTPinViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
            
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break

        default:
            break
        }
    }
    

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        if controller.fetchedObjects?.count > 0 {
            newCollectionButton.enabled = true
        }
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
}


    


