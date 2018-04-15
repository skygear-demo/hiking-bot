//
//  MapViewController.swift
//  KLPlatform
//
//  Created by KL on 31/3/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import MapKit

struct orderedPlacemarks{
  var index: Int
  var placemark: CLPlacemark
}

struct orderedRoutes{
  var index: Int
  var route: MKRoute
}

class MapViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var segmentedControl: UISegmentedControl!
  let locationManager = CLLocationManager()
  var currentTransportType = MKDirectionsTransportType.automobile
  
  var destinations: [String] = []
  var placemarks: [orderedPlacemarks] = []
  var routes: [orderedRoutes] = []
  var allLocationsPin = [MKPointAnnotation]()
  
  @IBAction func showDirection(_ sender: Any) {
    switch segmentedControl.selectedSegmentIndex {
    case 0: currentTransportType = .automobile
    case 1: currentTransportType = .walking
    default: break
    }
    segmentedControl.isHidden = false
    
    displayMultipleRoutes()
  }
  
  private func displayMultipleRoutes(){
    placemarks.sort { (a, b) -> Bool in
      return a.index < b.index
    }
    
    self.mapView.removeOverlays(self.mapView.overlays)
    var start =  MKMapItem.forCurrentLocation()
    self.routes = []
    var routesCount = 0
    for placemark in placemarks{
      let currentOrder = routesCount
      
      let directionRequest = MKDirectionsRequest()
      // Set the starting point and destination
      directionRequest.source = start
      let destinationPlacemark = MKPlacemark(placemark: placemark.placemark)
      directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
      directionRequest.transportType = currentTransportType
      
      // Calculate the direction
      let directions = MKDirections(request: directionRequest)
      directions.calculate { (routeResponse, routeError) -> Void in
        guard let routeResponse = routeResponse else {
          if let routeError = routeError {
            print("Error: \(routeError)")
          }
          return
        }
        let route = routeResponse.routes[0]
        self.routes.append(orderedRoutes(index: currentOrder, route: route))
        
        // Display the line if all routes are calculated
        if self.routes.count == self.placemarks.count{
          self.routes.sort(by: { (a, b) -> Bool in
            return a.index < b.index
          })
          for route in self.routes{
            self.mapView.add(route.route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
          }
        }
      }
      start = directionRequest.destination!
      routesCount += 1
    }
  }
  
  private func displayMultipleAnnotate(){
    var order = 0
    for place in destinations{
      let currentOrder = order  
      let geoCoder = CLGeocoder()
      geoCoder.geocodeAddressString(place, completionHandler: { placemarks, error in
        if let error = error {
          print(error)
          return
        }
        
        if let placemarks = placemarks {
          // Get the first placemark
          let placemark = placemarks[0]
          self.placemarks.append(orderedPlacemarks(index: currentOrder, placemark: placemark))
          
          // Add annotation
          let annotation = MKPointAnnotation()
          annotation.title = place
          
          if let location = placemark.location {
            annotation.coordinate = location.coordinate
            
            self.allLocationsPin.append(annotation)
            // Display the annotation
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations(self.allLocationsPin, animated: true)
          }
        }
      })
      order += 1
    }
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    segmentedControl.isHidden = true
    segmentedControl.addTarget(self, action: #selector(showDirection), for: .valueChanged)
    
    // Show the current user's location
    mapView.showsUserLocation = true
    
    // Request for a user's authorization for location services
    locationManager.requestWhenInUseAuthorization()
    let status = CLLocationManager.authorizationStatus()
    
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      mapView.showsUserLocation = true
    }
    
    // Convert address to coordinate and annotate it on map
    displayMultipleAnnotate()
    
    
    mapView.delegate = self
    if #available(iOS 9.0, *) {
      mapView.showsCompass = true
      mapView.showsScale = true
      mapView.showsTraffic = true
    }
  }
  
  // MARK: - MKMapViewDelegate methods
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "MyPin"
    
    if annotation.isKind(of: MKUserLocation.self) {
      return nil
    }
    
    // Reuse the annotation if possible
    var annotationView: MKAnnotationView?
    
    if #available(iOS 11.0, *) {
      var markerAnnotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
      
      if markerAnnotationView == nil {
        markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        markerAnnotationView?.canShowCallout = true
      }
      
      markerAnnotationView?.glyphText = "🕹"
      markerAnnotationView?.markerTintColor = UIColor.white
      
      annotationView = markerAnnotationView
      
    } else {
      
      var pinAnnotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
      
      if pinAnnotationView == nil {
        pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinAnnotationView?.canShowCallout = true
        pinAnnotationView?.pinTintColor = UIColor.orange
      }
      
      annotationView = pinAnnotationView
    }
    
    let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
    leftIconView.image = UIImage(named: "mapicon.png")
    annotationView?.leftCalloutAccessoryView = leftIconView
    annotationView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    if mapView.overlays.count == 1{
      renderer.strokeColor = UIColor.blue
      renderer.lineWidth = 5.0
    }else if mapView.overlays.count == 2{
      renderer.strokeColor = UIColor.orange
      renderer.lineWidth = 3.5
    }else if mapView.overlays.count == 3{
      renderer.strokeColor = UIColor.red
      renderer.lineWidth = 2.0
    }else{
      renderer.strokeColor = UIColor.purple
      renderer.lineWidth = 1.0
    }
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    var steps: [MKRouteStep] = []
    
    for route in routes{
      for step in route.route.steps{
        steps.append(step)
      }
    }
    
    let vc = StepsTableViewController()
    vc.routeSteps = steps
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}
