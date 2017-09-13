//
//  DetailViewController.swift
//  BuscadorLibrosCoreData
//
//  Created by Erik Basto Segovia on 12/09/17.
//  Copyright © 2017 Erik Basto Segovia. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var titleDetail: UILabel!
    @IBOutlet weak var authorsDetail: UILabel!
    @IBOutlet weak var isbnDetail: UILabel!
    @IBOutlet weak var coverImageDetail: UIImageView!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let labelTitle = titleDetail{
                labelTitle.text = detail.title
            }
            if let labelAuthors = authorsDetail
            {
                labelAuthors.text = detail.authors
            }
            if let labelIsbn = isbnDetail{
                labelIsbn.text = detail.isbn
            }
            if (detail.cover != nil)
            {
                if let imageCover = coverImageDetail{
                    imageCover.image = UIImage(data: detail.cover! as Data)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Book? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

