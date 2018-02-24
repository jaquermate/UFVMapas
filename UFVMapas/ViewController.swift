//
//  ViewController.swift
//  UFVMapas
//
//  Created by Jesus M Martínez de Juan on 22/2/18.
//  Copyright © 2018 CETYS. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import UserNotifications
class ViewController: UIViewController, MKMapViewDelegate {
    var clasificacionElegida = ""
    var nombre: String = ""
    var lat: Double = 0
    var long: Double = 0
    var identificador: String = ""
    
    
    @IBOutlet var miMapa: MKMapView!
    @IBOutlet var labelNombre: UILabel!
    @IBOutlet var labelLong: UILabel!
    
    @IBOutlet var labelLat: UILabel!
    
    @IBOutlet var guardarBtn: UIBarButtonItem!
    @IBOutlet var nombreLocalizacion: UITextField!
    
    @IBOutlet var latitud: UITextField!
    
    @IBOutlet var longitud: UITextField!
    
    @IBOutlet var nombreDisplay: UITextField!
  
    @IBOutlet var longDisplay: UITextField!
    
    @IBOutlet var latDisplay: UITextField!
    
    @IBOutlet var actualizarBoton: UIButton!
    @IBOutlet var trashBtn: UIBarButtonItem!
    var arrayNombresExistentes = [String]()
    
    
    @IBAction func llevameBtn(_ sender: Any) {
        //Te lleva a mapas de apple pero con un itinerario ya hecho
        let latLLevame: CLLocationDegrees = Double(labelLat.text!)!
        let longLLevame: CLLocationDegrees = Double(labelLong.text!)!
        let nombreLLevame: String = labelNombre.text!
        let regionDistance: CLLocationDistance = 1000;
        let coordinates = CLLocationCoordinate2DMake(latLLevame, longLLevame)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = nombreLLevame
        mapItem.openInMaps(launchOptions: options)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(clasificacionElegida)
        //El usuario nos da permiso para mandar notificaciones (solo se pregunta la 1a vez)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            
        })
        //Carga en la ventana de mapa segun las coordenadas correspondientes
        if identificador == "miIdentificador"{
            miMapa.showsBuildings = true
            miMapa.showsCompass = true
            miMapa.showsScale = true
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.001, 0.001)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            miMapa.setRegion(region, animated: true)
            
        
            let anotacion = MKPointAnnotation()
            anotacion.coordinate = location
            anotacion.title = nombre
            anotacion.subtitle = "Punto exacto de " + nombre
            miMapa.addAnnotation(anotacion)
            
            
            labelNombre.text = nombre
            labelLong?.text = String(long)
            labelLat?.text = String(lat)
        }
    }
    @IBAction func guardar(_ sender: Any) {//Guarda un nuevo sitio de tipo estudio
        var nombreExistente = false
        let _nombreLocalizacion = self.nombreLocalizacion.text!
        let _latitudLocalizacion = NSDecimalNumber(string: self.latitud.text!)
        let _longitudLocalizacion = NSDecimalNumber(string: self.longitud.text!)
        //Doy valores a las var de las notificaciones
        let content = UNMutableNotificationContent()
        content.title = "Añadido"
        content.subtitle = "Nuevo nombre: "
        content.body = _nombreLocalizacion
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8, repeats: false)
        //Ningun campo puede estar vacío
        if !(self.nombreLocalizacion.text?.isEmpty)! && !(self.latitud.text?.isEmpty)! && !(self.longitud.text?.isEmpty)!{
            //Comprueba si el nombre que intentas introducir ya existe
            for i in 0 ... arrayNombresExistentes.count-1 {
                if arrayNombresExistentes[i] == self.nombreLocalizacion.text {
                    nombreExistente = true
                }
            }
            //Ventana avisando de que ya existe
            if nombreExistente == true{
                let refreshAlert = UIAlertController(title: "Nombre ya introducido", message: "Por favor introduzca otro", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Entendido", style: .default, handler: { (action: UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
                }))
                present(refreshAlert, animated: true, completion: nil)
            } else{//Si no existe
                // Guarda el nuevo elemento
                //Manda la notificacion
                let requestNot = UNNotificationRequest(identifier: "guardandoNombre", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(requestNot, withCompletionHandler: nil)
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                
                let managedContext = appDelegate.persistentContainer.viewContext
                //En la siguiente linea se ve que se hace en funcionde la clasificacionElegida pasada en el segue
                let entidad = NSEntityDescription.entity(forEntityName: clasificacionElegida, in: managedContext)
                
                let registro = NSManagedObject(entity: entidad!, insertInto: managedContext)
                
                registro.setValue(_nombreLocalizacion, forKey: "nombre")
                registro.setValue(_latitudLocalizacion, forKey: "latitud")
                registro.setValue(_longitudLocalizacion, forKey: "longitud")
                
                do{
                    try managedContext.save()
                    print("localizacion guardada ok. Latitud:" + String(describing: _latitudLocalizacion) + " , longitud: " + String(describing: _longitudLocalizacion))
                    
                }   catch let error as NSError{
                    print("No se ha podido escribir la localizacion \(error), \(error.userInfo)")
                }
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    @IBAction func cancelar(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editarBtn(_ sender: Any) {//activa los botones relativos a la edicion
        self.nombreDisplay.isEnabled = true
        self.longDisplay.isEnabled = true
        self.latDisplay.isEnabled = true
        self.actualizarBoton.isEnabled = true
        self.trashBtn.isEnabled = true
        
    }
    @IBAction func actualizarBtn(_ sender: UIButton) {//guarda los cambios hechos al editar
        let _nombreLocalizacion = self.nombreDisplay.text!
        let _latitudLocalizacion = NSDecimalNumber(string: self.latDisplay.text!)
        let _longitudLocalizacion = NSDecimalNumber(string: self.longDisplay.text!)
        print (arrayNombresExistentes)
        //Ningun campo puede estar vacío
        if !(self.nombreDisplay.text?.isEmpty)! && !(self.latDisplay.text?.isEmpty)! && !(self.longDisplay.text?.isEmpty)!{
            // Guarda el nuevo elemento
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                
                let managedContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult> (entityName : clasificacionElegida)
                
                do {
                    let results = try managedContext.fetch(request)
                    if results.count > 0{
                        for result in results as! [NSManagedObject]{
                            if let nombreFetch = result.value(forKey: "nombre") as? String{
                                if nombreFetch == ""{
                                    managedContext.delete(result)
                                }
                                print(nombreFetch)
                                
                                if labelNombre!.text == nombreFetch{
                                    result.setValue(_nombreLocalizacion, forKey: "nombre")
                                    result.setValue(_latitudLocalizacion, forKey: "latitud")
                                    result.setValue(_longitudLocalizacion, forKey: "longitud")
                                    do{
                                        try managedContext.save()
                                    }
                                    catch{
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                catch{
                    
                }
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
    }
    
    @IBAction func eliminarBtn(_ sender: UIBarButtonItem) {//elimina un registro
        //primero muestra una alerta de confirmacion
        let refreshAlert = UIAlertController(title: "Eliminar", message: "Seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult> (entityName : self.clasificacionElegida)
            
            do {
                let results = try managedContext.fetch(request)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let nombreFetch = result.value(forKey: "nombre") as? String{
                            if self.labelNombre!.text == nombreFetch{
                                managedContext.delete(result)
                                do{
                                    try managedContext.save()
                                }
                                catch{
                                    
                                }
                            }
                        }
                    }
                }
            }
            catch{
                
            }
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
 
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

