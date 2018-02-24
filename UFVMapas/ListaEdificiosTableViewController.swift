//
//  ListaEdificiosTableViewController.swift
//  UFVMapas
//
//  Created by Jesus M Martínez de Juan on 24/2/18.
//  Copyright © 2018 CETYS. All rights reserved.
//

import UIKit
import CoreData
class ListaEdificiosTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext : NSManagedObjectContext? = nil
    var clasificacionElegida = "Edificio"
    var fetchedResultsController  = NSFetchedResultsController<NSFetchRequestResult>()
    var path :IndexPath? = nil
    var path2 :IndexPath? = nil
    var nombreCD : String = ""
    var latCD : Double = 0
    var longCD : Double = 0
    var arrayNombresExistentes = [String]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Edificio")
        //Elimina los campos cuyo nombre esté vacío y almacena un array de los nombre existentes
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if  let nombreFetch = result.value(forKey: "nombre") as? String{
                        
                        if nombreFetch == ""{ //Vacios
                            managedObjectContext.delete(result)
                            do{  try managedObjectContext.save()
                            }
                            catch{
                            }
                        } else { //Existentes
                            arrayNombresExistentes.append(nombreFetch)
                            print(arrayNombresExistentes)
                        }
                    }
                }
            }
        }
        catch{
            
        }
        
        //rellena la tabla dinamica con los datos del core data
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending:true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
            print("datos cargados ok")
        }   catch let error as NSError{
            print("No se ha podido leer \(error), \(error.userInfo)")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaBasica", for: indexPath)
        path = indexPath
        let registro : NSManagedObject = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        cell.textLabel?.text = registro.value(forKey: "nombre") as! String?
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert: self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete: self.tableView.deleteRows(at: [indexPath!], with: .fade)
        default:return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let pantallaDestino: ViewController = segue.destination as! ViewController
        pantallaDestino.clasificacionElegida = "Edificio"
        //en la transicion prepara las variables para pasarlas entre vistas
        if segue.identifier == "muestraMapa"{
            let indice = tableView.indexPathForSelectedRow
            
            let registro: NSManagedObject = self.fetchedResultsController.object(at: indice!) as! NSManagedObject
            
            pantallaDestino.identificador = "miIdentificador"
            pantallaDestino.long = registro.value(forKey: "longitud") as! Double
            pantallaDestino.lat = registro.value(forKey: "latitud") as! Double
            pantallaDestino.nombre = registro.value(forKey: "nombre") as! String
            
            
        } else if segue.identifier == "muestraGuardar"{
            
            
            print(pantallaDestino.clasificacionElegida + " y " + self.clasificacionElegida)
            pantallaDestino.arrayNombresExistentes = self.arrayNombresExistentes
        }
    }
}
/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */
/*
 
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */
