//
//  FileListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
//    var _path: String = ""
    var _pathList: [String] = []
    
    var _tableView: UITableView = UITableView()
    var _datas: Array<Files.Metadata> = []
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(pathList: [String]){
        super.init(nibName: nil, bundle: nil)
        self._pathList = pathList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = _pathList.last
        self.navigationController?.delegate = self
        
        //
        _tableView = UITableView(frame: self.view.bounds, style: .plain)
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        
        self.view.addSubview(_tableView)
        
        
        load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func load(){
        if let client = DropboxClientsManager.authorizedClient {
            client.files.listFolder(path: makePath()).response { response, error in
                if let metadata = response {
                    self._datas = []
//                    print("Entries: \(metadata.entries)")
                    for entry in metadata.entries {
                        self._datas.append(entry)
                    }
                    self._tableView.reloadData()
                } else {
                    print(error!)
                }
            }
        }
    }
    
    func makePath() -> (String) {
        var ret: String = ""
        for v in _pathList {
            ret += "/" + v
        }
        print(ret)
        return ret
    }
    
    public func getPathCount() -> (Int){
        return _pathList.count
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        print("もどった")
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        print("もどった")
    }


    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = _datas[indexPath.row].name

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((_datas[indexPath.row] as? Files.FolderMetadata) != nil) {
//            NotificationCenter.default.post(name: Notification.Name("FileListTapped"), object: _datas[indexPath.row])
            
            var l: [String] = _pathList
            l.append(_datas[indexPath.row].name)
            self.navigationController?.pushViewController(FileListViewController(pathList: l),
                                                          animated: true)
        }
    }
}
