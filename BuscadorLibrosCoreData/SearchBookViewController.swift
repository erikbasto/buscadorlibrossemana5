//
//  SearchBookViewController.swift
//  BuscadorLibrosCoreData
//
//  Created by Erik Basto Segovia on 12/09/17.
//  Copyright © 2017 Erik Basto Segovia. All rights reserved.
//

import UIKit
import CoreData

class SearchBookViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var isbnToSearchTextField: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        isbnToSearchTextField.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SaveBook(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if(!existeISBNCoreData(isbn: isbnLabel.text!, loadBook: false))
        {
            let newBook = Book(context: context)
            newBook.title = titleLabel.text
            newBook.authors =  authorsLabel.text
            newBook.isbn = isbnLabel.text
            if(!coverImageView.isHidden)
            {
                newBook.cover = UIImagePNGRepresentation(coverImageView.image!) as NSData?
            }
            do{
                try context.save()
            }
            catch{
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            
                }
       }
        
        navigationController?.popViewController(animated: true)
       }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(validateTextFiedlContent(value: isbnToSearchTextField.text!))
        {
            if(!existeISBNCoreData(isbn: isbnToSearchTextField.text!, loadBook: true))
            {
                busquedaISBN(isbn: isbnToSearchTextField.text!)
            }
        }
        return true
    }
    
    
    /*
     
     Realizacion de la busqueda del libro y asignacion a UI
     
     */
    
    func existeISBNCoreData(isbn: String, loadBook: Bool )->Bool
    {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let booksFetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        booksFetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        do{
            let results = try context.fetch(booksFetchRequest)
            if(results.count>0)
            {
                if(loadBook)
                {
                    titleLabel.text = results[0].title
                    authorsLabel.text = results[0].authors
                    isbnLabel.text = results[0].isbn
                    if(results[0].cover != nil)
                    {
                        coverImageView.image = UIImage(data: results[0].cover! as Data)
                    }
                }
            }
            else
            {
                return false
            }
            
        }catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           
        }
        return true
    }
    
    func busquedaISBN(isbn: String)
    {
        let url:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn
        let urlToSearch = NSURL(string: url)
        let contentData:NSData? = NSData(contentsOf: urlToSearch! as URL)
        if(contentData == nil)
        {
            showAlertMessage(title: "Aviso", message: "No se ha podido conectar al servicio. Favor de reintentar más tarde")
            return
        }
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: contentData! as Data, options: []) as! NSDictionary
            if(jsonResponse.count == 0 )
            {
                showAlertMessage(title: "Aviso", message: "No se ha encontrado un libro con el ISBN proporcionado.")
                return
            }
            let bookInfo = jsonResponse["ISBN:" + isbn] as! NSDictionary
            
            titleLabel.text = bookInfo["title"] as? String
            
            let authors = (bookInfo["authors"] as! NSArray).mutableCopy() as! NSMutableArray
            var authorsName: String = ""
            for index in 0...authors.count-1
            {
                let author = authors[index] as! NSDictionary
                let name = author["name"] as? String
                authorsName = authorsName + name! + "\r\n"
            }
            authorsLabel.text = authorsName
            isbnLabel.text = isbn
            if(bookInfo["cover"] != nil)
            {
                let covers = bookInfo["cover"] as! NSDictionary
                if(covers.count > 0)
                {
                    let coverImage = covers["medium"] as! NSString
                    coverImageView.image = getBookCover(imageUrl: coverImage as String)
                    coverImageView.isHidden = false
                }
                else{
                    coverImageView.isHidden = true
                }
            }
            else{
                coverImageView.isHidden = true
            }
            
        }
        catch{
            clearFields()
        }
        
    }
    
    
    func getBookCover(imageUrl: String) -> UIImage {
        let url = NSURL(string: imageUrl)
        let imageContentData:NSData? = NSData(contentsOf: url! as URL)
        let image = UIImage(data:imageContentData! as Data)
        
        return image!
    }
    
    
    /*
     
     Validaciones previas a la busqueda: cadenas vacias y conexiona  red
     
     */
    func validateTextFiedlContent(value: String) -> Bool{
        if(isStringEmpty(stringValue: value))
        {
            showAlertMessage(title: "Aviso", message: "No se ha proporcionado un ISBN a buscar.")
            return false
        }
        if(!Reachability.isConnectedToNetwork())
        {
            showAlertMessage(title: "Aviso", message: "No cuenta con acceso a la red, favor de reintentar posteriormente.")
            return false
        }
        return true
        
    }
    
    func isStringEmpty( stringValue:String) -> Bool
    {
        var stringValue = stringValue
        var returnValue = false
        
        if stringValue.isEmpty  == true
        {
            returnValue = true
            return returnValue
        }
        stringValue = stringValue.trimmingCharacters(in: NSCharacterSet.whitespaces)
        if(stringValue.isEmpty == true)
        {
            returnValue = true
            return returnValue
            
        }
        return returnValue
        
    }
    
    /*
     
     Utilerias
     
     */
    
    func clearFields()
    {
        authorsLabel.text = "  "
        titleLabel.text = "  "
        isbnLabel.text = "  "
        coverImageView.isHidden = true
    }
    
    func showAlertMessage(title: String, message:String)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
