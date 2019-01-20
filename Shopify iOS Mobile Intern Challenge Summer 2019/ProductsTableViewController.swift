//
//  ProductsTableViewController.swift
//  Shopify iOS Mobile Intern Challenge 2019
//
//  Created by atala rchidi on 2019-01-12.
//  Copyright © 2019 Atala Rchidi. All rights reserved.
//

import UIKit

class ProductsTableViewController: UITableViewController {

    @IBOutlet weak var viewOfActivityIndiicator: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let urlCustomCollection = "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    
    var myRowProduct : String = ""
    
    var productListOfDetails = [Prod]()
    var productsPassedOver2 = [Prod]()
    
    var productVariants = [Var]()
    var productsPassedOverForVariants = [Var]()
    
    var productImg = [Img]()
    var productsPassedOverForImage = [Img]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating();
        
        getCustomID(tag5: myRowProduct)
    }
    
    
    
    //How many rows we want in our table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsPassedOver2.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        cell.selectionStyle = .none

        cell.textLabel?.numberOfLines = 0 //as many lines needed
        
        cell.textLabel?.text = "\(productsPassedOver2[indexPath.row].nameOfProduct) = \(productsPassedOverForVariants[indexPath.row].inventory) \n\(productsPassedOver2[indexPath.row].title) \n\(productsPassedOver2[indexPath.row].bodyHtml)"
        
        do{
            let data: Data = try Data.init(contentsOf: productsPassedOverForImage[indexPath.row].src)
            cell.imageView?.image = UIImage(data:data)
        }
        catch {
            print(error)
            cell.imageView?.image = nil
        }
        return cell
    }
    
    
/*-------------------------------------------------------------------------------------------------------------------
     Custom Collections: trigger nanana fill with infos
---------------------------------------------------------------------------------------------------------------------*/
    
    struct CC: Decodable{
        let cusCol: [CustomCollections]
        
        enum CodingKeys: String, CodingKey {
            case cusCol = "custom_collections"
        }
    }
    
    struct CustomCollections: Decodable{
        let id: Int
        let title: String
    }


    func getCustomID(tag5: String)
    {
        let urlObj = URL(string: urlCustomCollection)
        let whatWasClicked = tag5
        var intCustom = 0
        
        URLSession.shared.dataTask(with: urlObj!) { (data, response, error ) in
            do {
                let jsonDecoder = JSONDecoder()
                let cc = try jsonDecoder.decode(CC.self, from: data!)
                
                for collection in cc.cusCol{
                    let tagsGroup : String =  collection.title
                    intCustom = collection.id

                    if tagsGroup.contains(whatWasClicked){
                        self.listOfCollects(number: intCustom)
                    }
                }
            }
            catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume() //after resume the urlseesion start
    }


/*--------------------------------------------------------------------------------------------------------------------
                                                    List of collects
---------------------------------------------------------------------------------------------------------------------*/
    
    struct CollectsList: Decodable{
        let collects: [Coll]
    }
    
    struct Coll: Decodable{
        let productId: Int
        
        enum CodingKeys: String, CodingKey {
            case productId  = "product_id"
        }
    }

    
    func listOfCollects(number:Int)
    {
        let listOfProductsForACustomCollection = "https://shopicruit.myshopify.com/admin/collects.json?collection_id=\(number)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        let urlObj = URL(string: listOfProductsForACustomCollection)
        
        URLSession.shared.dataTask(with: urlObj!) { (data, response, error ) in
            do{
                var arrayOfId: [Int] = []
                let jsonDecoder = JSONDecoder()
                let collectsList = try jsonDecoder.decode(CollectsList.self, from: data!)

                for collect in collectsList.collects{
                    arrayOfId.append(collect.productId)
                }
                
                self.collectionDetails(arrayInt: arrayOfId){ (productListOfDetail, productVariant, productImg) in
                    
                    //go back to the main thread
                    DispatchQueue.main.async {
                        
                        if self.activityIndicator.isAnimating == true {
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                        self.productsPassedOver2 = productListOfDetail
                        self.productsPassedOverForVariants = productVariant
                        self.productsPassedOverForImage = productImg
                        self.tableView.reloadData() //UITableView.reloadData() must be used from main thread only
                    }
                }
            }
            catch let jsonErr{
                print("Failed to fetch the collect list for a custom collection: ", jsonErr)
            }
        }.resume()
    }
    
    
/*--------------------------------------------------------------------------------------------------------------------
                                                    Collection Details
---------------------------------------------------------------------------------------------------------------------*/
    
    struct Products: Decodable{
        let products: [Prod]
    }
    struct Prod: Decodable{
        let title: String
        let bodyHtml: String
        let nameOfProduct: String
        let variants: [Var]
        let images: [Img]
        
        enum CodingKeys: String, CodingKey{
            case title
            case bodyHtml = "body_html"
            case nameOfProduct = "product_type"
            case variants
            case images
        }
    }
    
    struct Var: Decodable{
        let inventory: Int
        
        enum CodingKeys: String, CodingKey{
            case inventory = "inventory_quantity"
        }
    }
    
    struct Img : Decodable{
        let src: URL
    }
    
    func collectionDetails(arrayInt: [Int], completion: @escaping ([Prod], [Var], [Img]) -> Void)
    {
        var s = ""
        
        for id in arrayInt{
            s += "\(id),"
        }
        
        let res = s.dropLast() //remove the last comma
        
        let linkOfProductDetails = "https://shopicruit.myshopify.com/admin/products.json?ids=\(res)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        let urlObj = URL(string: linkOfProductDetails)
        
        URLSession.shared.dataTask(with: urlObj!) { (data, response, error ) in
            do{
                let jsonDecoder = JSONDecoder()

                let products = try jsonDecoder.decode(Products.self, from: data!)
            
                for i in products.products{
                    
                    var x = 0
                    var imgSrc = ""
                    
                    for j in i.variants{
                        x += j.inventory
                    }
                    
                    for k in i.images{
                        imgSrc += k.src.absoluteString
                    }
                    
                    self.productListOfDetails.append(Prod.init(title: i.title, bodyHtml: i.bodyHtml, nameOfProduct: i.nameOfProduct, variants: [Var.init(inventory: x)], images: [Img.init(src: URL.init(string: imgSrc)!)]))
                    
                    self.productVariants.append(Var.init(inventory: x))
                    
                    self.productImg.append(Img.init(src: URL.init(string: imgSrc)!))

                }
                completion(self.productListOfDetails, self.productVariants, self.productImg)
                
            } catch let jsonErr{
                print("Failed to fetch the collect list for a custom collection: ", jsonErr)
            }
        }.resume()
    }
    
    
}
