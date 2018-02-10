//
//  CollectionViewDatasource.swift
//  Streaming
//
//  Created by Sky Xu on 1/22/18.
//  Copyright © 2018 Sky Xu. All rights reserved.
//

import Foundation
import UIKit

typealias CollectionCellCallback = (UICollectionView, IndexPath) -> UICollectionViewCell

class CollectionViewDatasource<Item>: NSObject, UICollectionViewDataSource {
    
    var configureCell: CollectionCellCallback?
    var items: [Item]
    init(items: [Item]) {
        self.items = items
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return (items.count - 1)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if configureCell == nil {
            precondition(false, "you didn't pass collectionCongigurecell")
        }
        
        return configureCell!(collectionView, indexPath)
    }
    
}

//class CustomCollectionFlowLayout: UICollectionViewFlowLayout {
//   
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = CGFloat(320)
//        let width: CGFloat
//        let section = indexPath.section
//        print(section)
//        switch (section) {
//        case (0):
//            width = 500
//        case (1):
//            width = 250
//        default:
//            width = 250
//        }
//       
//        return CGSize(width: width, height: height)
//    }
//}
//
//
//
