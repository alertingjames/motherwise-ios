//
//  VideoPlayViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayViewController: BaseViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let videoURL = URL(string: gComment.video_url)
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismiss(gesture:UITapGestureRecognizer){
        self.dismiss(animated: false, completion: nil)
    }

    
}
