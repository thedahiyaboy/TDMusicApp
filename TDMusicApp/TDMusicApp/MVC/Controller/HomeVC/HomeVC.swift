//
//  HomeVC.swift
//  TDMusicApp
//
//  Created by dahiyaboy on 27/05/17.
//  Copyright © 2017 dahiyaboy. All rights reserved.
//

import UIKit
import MediaPlayer

class HomeVC: UIViewController , MPMediaPickerControllerDelegate{

    // MARK: - Outlets
    // MARK: -
    @IBOutlet weak var btnPlayPause : UIButton!
    @IBOutlet weak var seekSlider   : UISlider!
    
    @IBOutlet weak var ivBackground : UIImageView!
    @IBOutlet weak var lblTrackTitle: UILabel!
    @IBOutlet weak var ivTrack      : UIImageView!
    
    // MARK: - Properties
    // MARK: -
    var mediapicker : MPMediaPickerController!
    var musicPlayer : MPMusicPlayerController!
    var appMusicPlayer : MPMusicPlayerController!
    var systemMusicPlayer : MPMusicPlayerController!
    var timer = Timer()
    
    // MARK: - VC Cycles
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()

        self.seekSlider.value = 0
        
        // Command Center
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled        = true
        commandCenter.nextTrackCommand.addTarget(self, action:#selector(nextTrackCommandSelector))
        commandCenter.previousTrackCommand.isEnabled    = true
        commandCenter.nextTrackCommand.addTarget(self, action:#selector(previousTrackCommandSelector))
        commandCenter.togglePlayPauseCommand.isEnabled  = true
        commandCenter.togglePlayPauseCommand.addTarget(self, action:#selector(togglePlayPauseCommandSelector))
        
        // media setup
        
        self.mediapicker        = MPMediaPickerController.self(mediaTypes:MPMediaType.music)
        self.appMusicPlayer     = MPMusicPlayerController.applicationMusicPlayer()
        self.systemMusicPlayer  = MPMusicPlayerController.systemMusicPlayer()
        self.musicPlayer        = MPMusicPlayerController()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.resetMediaFor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // MARK: - commandCenter
    // MARK: -
    
    // Toggle b/w play & pause
    func togglePlayPauseCommandSelector(){
        self.playerHandler()
    }
    
    // play next track
    func nextTrackCommandSelector(){
     self.musicPlayer.skipToNextItem()
    }
    
    // play previous track
    func previousTrackCommandSelector(){
     self.musicPlayer.skipToPreviousItem()
    }
    
    // track player handler, mantains the state of music player.
    func playerHandler(){
        if (musicPlayer.playbackState == MPMusicPlaybackState.stopped) || (musicPlayer.playbackState == MPMusicPlaybackState.paused){
            self.musicPlayer.play()
        }
        else{
            self.musicPlayer.pause()
        }

        
        let nowPlayingItem = self.musicPlayer.nowPlayingItem
        if nowPlayingItem == nil{
            self.lblTrackTitle.text = "No track available"
            self.ivBackground.image = UIImage(named: "dm.jpg")
            self.ivTrack.image = UIImage(named: "dm.jpg")
            self.btnPlayPause.isSelected = false
            let alert = UIAlertController(title: "No Track found", message: "Please import track first.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            
            self.lblTrackTitle.text = nowPlayingItem?.title!
            self.ivBackground.image = nowPlayingItem?.artwork?.image(at: self.ivBackground.frame.size)
            self.ivTrack.image = nowPlayingItem?.artwork?.image(at: self.ivBackground.frame.size)
            self.btnPlayPause.isSelected = true
        }
        
    }
    
    func timerAction() {
        
        self.seekSlider.value = Float(self.musicPlayer.currentPlaybackTime)
    }
    
    // MARK: - MPMediaPicker
    // MARK: -
    public func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection){
        
        self.dismiss(animated: true, completion: nil)
        self.updateNowPlayingItem(mediaItemCollection)
    }
    
    public func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController){
        self.dismiss(animated: true, completion: nil)
    }
    
    // Updates the current playing track
    func updateNowPlayingItem(_ mediaItemCollection: MPMediaItemCollection) {
        if let myPlayer = self.musicPlayer {

            myPlayer.stop()
            self.seekSlider.value = 0
            let allAlbumsQuery : MPMediaQuery = MPMediaQuery.albums()
//            let arrAllAlbums : [MPMediaItemCollection] = allAlbumsQuery.collections!
           
            myPlayer.play()
            self.btnPlayPause.isSelected = true
            myPlayer.setQueue(with: allAlbumsQuery)
            self.resetMediaFor()
        }
    }
    
    // MARK: - Button Actions
    // MARK: -
    func resetMediaFor(){
        
        let nowPlayingItem = self.musicPlayer.nowPlayingItem
        
        if nowPlayingItem == nil{
            self.lblTrackTitle.text = "No track available"
            self.ivBackground.image = UIImage(named: "dm.jpg")
            self.ivTrack.image = UIImage(named: "dm.jpg")
            self.seekSlider.value = 0
            self.seekSlider.minimumValue = 0
            
        }
        else{
            
            self.lblTrackTitle.text = nowPlayingItem?.title!
            self.ivBackground.image = nowPlayingItem?.artwork?.image(at: self.ivBackground.frame.size)
            self.ivTrack.image = nowPlayingItem?.artwork?.image(at: self.ivBackground.frame.size)
            self.seekSlider.value = 0
            self.seekSlider.minimumValue = 0
            btnPlayPause.isSelected = true
            self.seekSlider.maximumValue = Float((nowPlayingItem?.playbackDuration)!)
            self.btnPlayPause.isSelected = false
            if appMusicPlayer.playbackState == .playing{
                self.musicPlayer.play()
                self.btnPlayPause.isSelected = true
            }
        }
    }
    
    @IBAction func btnNextTrackAction(_ sender: UIButton) {
        
        self.musicPlayer.skipToNextItem()
        self.resetMediaFor()
    }
    
    @IBAction func btnPreviousAction(_ sender: UIButton) {

        
        self.musicPlayer.skipToPreviousItem()
        self.resetMediaFor()
    }
    
    @IBAction func btnPlayPauseAction(_ sender: UIButton) {
        
       sender.isSelected = !sender.isSelected
       self.playerHandler()
        
    }
    
    @IBAction func btnLoadMusicAction(_ sender: UIButton) {
        
        mediapicker.allowsPickingMultipleItems = false
        mediapicker.delegate = self
        
        self.present(mediapicker, animated: true, completion: nil)
    }
    
    // seek to time slider action
    @IBAction func seekSliderAction(_ sender: UISlider) {
        self.musicPlayer.currentPlaybackTime = TimeInterval(sender.value)
    }
}
