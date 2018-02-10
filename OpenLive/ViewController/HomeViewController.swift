//
//  ViewController.swift
//  Streaming
//
//  Created by Sky Xu on 1/11/18.
//  Copyright © 2018 Sky Xu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
//    reload data when fetch rooms from server
    var popularVideos: [FakeRoom] = [FakeRoom(key: "sdfs", title: "skys", img: "https://nextcity.org/images/uploads/_resized/6642874991_9b68764995_b.jpg"),
       FakeRoom(key: "sdfs", title: "skys", img: "https://nextcity.org/images/uploads/_resized/6642874991_9b68764995_b.jpg"),
        FakeRoom(key: "sdfs", title: "skys", img: "https://nextcity.org/images/uploads/_resized/6642874991_9b68764995_b.jpg")]
    
    let collectionViewDatasource = CollectionViewDatasource(items: [])
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func hostButtonTapped(_ sender: UIButton) {
        
        
        if AuthService.instance.isLoggedIn {
            let storyBoard = UIStoryboard.init(name: "CreateRoom", bundle: nil)
            let createRoomVC = storyBoard.instantiateViewController(withIdentifier: "createRoomVC") as! CreateRoomViewController
            self.navigationController?.pushViewController(createRoomVC, animated: true)
        } else {
            let storyBoard = UIStoryboard.init(name: "Register", bundle: nil)
            let registerVC = storyBoard.instantiateViewController(withIdentifier: "registerVC") as! RegisterViewController
            self.navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.collectionViewDatasource.items = popularVideos
        self.collectionView.dataSource = self.collectionViewDatasource
        
//        trigger collecionViewFlowlayout delegate
        self.collectionView.delegate = self
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//     update Cell UI vy calling configureCell call back function
        collectionViewDatasource.configureCell = { (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCell
            cell.img.loadImageFromUrlString(urlString: self.popularVideos[indexPath.row].img)
            
            return cell
        }
        
       
    }
}

extension HomeViewController: UICollectionViewDelegate {
//    go to watch VC when click on the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard.init(name: "LiveRoom", bundle: nil)
        let liveRoomVC = storyBoard.instantiateViewController(withIdentifier: "liveRoomVC") as! LiveRoomViewController
        self.navigationController?.pushViewController(liveRoomVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(250)
        let width: CGFloat
        let section = indexPath.section
        switch (section) {
        case (0):
            width = self.collectionView.bounds.size.width - 20
        case (1):
            width = (self.collectionView.bounds.size.width - 40) / 2
        default:
            width = 250
        }
        
        return CGSize(width: width, height: height)
    }
}

