

import UIKit
import AVKit
import QuartzCore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol, ChannelProtocol {

    @IBOutlet weak var disc: EkoImage!
    @IBOutlet weak var fmBg: UIImageView!
    @IBOutlet weak var songsList: UITableView!
    
    var eHttp: HttpController = HttpController()
    var imageCache = Dictionary<String, UIImage>()
    var tableData: NSArray = NSArray()
    var channelData: NSArray = NSArray()
    var audioPlayer: AVPlayer?
    
    
    var timer: Timer?
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIImageView!
    
    //@IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnPlay: EkoButton!
    //@IBOutlet weak var btnNext: UIButton!
    
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disc.onRotation()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurVisual = UIVisualEffectView(effect: blurEffect)
        blurVisual.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        fmBg.addSubview(blurVisual)
        
        songsList.dataSource = self
        songsList.delegate = self
        
        eHttp.delegate = self
        eHttp.onSearch(url: "http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch(url: "http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        songsList.backgroundColor = UIColor.clear
        
        btnPlay.addTarget(self, action: #selector(onPlay), for: UIControlEvents.touchUpInside)
        //btnPrev.addTarget(self, action: #selector(onClick), for: UIControlEvents.touchUpInside)
        //btnNext.addTarget(self, action: #selector(onClick), for: UIControlEvents.touchUpInside)
    }
    
//    @objc func onClick(btn: UIButton) {
//        if btn == btnNext {
//            currentIndex += 1
//            if currentIndex > tableData.count - 1 {
//                currentIndex = 0
//            }
//        }else{
//            currentIndex -= 1
//            if currentIndex < 0 {
//                currentIndex = tableData.count - 1
//            }
//        }
//        onSelectRow(index: currentIndex)
//    }
    
    @objc func onPlay(btn: UIButton) {
        if btnPlay.isPlay {
            audioPlayer?.play()
        }else{
            audioPlayer?.pause()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = songsList.dequeueReusableCell(withIdentifier: "song") as! UITableViewCell
        cell.backgroundColor = UIColor.clear
        let rowData: NSDictionary = tableData[indexPath.row] as! NSDictionary
        cell.textLabel?.text = rowData["title"] as? String
        cell.detailTextLabel?.text = rowData["artist"] as? String
        //cell.imageView?.image = UIImage(named: "mayday_concert.jpg")
        let url = rowData["picture"] as? String
        let image = self.imageCache[url!]
        if image == nil {
            let img_url = URL(string: url!)
            let data = try! Data(contentsOf: img_url!)
            let img = UIImage(data: data)
            cell.imageView?.image = img
            self.imageCache[url!] = img
        }else{
            cell.imageView?.image = image
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectRow(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    func onSelectRow(index: Int) {
        let indexPath = NSIndexPath.init(row: index, section: 0)
        songsList.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        
        let rowData: NSDictionary = self.tableData[index] as! NSDictionary
        let audioUrl: String = rowData["url"] as! String
        onSetAudio(url: audioUrl)
        let img_url: String = rowData["picture"] as! String
        onSetImage(url: img_url)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let channelC: ChannelController = segue.destination as! ChannelController
        channelC.delegate = self
        channelC.channelData = self.channelData
    }
    
    func didRecieveResults(results: NSDictionary) {
        
        
        if let arrSong = results.value(forKey: "song") {
            self.tableData = arrSong as! NSArray
            self.songsList.reloadData()
            let firDict: NSDictionary = self.tableData[0] as! NSDictionary
            let audioUrl: String = firDict["url"] as! String
            onSetAudio(url: audioUrl)
            let imgUrl: String = firDict["picture"] as! String
            onSetImage(url: imgUrl)
            
        }else if let arrChannel = results.value(forKey: "channels") {
            self.channelData = arrChannel as! NSArray
        }
    }
    
    func onChangeChannel(channel_id: String) {
        let url: String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url: url)
    }
    
    func onSetAudio(url: String) {
        //self.timer?.invalidate()
        //self.playTime.text = "00:00"
        self.audioPlayer?.pause()
        let url = NSURL(string: url)
        self.audioPlayer = AVPlayer(playerItem: AVPlayerItem(url: url! as URL))
        self.audioPlayer?.play()
        btnPlay.onPlay()
        self.timer?.invalidate()
        self.playTime.text = "00:00"
        self.timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdatePlayTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func onUpdatePlayTime() {
        let now = Double(CMTimeGetSeconds((audioPlayer?.currentTime())!))
        
        if now > 0.0 {
            let t = audioPlayer?.currentItem?.asset.duration
            let pro: CGFloat = CGFloat(now / Double(CMTimeGetSeconds(t!)))
            
            progress.frame.size.width = view.frame.size.width * pro
            
            
            let all: Int = Int(now)
            let m: Int       = all % 60
            let f: Int      = Int(all/60)
            
            var time: String = ""
            
            time = f < 10 ? "0\(f):" : "\(f):"
            time += m < 10 ? "0\(m)" : "\(m)"
            
            self.playTime.text = time
            
        }
    }

    func onSetImage(url: String) {
        let image = self.imageCache[url]
        
        if image == nil {
            let img_url = URL(string: url)
            let data = try! Data(contentsOf: img_url!)
            let img = UIImage(data: data)
            self.disc.image = img
            self.fmBg.image = img
            self.imageCache[url] = img
        }else{
            self.disc.image = image
            self.fmBg.image = image
        }
    }

}

