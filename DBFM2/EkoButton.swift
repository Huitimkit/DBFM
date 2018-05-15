

import UIKit

class EkoButton: UIButton {

    var isPlay: Bool = true
    var imgPlay: UIImage = UIImage(named: "cm2_mv_btn_play_ver.png")!
    var imgPause: UIImage = UIImage(named: "cm2_mv_btn_pause_ver.png")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.addTarget(self, action: #selector(onClick), for: UIControlEvents.touchUpInside )
    }
    
    @objc func onClick(){
        isPlay = !isPlay
        
        if isPlay {
            self.setImage(imgPause, for: UIControlState.normal)
        }else{
            self.setImage(imgPlay, for: UIControlState.normal)
        }
    }
    
    func onPlay() {
        isPlay = true
        self.setImage(imgPause, for: UIControlState.normal)
    }

}
