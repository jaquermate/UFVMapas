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
    @IBAction func guardar(_ sender: Any) {//guarda un nuevo sitio de tipo estudio
        
        let _nombreLocalizacion = self.nombreLocalizacion.text!
        let _latitudLocalizacion = NSDecimalNumber(string: self.latitud.text!)
        let _longitudLocalizacion = NSDecimalNumber(string: self.longitud.text!)
        if !(self.nombreLocalizacion.text?.isEmpty)! && !(self.latitud.text?.isEmpty)! && !(self.longitud.text?.isEmpty)!{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entidad = NSEntityDescription.entity(forEntityName: "Estudios", in: managedContext)
            
            let registro = NSManagedObject(entity: entidad!, insertInto: managedContext)
            
            registro.setValue(_nombreLocalizacion, forKey: "nombre")
            registro.setValue(_latitudLocalizacion, forKey: "latitud")
            registro.setValue(_longitudLocalizacion, forKey: "longitud")
            do{
                try managedContext.save()
                print("localizacion guardada ok")
            }   catch let error as NSError{
                print("No se ha podido escribir la localizacion \(error), \(error.userInfo)")
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelar(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {//carga en la ventana de mapa segun las coordenadas correspondientes
        super.viewDidLoad()
        if identificador == "miIdentificador"{
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let region = MKCoordinateRegionMakeWithDistance(location, 70.0, 100.0)
            
            miMapa.setRegion(region, animated: true)
            labelNombre.text = nombre
            labelLong?.text = String(long)
            labelLat?.text = String(lat)
    }
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
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult> (entityName : "Estudios")
        
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func eliminarBtn(_ sender: UIBarButtonItem) {//elimina un registro
        //primero muestra una alerta de confirmacion
        let refreshAlert = UIAlertController(title: "Eliminar", message: "Seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult> (entityName : "Estudios")
            
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

