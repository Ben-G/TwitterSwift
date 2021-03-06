//
//  ImageDownload.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import UIKit

private let errorDomain = "de.benjamin-encz.twitterswift"

func fetchImage(urlString:String) -> (Promise<UIImage>, Request?) {
  let fileName = filenameForURLString(urlString)
  
  if (NSFileManager.defaultManager().fileExistsAtPath(fileName.absoluteString!)) {
    let image = UIImage(contentsOfFile: fileName.absoluteString!)!
    return (Promise(image), nil)
  }
  
  var request: Request?
  
  var promise = Promise<UIImage> { (fulfill, reject) in
    request = Alamofire.download(.GET, urlString, { (temporaryURL, response) in
      
      let url = filenameForURLString(urlString)
      let imageData = NSData(contentsOfURL:temporaryURL)
      
      if let imageData = imageData {
        let image = UIImage(data: imageData)
        if let image = image {
          fulfill(image)
        } else {
          reject(NSError(domain: errorDomain, code: 0, userInfo: nil))
        }
      } else {
        reject(NSError(domain: errorDomain, code: 1, userInfo: nil))
      }
      
      return url
    })
    
    return
  }
  
  return (promise, request)
}

private func filenameForURLString(urlString:String) -> NSURL {
  let fileNameComponents = urlString.componentsSeparatedByString("/")
  
  let directoryURL = NSFileManager.defaultManager()
    .URLsForDirectory(.DocumentDirectory,
      inDomains: .UserDomainMask)[0]
    as! NSURL
  
  let fileName = fileNameComponents[fileNameComponents.count - 2] + fileNameComponents[fileNameComponents.count - 1]
  let pathComponent = fileName
  let url = directoryURL.URLByAppendingPathComponent(pathComponent)
  
  
  return url
}