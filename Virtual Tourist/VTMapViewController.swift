//
//  VTMapViewController.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/6/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var editingMode: Bool = false
    var longPressRecogniser: UILongPressGestureRecognizer?
    var pinArray = [PinObject]()
    var pin: PinObject? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpNavigationBar()
        addGestureRecognizer()
        hideEditingMode()
        
        if let pins = fetchAllPins() {
            pinArray = pins
            restorePins(pins)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //TODO: Will save map state here
    }
    
    func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.title = AppStrings.navigationBarTitle
    }
    
    override func setEditing(editing: Bool, animated: Bool){
        
        super.setEditing(editing, animated: animated)
        if(editing) {
            showEditingMode()
            mapView.removeGestureRecognizer(longPressRecogniser!)
            editingMode = true
        }
        else {
            mapView.addGestureRecognizer(longPressRecogniser!)
            hideEditingMode()
            editingMode = false
        }
    }
    
    func showEditingMode() {
        deleteView.hidden = false
        deleteLabel.textColor = UIColor.whiteColor()
        deleteLabel.text = AppStrings.deleteViewText
    }
    
    func hideEditingMode() {
        deleteView.hidden = true
    }
    
    func addGestureRecognizer() {
        longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser!.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser!)
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "PinObject")
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func fetchAllPins() -> [PinObject]?{
        
        let fetchRequest = NSFetchRequest(entityName: "PinObject")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as? [PinObject]
        }
        catch _ {
            return nil
        }
    }
    
    func restorePins(pins: [PinObject]) {
        
        for pin in pins {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.animatesDrop = true
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func getPinObjectWithAnnatation(annotation: MKAnnotation) -> PinObject? {
        
        var pinObject: PinObject?
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        
        for pin in pinArray {
            if  pin.latitude == lat && pin.longitude == long {
                pinObject = pin
                break
            }
        }
        
        return pinObject
    }
    
    
    // Reference: http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching/3960754#3960754
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        let pin = PinObject(lat: touchMapCoordinate.latitude,long: touchMapCoordinate.longitude, context: self.sharedContext)
        pinArray.append(pin)
        
        dispatch_async(dispatch_get_main_queue()){
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "map_pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        if editingMode {
            
            if let pin = getPinObjectWithAnnatation(view.annotation!) {
                sharedContext.deleteObject(pin)
                CoreDataStackManager.sharedInstance().saveContext()
            }
            mapView.removeAnnotation(view.annotation!)
        }
            
        else {
            pin = getPinObjectWithAnnatation(view.annotation!)
            performSegueWithIdentifier("toPinSegue", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPinSegue" {
            let pinVC = segue.destinationViewController as! VTPinViewController
            pinVC.pin = pin
       } 
    }
}

