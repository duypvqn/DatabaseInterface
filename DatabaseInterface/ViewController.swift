//
//  ViewController.swift
//  DatabaseInterface
//
//  Created by Duy Pham Viet on 2018/08/14.
//  Copyright © 2018 Duy Pham Viet. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.isHidden = true
        setupTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTable(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }

    @IBAction func realmDB(sender:UIButton){
        if tableView.isHidden {
            tableView.isHidden = false
            tableView.reloadData()
        }
        
        IDatabase.db = IRealm.self
        IDatabase.curVer = 2
        IDatabase.dbFileName = "DBInterface"
        IDatabase.migrationAction = {
            let config = Realm.Configuration(
                schemaVersion:IDatabase.curVer,
                migrationBlock:{migration, oldSchemaVer in
                    //Unit test migration
                    //check version and implement changing
                    if oldSchemaVer < 1 {
                        //add createDate and updateDate
                    }
                    
                    if oldSchemaVer < 2 {
                        //rename updateDate -> modifierDate
                        migration.renameProperty(onType: "BaseObject", from: "updateDate", to: "modifierDate")
                    }
            })
            
            Realm.Configuration.defaultConfiguration = config
        }
    }
    
    @IBAction func SQliteDB(sender:UIButton){
        if tableView.isHidden {
            tableView.isHidden = false
            tableView.reloadData()
        }
        
        IDatabase.db = ISQLite.self
        IDatabase.dbFileName = "DBInterface"
        IDatabase.migrationAction = {
            //sqlite
            
        }
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource{
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "create table"
        case 1:
            cell.textLabel?.text = "delete table"
        case 2:
            cell.textLabel?.text = "insert"
        case 3:
            cell.textLabel?.text = "update"
        case 4:
            cell.textLabel?.text = "delete"
        default:
            cell.textLabel?.text = "select"
        }
        
        return cell
    }
    
    func generateTestData<T:BaseObject>()->[T]{
        if type(of: T.self) == type(of: DAOArea.self) {
            let area1 = DAOArea()
            area1.areaId = "01"
            area1.areaName = "Tokyo"
            area1.isActivated = 1
            area1.createDate = "2018/08/15 15:35:40"
            area1.modifierDate = "2018/08/15 15:35:40"
            
            let area2 = DAOArea()
            area2.areaId = "02"
            area2.areaName = "Saitama"
            area2.isActivated = 0
            area2.createDate = "2018/08/15 15:35:40"
            area2.modifierDate = "2018/08/15 15:35:40"
            
            let area3 = DAOArea()
            area3.areaId = "03"
            area3.areaName = "Osaka"
            area3.isActivated = 0
            area3.createDate = "2018/08/15 15:35:40"
            area3.modifierDate = "2018/08/15 15:35:40"
            return [area1,area2,area3] as! [T]
        }
        else if type(of: T.self) == type(of: DAOUser.self) {
            let user1 = DAOUser()
            user1.userId = "01"
            user1.userName = "Tokyo"
            user1.lat = 35.649761
            user1.lon = 139.712996
            
            let user2 = DAOUser()
            user2.userId = "02"
            user2.userName = "Tokyo"
            user2.lat = 35.649761
            user2.lon = 139.7113013
            
            let user3 = DAOUser()
            user3.userId = "03"
            user3.userName = "Tokyo"
            user3.lat = 35.649761
            user3.lon = 139.7113013
            return [user1,user2,user3] as! [T]
        }
        return [T]()
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomDouble(min: Double, max: Double) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func randomCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //test data
        let random = randomInt(min: 0, max: 5)
        var array:[BaseObject]!
        if random % 2 == 0 {
            let arrayValue : [DAOUser] = generateTestData()
            array = arrayValue
        }
        else{
            let arrayValue : [DAOArea] = generateTestData()
            array = arrayValue
        }
        switch indexPath.row {
        case 0:
            if random % 2 == 0 {
                let _ = IDatabase.createTable(fromModel: DAOArea.self)
            }
            else{
                let _ = IDatabase.createTable(fromModel: DAOUser.self)
            }
        case 1:
            if random % 2 == 0 {
                let _ = IDatabase.deleteTable(name: DAOArea.tableName())
            }
            else{
                let _ = IDatabase.deleteTable(name: DAOUser.tableName())
            }
        case 2:
            let _ = IDatabase.insertObjs(array: array)
        case 3:
            let _ = IDatabase.updateObjs(array: array)
        case 4:
            let _ = IDatabase.deleteObjs(array: array)
        default:
            if random % 2 == 0 {
                let result : [DAOArea] = IDatabase.fetchObjs(condition: "")
                debugPrint("fetch result: \(result)")
            }
            else{
                let result : [DAOUser] = IDatabase.fetchObjs(condition: "")
                debugPrint("fetch result: \(result)")
            }
                
        }
    }
}

