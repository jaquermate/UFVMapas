//
//  ViewController.swift
//  UFVMapas
//
//  Created by Jesus M Martínez de Juan on 22/2/18.
//  Copyright © 2018 CETYS. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {

    @IBOutlet var nombreLocalizacion: UITextField!
    @IBAction func guardar(_ sender: Any) {
        let _nombreLocalizacion = self.nombreLocalizacion.text!
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entidad = NSEntityDescription.entity(forEntityName: "Estudios", in: managedContext)
        
        let registro = NSManagedObject(entity: entidad!, insertInto: managedContext)
        
        registro.setValue(_nombreLocalizacion, forKey: "nombre")
        
        do{
            try managedContext.save()
            print("localizacion guardada ok")
        }   catch let error as NSError{
            print("No se ha podido escribir la localizacion \(error), \(error.userInfo)")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelar(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

