//
//  VTMapViewController.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/6/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import UIKit
import MapKit

class VTMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var editingMode: Bool = false
    var longPressRecogniser: UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpNavigationBar()
        addGestureRecognizer()
        hideEditingMode()
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
            print("Trying to delete")
            mapView.removeAnnotation(view.annotation!)
        }
        else {
            let lat = String(view.annotation!.coordinate.latitude)
            let long = String(view.annotation!.coordinate.longitude)
            
            VTFlickrClient.sharedInstance().getPhotosForPin(lat, long: long) { (result, error) -> Void in
                guard error == nil else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    return
                }
                print("GET DATA")
            }
            
            print("Will navigate to nex view controller")
            
        }
    }
}

