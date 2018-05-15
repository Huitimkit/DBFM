//
//  HttpController.swift
//  DBFM2
//
//  Created by addcn on 2018/5/11.
//  Copyright © 2018年 addcn. All rights reserved.
//

import UIKit
import Alamofire

protocol HttpProtocol {
    func didRecieveResults(results: NSDictionary)
}

class HttpController: NSObject {

    var delegate: HttpProtocol?
    
    func onSearch(url: String) {
        Alamofire.request(url, method: .get).responseJSON { (response) in

            if let result = response.result.value {
                let json = result as! NSDictionary
                self.delegate?.didRecieveResults(results: json)
            }
        }
        
    }
}
