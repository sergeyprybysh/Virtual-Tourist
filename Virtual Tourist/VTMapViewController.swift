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
    
    var pinCoordinates: CLLocationCoordinate2D? = nil //will remove it
    
    var pins = [PinObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpNavigationBar()
        addGestureRecognizer()
        hideEditingMode()
        
        pins = fetchAllPins()
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func fetchAllPins() -> [PinObject]{
        
        let fetchRequest = NSFetchRequest(entityName: "PinObject")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [PinObject]
        }
        catch _ {
            return [PinObject]()
        }
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
    // Reference: http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching/3960754#3960754
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        pinCoordinates = touchMapCoordinate
        
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
        let lat = view.annotation?.coordinate.latitude
        let long = view.annotation?.coordinate.longitude
        let epsilon = 0.000001
        if editingMode {
            print("Trying to delete")
            mapView.removeAnnotation(view.annotation!)
        }
        else {
            for item in pins {
                if fabs(item.latitude - lat!) <= epsilon && fabs(item.longitude - long!) <= epsilon {
                    
                }
            }
            var dictionary = [String: AnyObject]()
            dictionary["lat"] = lat
            dictionary["long"] = long
            dispatch_async(dispatch_get_main_queue()) {
                let pin = PinObject(dictionary: dictionary, context: self.sharedContext)
                self.pins.append(pin)
            }
            
            performSegueWithIdentifier("toPinSegue", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPinSegue" {
            let pinVC = segue.destinationViewController as! VTPinViewController
            pinVC.pinCoordinates = pinCoordinates
       } 
    }
}

