//
//  BusquedaLugarViewController.swift
//  MyLocationApp
//
//  Created by Ziutzel grajales on 14/03/23.
//

import UIKit
import MapKit

class BusquedaLugarViewController: UIViewController {
    
    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var busquedaLugar: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        busquedaLugar.delegate = self
    }
    
    //MARK: Función buscar lugar
    
    func buscarLugar () {
        //Creamos el geocoder
        let geocoder = CLGeocoder()
        //Validamos si el textfield contiene información
        if busquedaLugar.text != "" {
            if let direccion = busquedaLugar.text {
                
                geocoder.geocodeAddressString(direccion) { (lugares: [CLPlacemark]? , error : Error?) in
                    
                    //Validamos si hubo error
                    if error != nil {
                        print("Debug : Error al intentar encontrar el lugar \(error?.localizedDescription)")
                    }
                    
                    //Validar si se encontró algun lugar con la busqueda
                    if let lugar = lugares?.first {
                        //Crear una anotación
                        let anotacion = MKPointAnnotation()
                        anotacion.coordinate = lugar.location!.coordinate
                        anotacion.title = direccion
                        anotacion.subtitle = "Latitud : \(lugar.location!.coordinate.latitude), Longitud : \(lugar.location!.coordinate.longitude)"
                        //Creamos el nivel de zoom con el spam y el radio con la region
                        let span = MKCoordinateSpan(latitudeDelta : 0.03 , longitudeDelta : 0.03)
                        let region = MKCoordinateRegion(center: anotacion.coordinate , span : span)
                        self.mapa.setRegion(region, animated: true)
                        self.mapa.addAnnotation(anotacion)
                    }
                }
                
            }
        }
    }
}

extension BusquedaLugarViewController : UITextFieldDelegate  {
    //Habilitar el boton del teclado para buscar al terminar de escribir
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        busquedaLugar.endEditing(true)
        return true 
    }
    
    //Identifica cuando el usuario termina de editar y se limpia del textfield el texto escrito
    func textFieldDidEndEditing(_ textField: UITextField) {
        buscarLugar ()
        busquedaLugar.text = ""
        //Ocultar teclado
        busquedaLugar.endEditing(true)
    }
    
    //Evitar que el usuario no escriba nada
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if busquedaLugar.text != "" {
            return true
        } else {
            busquedaLugar.placeholder = "Debes escribir un lugar"
            return false
        }
    }
}
