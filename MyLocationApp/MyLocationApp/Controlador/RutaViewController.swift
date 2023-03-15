//
//  RutaViewController.swift
//  MyLocationApp
//
//  Created by Ziutzel grajales on 15/03/23.
//

import UIKit
import MapKit

class RutaViewController: UIViewController {

    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var destinoTextField: UITextField!
    
    var latitud : CLLocationDegrees?
    var longitud : CLLocationDegrees?
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        destinoTextField.delegate = self
        
        
        manager.delegate = self
        mapa.delegate = self
        //Pedir ubicación al usuario
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        mapa.showsUserLocation = true
    }
    
    func buscarLugar(){
        self.mapa.removeAnnotations(mapa.annotations)
        self.mapa.removeOverlays(mapa.overlays)
        
        let geocoder = CLGeocoder()  //para convertir entre un lugar y coordenadas
        if destinoTextField.text != "" {
            if let direccion = destinoTextField.text {
                geocoder.geocodeAddressString(direccion) { (lugares: [CLPlacemark]?, error: Error?) in
                    //validar si hubo error
                    if error != nil {
                        print("Debug: Error al encontrar lugar \(error!.localizedDescription)")
                    }
                    
                    guard let destinoRuta = lugares?.first?.location else { return }
                    
                    //si hubo algun lugar con la busqueda
                    if let lugar = lugares?.first {
                        //crear una anotacion
                        let anotacion = MKPointAnnotation()
                        anotacion.coordinate = lugar.location!.coordinate
                        anotacion.title = direccion
                        anotacion.subtitle = "Lat: \(lugar.location!.coordinate.longitude) , Lon: \(lugar.location!.coordinate.longitude)"
                        
                        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                        
                        self.mapa.setRegion(region, animated: true)
                        self.mapa.addAnnotation(anotacion)
                        
                        //Trazar ruta
                        self.trazarRuta(coordenadasDestino: destinoRuta.coordinate)
                    }
                    
                }
            }
        }
    }
    
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D){
        //origen
        guard let coordOrigen = manager.location?.coordinate else { return }
        
        //Custom annotation
        let anotacion = MKPointAnnotation()
        anotacion.coordinate = coordOrigen
        anotacion.title = "Estas aqui"
        self.mapa.addAnnotation(anotacion)
        
        //crear un origen - destino
        let origenPlaceMark = MKPlacemark(coordinate: coordOrigen)
        let destinoPlaceMark = MKPlacemark(coordinate: coordenadasDestino)
        
        //Crear un mapkit Item
        let origenItem = MKMapItem(placemark: origenPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        
        //Solicitud de ruta
        let solicitudRuta = MKDirections.Request()
        solicitudRuta.source = origenItem
        solicitudRuta.destination = destinoItem
        
        //Como se va a viajar (pie, bici, carro, transporte publico)
        solicitudRuta.transportType = .automobile
        solicitudRuta.requestsAlternateRoutes = true
        
        let direccion = MKDirections(request: solicitudRuta)
        
        direccion.calculate { respuesta, error in
            //mostrar alerta en caso de que haya error
            if error != nil {
                print("Debug: error al calcular la ruta")
                self.mostrarAlerta(titulo: "Error", mensaje: error!.localizedDescription)
            }
            
            if let respuestaSegura = respuesta {
                let ruta = respuestaSegura.routes.first
                self.mapa.addOverlay(ruta!.polyline)
                self.mapa.setVisibleMapRect((ruta?.polyline.boundingMapRect)!, animated: true)
            }
        }
    }
}

extension RutaViewController : CLLocationManagerDelegate {
    
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let ubicacion = locations.first else { return }
        latitud = ubicacion.coordinate.latitude
        longitud = ubicacion.coordinate.longitude
    }
    
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener la ubicación")
        mostrarAlerta(titulo: "ERROR", mensaje: "Error al obtener la ubicacion")
    }
}

extension RutaViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderizado.strokeColor = .red
        return renderizado
    }
}
    

extension RutaViewController {
        
        func mostrarAlerta(titulo: String , mensaje : String ) {
            
            let alerta = UIAlertController(title: "Ubicación", message: mensaje, preferredStyle: .alert)
            
            let accionOK = UIAlertAction(title: "OK", style: .default) { _ in
                //Hacer algo
            }
            
            alerta.addAction(accionOK)
            present(alerta, animated: true)
        }
    }

extension RutaViewController : UITextFieldDelegate  {
    
    //Habilitar el boton del teclado para buscar al terminar de escribir
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        destinoTextField.endEditing(true)
        return true
    }
    
    //Identifica cuando el usuario termina de editar y se limpia del textfield el texto escrito
    func textFieldDidEndEditing(_ textField: UITextField) {
        buscarLugar ()
        destinoTextField.text = ""
        //Ocultar teclado
        destinoTextField.endEditing(true)
    }
    
    //Evitar que el usuario no escriba nada
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if destinoTextField.text != "" {
            return true
        } else {
            destinoTextField.placeholder = "Debes escribir un lugar"
            return false
        }
    }
}
