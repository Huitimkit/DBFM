

import UIKit
import QuartzCore

protocol ChannelProtocol {
    func onChangeChannel(channel_id: String)
}

class ChannelController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var channelList: UITableView!
    var delegate: ChannelProtocol?
    var channelData: NSArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.alpha = 0.8

        channelList.dataSource = self
        channelList.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = channelList.dequeueReusableCell(withIdentifier: "channel") as! UITableViewCell
        let rowData: NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        let channel = rowData["name"] as! String
        cell.textLabel?.text = channel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        let channel_id: String = rowData["channel_id"] as! String
        
        delegate?.onChangeChannel(channel_id: channel_id)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
}
