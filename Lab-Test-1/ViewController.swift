//
//  ViewController.swift
//  Lab-Test-1
//
//  Created by SimMacbook on 5/14/21.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    // destination variable
    var destination: CLLocationCoordinate2D!
    
    var marklocations = [CLLocationCoordinate2D]()
    
    
    var destinationLat = 0.0
    var destinationLong = 0.0
    var userlati = 0.0
    var userlongit = 0.0
    var Count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
         
        // start updating the location
        locationManager.startUpdatingLocation()
        
        addDoubleTap()
        
        // giving the delegate of MKMapViewDelegate to this class
        mapView.delegate = self
        addSingleTap()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        userlati = latitude
        userlongit = longitude
        
        
        displayLocation(latitude: latitude, longitude: longitude, title: "My location", subtitle: "you are here")
    }
    
    
  
    
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        mapView.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    func addPolygon() {
        let coordinates = marklocations.map {$0}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    

 
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        Count = Count + 1
        
        if(Count == 4){
            
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
                        
            annotation.title = "A"
            annotation.coordinate = marklocations[0]
            mapView.addAnnotation(annotation)
           
            
        }
        
        else{
            
        if(Count == 1){
        annotation.title = "A"
            
        }
        else if(Count == 2){
            
            
            annotation.title = "B"
        }
        
        else if(Count == 3){
            
            annotation.title = "C"
        }
       
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        destination = coordinate
        
        marklocations.append(destination)
        addPolygon()
        
        }
       
    }
    

    func addSingleTap() {
        let Tap = UITapGestureRecognizer(target: self, action: #selector(singlePin))
        Tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(Tap)
        
    }
    
    @objc func singlePin(sender: UITapGestureRecognizer) {
        
        
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        destinationLat = coordinate.latitude
        destinationLong = coordinate.longitude
        
        
       
    }


    
    @IBAction func drawRoute(_ sender: Any) {
        
        mapView.removeOverlays(mapView.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        
        for locat in marklocations{
            
        let destinationPlaceMark = MKPlacemark(coordinate: locat)
        
            
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        
        
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            

            
          
        }
    }
    
    
   
    }

}

extension ViewController: MKMapViewDelegate {
    
        //MARK: - viewFor annotation method
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            if annotation is MKUserLocation {
                return nil
            }

            switch annotation.title {
            case "My location":
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
                annotationView.markerTintColor = UIColor.blue
                return annotationView
            case "A":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
                
            case "B":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
                
            case "C":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
                
            default:
                return nil
            }
        }

//        //MARK: - callout accessory control tapped
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {



            let coordinate1Lat = userlati

            let coordinate1Long = userlongit

            let coordinate1 = CLLocation(latitude: coordinate1Lat, longitude: coordinate1Long)

            let coordinate2 = CLLocation(latitude: destinationLat, longitude: destinationLong)

            let distance = String(coordinate1.distance(from: coordinate2))

            let alertController = UIAlertController(title: "Distance from source location", message: distance, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
     if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}

