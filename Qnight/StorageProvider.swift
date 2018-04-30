//
//  StorageProvider.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-07-28.
//  Copyright © 2017 David Choi. All rights reserved.
//
import Foundation
import FirebaseStorage

class StorageProvider {
    private static let _instance = StorageProvider()
    static var Instance: StorageProvider {
        return _instance
    }
    
    var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    
    /*
     // download files
     
     // Create a reference to the file you want to download
     let islandRef = storageRef.child("images/island.jpg")
     
     // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
     islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
     if let error = error {
     // Uh-oh, an error occurred!
     } else {
     // Data for "images/island.jpg" is returned
     let image = UIImage(data: data!)
     }
     }
     
     // manage downloads
     // Start downloading a file
     let downloadTask = storageRef.child("images/mountains.jpg").write(toFile: localFile)
     
     // Pause the download
     downloadTask.pause()
     
     // Resume the download
     downloadTask.resume()
     
     // Cancel the download
     downloadTask.cancel()
     
     
     // monitoring download progress
     // Add a progress observer to a download task
     let observer = downloadTask.observe(.progress) { snapshot in
     // A progress event occurred
     }
     
     
     
     */
    
}
