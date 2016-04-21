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
    
    var lat: Double? = 0.00
    var long: Double? = 0.00
    
    var data = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        setUpFlowLayout()
        setUpMap()
    }
    
    func setUpFlowLayout() {
        let space: CGFloat = 2.0
        let dimention = (view.frame.size.width - (space * 2)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimention, dimention)
    }
    
    func setUpMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat!, long!)
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
    
}
