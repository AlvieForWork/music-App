//
//  musicAppViewController.swift
//  musicAppViewController
//
//  Created by worker on 2022/6/1.
//

import UIKit
import AVFoundation

class musicAppViewController: UIViewController {
    
    @IBOutlet weak var musicPic: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var playTimeSlider: UISlider!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let player = AVPlayer()
    var playerItem:AVPlayerItem!
    var asset:AVAsset?
    var playMusicIndex = 0
    var musics = music()
    var musicIndex = 0
    var repeatIndex = 0
    var repeatBool = false
    var shuffleIndex = 0

    override func viewDidLoad() {

        super.viewDidLoad()
        
        
        playMusic()
        updateUI()
        nowPlayTime()
        updateMusicUI()
        musicEnd()
        repeatBtn.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal)
        shuffleBtn.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
        stopBtn.setImage(setbuttonImage(systemName: "pause.fill", pointSize: 30), for: .normal)
        nextBtn.setImage(setbuttonImage(systemName: "forward.end.fill", pointSize: 30), for: .normal)
        backBtn.setImage(setbuttonImage(systemName:"backward.end.fill" , pointSize: 30), for: .normal)
        

    }
    
    //設定Button圖示大小跟圖案
    func setbuttonImage(systemName:String,pointSize:Int) -> UIImage? {
        let sfsymbol = UIImage.SymbolConfiguration(pointSize: CGFloat(pointSize), weight: .bold , scale: .large )
        let sfsymbolImage = UIImage(systemName: systemName, withConfiguration: sfsymbol)
        return sfsymbolImage
        
    }
    
    //更新歌曲、歌手、畫面圖片
    func updateUI() {
        musicNameLabel.text = allmusic[musicIndex].musicName
        singerLabel.text = allmusic[musicIndex].singer
        musicPic.image = UIImage(named: allmusic[musicIndex].musicPic)
    }
    //顯示播放幾秒func
    func timeShow(time:Double) -> String {
        //同時得到商和餘數
        let time = Int(time).quotientAndRemainder(dividingBy: 60)
        let timeString = ("\(String(time.quotient)) : \(String(format: "%02d", time.remainder))")
        return timeString
    }
    
    
    //更新歌曲時確認歌的時間讓Slider也更新
    func updateMusicUI() {
        guard let timeduration = playerItem?.asset.duration else{
            return
        }
    let seconds = CMTimeGetSeconds(timeduration)
        endTime.text = timeShow(time:seconds)
        playTimeSlider.minimumValue = 0
        playTimeSlider.maximumValue = Float(seconds)
        playTimeSlider.isContinuous = true
        print("second:\(seconds)")
 
    }
    
    //    播放幾秒的Func 不懂
    func nowPlayTime(){
    //        播放的計數器從1開始每一秒都在播放
    player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
    //          如果音樂要播放
    if self.player.currentItem?.status == .readyToPlay{
    //                就會得到player播放的時間
    let currenTime = CMTimeGetSeconds(self.player.currentTime())
    //                Slider移動就會等於currenTime的時間
    self.playTimeSlider.value = Float(currenTime)
    //                顯示播放了幾秒
    self.startTime.text = self.timeShow(time: currenTime)
    }
    })
    }
    

    
    //確認音樂結束
    func musicEnd(){
    //        叫出  NotificationCenter.default.addObserver來確認音樂是否結束
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
    //            如果結束有打開repeatBool 就會從頭播放
    if self.repeatBool{
    let musicEndTime: CMTime = CMTimeMake(value: 0, timescale: 1)
    self.player.seek(to: musicEndTime)
    self.player.play()
    }else{
    //            如果結束沒有打開repeatBool就會撥下一首歌
    self.playNextSound()
    }
    }
    }
    

    
    //播放音樂
    func playMusic() {
        guard let fileUrl = Bundle.main.url(forResource: allmusic[musicIndex].music, withExtension: "mp4") else { return }
        playerItem = AVPlayerItem(url:fileUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    

    //播放下一首歌 musicIndex是musiclist裡的
    func playNextSound() {
        if shuffleIndex == 1{
            musicIndex = Int.random(in: 0...allmusic.count - 1)
            updateUI()
            playMusic()
            updateMusicUI()
        }else{
            musicIndex += 1
            if musicIndex < allmusic.count {
                updateUI()
                playMusic()
                updateMusicUI()
            }else{
                musicIndex = 0
                updateUI()
                playMusic()
                updateMusicUI()
            }
            
        }
    }
    
    //按前一首
    func backSound() {
        if shuffleIndex == 1 {
            musicIndex = Int.random(in: 0...allmusic.count - 1)
            updateUI()
            playMusic()
            updateMusicUI()
        }else{
            musicIndex -= 1
            if musicIndex < 0 {
                musicIndex = 0
                updateUI()
                playMusic()
                updateMusicUI()
            }else{
                updateUI()
                playMusic()
                updateMusicUI()
            }
        }
    }
    

    
    //重複播放
    @IBAction func repeatMusic(_ sender: UIButton) {
        repeatIndex += 1
        if repeatIndex == 1 {
            repeatBtn.setImage(setbuttonImage(systemName: "repeat.1", pointSize: 15), for: .normal)
            repeatBool = true
        }else{
            repeatIndex = 0
            repeatBtn.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal )
            repeatBool = false
        }
        
    }
    

    //隨機播放
    @IBAction func shuffleMusic(_ sender: UIButton) {
        shuffleIndex += 1
        if shuffleIndex == 1 {
            shuffleBtn.setImage(setbuttonImage(systemName: "shuffle.circle.fill", pointSize: 20), for: .normal)
            print("musicIndex\(musicIndex)")
            print("allmusic.count\(allmusic.count)")
        }else{
            shuffleIndex = 0
            shuffleBtn.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
        }
    }
    

    //音樂暫停播放
    
    @IBAction func stopMusic(_ sender: UIButton) {
        playMusicIndex += 1
        if playMusicIndex == 1 {
            player.pause()
            stopBtn.setImage(setbuttonImage(systemName: "play.fill", pointSize: 30), for: .normal)
        }else{
            player.play()
            playMusicIndex = 0
            stopBtn.setImage(setbuttonImage(systemName: "pause.fill", pointSize: 30), for: .normal)
        }
    }
    
   //下一首
    @IBAction func nextMusic(_ sender: UIButton) {
        playNextSound()
    }
    
    //上一首
    @IBAction func backMusic(_ sender: UIButton) {
        backSound()
    }
    
    
    //音量
    @IBAction func volumeChange(_ sender: UISlider) {
        player.volume = volumeSlider.value
    }
    
 
    
    
    @IBAction func timeChange(_ sender: UISlider) {
        let changeTime = Int64(sender.value)
        let time:CMTime = CMTimeMake(value: changeTime, timescale: 1)
        player.seek(to: time)
        print("sender.value\(sender.value)")
        print("sender.maximumValue\(sender.maximumValue)")
    }
    
    



}
