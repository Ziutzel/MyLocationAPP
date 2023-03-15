//
//  ViewController.swift
//  MyLocationApp
//
//  Created by Ziutzel grajales on 14/03/23.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapa: MKMapView!
    
    let manager = CLLocationManager()
    
    //Variables para guardar la información de latitud y longitud
    var latitud : Double = 0.0
    var longitud : Double = 0.0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    
    //MARK: IBActions
    
    @IBAction func coordenadas(_ sender: UIBarButtonItem) {
        mostrarAlerta(titulo: "Tus coordenadas son : ", mensaje: "Latitud : \(latitud) , Longitud : \(longitud)")
    }
    
    
    @IBAction func zoomMapa(_ sender: UIBarButtonItem) {
        
        let ubicacionMapa = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
        
        //Nivel de zoom
        let spanMapa = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //Proporcionamos el radio
        let radioMapa = MKCoordinateRegion(center: ubicacionMapa, span: spanMapa)
        //Agregamos la region al mapa y mostramos la ubicacion del usuario
        mapa.setRegion(radioMapa, animated: true)
        mapa.showsUserLocation = true
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    
        if let ubicacion = locations.first?.coordinate {
            latitud = ubicacion.latitude
            longitud = ubicacion.longitude
            print ("Se obtuvo la ubicación")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Debug : Error al obtener la ubicación")
    }
}

extension ViewController {
    
    func mostrarAlerta(titulo: String , mensaje : String ) {
        
        let alerta = UIAlertController(title: "Coordenadas", message: mensaje, preferredStyle: .alert)
        
        let accionOK = UIAlertAction(title: "OK", style: .default) { _ in
            //Hacer algo
        }
        
        alerta.addAction(accionOK)
        present(alerta, animated: true)
    }
}
