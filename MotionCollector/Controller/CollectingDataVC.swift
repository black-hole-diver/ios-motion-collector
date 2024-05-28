import UIKit
import CoreMotion
import CoreData
import WatchConnectivity

class CollectingDataVC: UIViewController, WCSessionDelegate, SettingsTableVCDelegate, RecordIDVCDelegate {
    
    enum Status {
        case waiting
        case recording
    }
    
    var status: Status = Status.waiting {
        willSet(newStatus) {
            
            switch(newStatus) {
            case .waiting:
                print ("Stop recording on iPhone")
                waiting()
                break
                
            case .recording:
                print ("Start recording on iPhone")
                recording()
                break
            }
        }
        didSet {
            
        }
    }
    
    weak var settingsTableVC:SettingsTableVC?
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordStatusImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var currentSession: Session? = nil
    var nextSessionid: Int = 0
    var recordTime: String = ""
    var sensorOutputs = [SensorOutput]()
    var characteristicsNames  = [CharacteristicName]()
    var sessionType: SessionType = SessionType.OnlyPhone
    var sensors = [Sensor]()
    
    var startTime = TimeInterval()
    var UIUpdateTimer = Timer()
    
    var currentFrequency: Int = 0
    var recordID: Int = 0
    
    let motion = CMMotionManager()
    var motionUpdateTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: In case of testing: fillTestData()
        status = .waiting
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        findLastSessionId()
        addNamesOfCharacteristics()
        addSensorIDs()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let settingsTableVC = destination as? SettingsTableVC {
            
            settingsTableVC.delegate = self
            self.settingsTableVC = segue.destination as? SettingsTableVC
        }
        
        if let recordIDVC = destination as? RecordIDVC {
            recordIDVC.delegate = self
            
            if let recordID = sender as? Int {
                recordIDVC.selectedID = recordID
            }
        }
        
    }
    
    func startGettingData() {
        if self.motion.isAccelerometerAvailable, self.motion.isGyroAvailable {
            
            self.motion.accelerometerUpdateInterval = 1.0 / Double (currentFrequency)
            self.motion.gyroUpdateInterval = 1.0 / Double (currentFrequency)
            
            self.motion.startAccelerometerUpdates()
            self.motion.startGyroUpdates()
            
            self.motionUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/Double (currentFrequency), repeats: true, block: { (timer1) in
                if let dataAcc = self.motion.accelerometerData, let dataGyro = self.motion.gyroData {
                    
                    // let currenTime = self.returnCurrentTime()
                    
                    let GyroX = dataGyro.rotationRate.x
                    let GyroY = dataGyro.rotationRate.y
                    let GyroZ = dataGyro.rotationRate.z
                    
                    let AccX = dataAcc.acceleration.x
                    let AccY = dataAcc.acceleration.y
                    let AccZ = dataAcc.acceleration.z
                    
                    let sensorOutput = SensorOutput()
                    
                    sensorOutput.timeStamp = Date()
                    
                    sensorOutput.gyroX = GyroX
                    sensorOutput.gyroY = GyroY
                    sensorOutput.gyroZ = GyroZ
                    
                    sensorOutput.accX = AccX
                    sensorOutput.accY = AccY
                    sensorOutput.accZ = AccZ
                    
                    self.sensorOutputs.append(sensorOutput)
                }
            }
            )}
    }
    
    func stopGettingData() {
        motionUpdateTimer.invalidate()
        motionUpdateTimer = Timer()
        self.motion.stopGyroUpdates()
        self.motion.stopAccelerometerUpdates()
        self.motion.stopMagnetometerUpdates()
    }
    
    func returnCurrentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let nanoseconds = calendar.component(.nanosecond, from: date)
        
        let currentTime = "\(hour):\(minutes):\(seconds):\(nanoseconds)"
        
        return currentTime
    }
    
    func periodChangedNumberSettingsDelegate(_ number: Int){
        currentFrequency = number
    }
    
    func changeIDpressed(){
        performSegue(withIdentifier: "toRecordIDSettings", sender: recordID)
    }
    
    func recordIDChangedNumberSettingsDelegate(_ number: Int){
        recordID = number
        settingsTableVC?.recordID.text = "\(number)"
    }
    
    @IBAction func StartButtonpressed(_ sender: Any) {
        status = .recording
        
        startGettingData()
        UIUpdateTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
        
        currentSession = Session(context: context)
        currentSession?.id = Int32(nextSessionid)
        currentSession?.date = NSDate()
        currentSession?.frequency = Int32(currentFrequency)
        currentSession?.recordID = Int32(recordID)
        currentSession?.type = Int32(sessionType.rawValue)
    }
    
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        UIUpdateTimer.invalidate()
        currentSession?.duration = recordTime
        
        for sensorOutput in sensorOutputs {
            
            let characteristicGyro = Characteristic (context:context)
            characteristicGyro.x = sensorOutput.gyroX!
            characteristicGyro.y = sensorOutput.gyroY!
            characteristicGyro.z = sensorOutput.gyroZ!
            characteristicGyro.toCharacteristicName = self.characteristicsNames[1]
            
            let characteristicAcc = Characteristic (context:context)
            characteristicAcc.x = sensorOutput.accX!
            characteristicAcc.y = sensorOutput.accY!
            characteristicAcc.z = sensorOutput.accZ!
            characteristicAcc.toCharacteristicName = self.characteristicsNames[0]
            
            
            let sensorData = SensorData(context: context)
            sensorData.timeStamp = sensorOutput.timeStamp! as NSDate
            sensorData.addToToCharacteristic(characteristicGyro)
            sensorData.addToToCharacteristic(characteristicAcc)
            sensorData.toSensor = sensors[0]
            
            self.currentSession?.addToToSensorData(sensorData)
            
        }
        
        
        if sessionType == SessionType.OnlyPhone {
            ad.saveContext()
            currentSession = nil
            sensorOutputs.removeAll()
        }
        
        print ("iPhone's motion data handled")
        nextSessionid += 1
        stopGettingData()
        status = .waiting
    }
    
    @objc func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        let fraction = UInt16(elapsedTime * 1000)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%03d", fraction)
        
        recordTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        recordTime = "\(strMinutes):\(strSeconds)"
    }
    
    func waiting() {
        settingsTableVC?.periodSlider.isEnabled = true
        settingsTableVC?.currentRecordNumberLabel.text =  "\(nextSessionid)"
        settingsTableVC?.recordNumberLabel.text = "Next record number:"
        recordStatusImage.isHidden = true
        recordTimeLabel.isHidden = false
        recordTimeLabel.text = "00:00:000"
        startButton.isHidden = false
        stopButton.isHidden = false
        startButton.isEnabled = true
        stopButton.isEnabled = false
        settingsTableVC?.tableView.allowsSelection = true
    }
    
    func recording() {
        settingsTableVC?.periodSlider.isEnabled = false
        recordStatusImage.isHidden = false
        settingsTableVC?.currentRecordNumberLabel.isHidden = false
        settingsTableVC?.currentRecordNumberLabel.text = "\(nextSessionid)"
        startButton.isEnabled = false
        stopButton.isEnabled = true
        settingsTableVC?.tableView.allowsSelection = false
        settingsTableVC?.recordNumberLabel.text = "Record number:"
    }
    
    //  MARK: Filling data for testing data model
    func fillTestData(){
        
        let characteristicName1 = CharacteristicName (context:context)
        characteristicName1.name = "Gyro"
        let characteristicName2 = CharacteristicName (context:context)
        characteristicName2.name = "Acc"
        
        
        let characteristic1 = Characteristic (context:context)
        characteristic1.x = 0.1
        characteristic1.y = 0.1
        characteristic1.z = 0.1
        characteristic1.toCharacteristicName = characteristicName1
        let characteristic2 = Characteristic (context:context)
        characteristic2.x = 0.2
        characteristic2.y = 0.2
        characteristic2.z = 0.2
        characteristic2.toCharacteristicName = characteristicName1
        let characteristic3 = Characteristic (context:context)
        characteristic3.x = 0.3
        characteristic3.y = 0.3
        characteristic3.z = 0.3
        characteristic3.toCharacteristicName = characteristicName1
        let characteristic1a = Characteristic (context:context)
        characteristic1a.x = 0.1
        characteristic1a.y = 0.1
        characteristic1a.z = 0.1
        characteristic1a.toCharacteristicName = characteristicName2
        let characteristic2a = Characteristic (context:context)
        characteristic2a.x = 0.2
        characteristic2a.y = 0.2
        characteristic2a.z = 0.2
        characteristic2a.toCharacteristicName = characteristicName2
        let characteristic3a = Characteristic (context:context)
        characteristic3a.x = 0.3
        characteristic3a.y = 0.3
        characteristic3a.z = 0.3
        characteristic3a.toCharacteristicName = characteristicName2
        
        
        let sensorData1 = SensorData(context: context)
        sensorData1.timeStamp = NSDate()
        sensorData1.addToToCharacteristic(characteristic1)
        sensorData1.addToToCharacteristic(characteristic2)
        sensorData1.addToToCharacteristic(characteristic3)
        
        let sensorData2 = SensorData(context: context)
        sensorData2.timeStamp = NSDate()
        sensorData2.addToToCharacteristic(characteristic1a)
        sensorData2.addToToCharacteristic(characteristic2a)
        sensorData2.addToToCharacteristic(characteristic3a)
        
        
        let session1 = Session(context: context)
        session1.id = 1
        session1.duration = "00:10"
        session1.date = NSDate()
        session1.frequency = 100
        session1.addToToSensorData(sensorData1)
        session1.addToToSensorData(sensorData2)
        
        let session2 = Session(context: context)
        session2.id = 2
        session2.duration = "00:15"
        session2.date = NSDate()
        session2.frequency = 100
        session2.addToToSensorData(sensorData1)
        session2.addToToSensorData(sensorData2)
        
        
        ad.saveContext()
    }
    
    func findLastSessionId() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        fetchRequest.fetchLimit = 1
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let record = try context.fetch(fetchRequest) as! [Session]
            
            if record.count == 1 {
                let lastSession = record.first! as Session
                nextSessionid = Int(lastSession.id) + 1
                settingsTableVC?.currentRecordNumberLabel.text = "\(nextSessionid)"
            }
                
            else {
                nextSessionid = 0
                settingsTableVC?.currentRecordNumberLabel.text = "\(nextSessionid)"
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func addNamesOfCharacteristics(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CharacteristicName")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let records = try context.fetch(fetchRequest) as! [CharacteristicName]
            
            if records.count != 3 {
                let characteristicName1 = CharacteristicName (context:context)
                characteristicName1.name = "Gyro"
                let characteristicName2 = CharacteristicName (context:context)
                characteristicName2.name = "Acc"
                ad.saveContext()
            }
            
        } catch {
            print(error)
        }
        
        let fetchRequestForLocalCharacteristicName: NSFetchRequest<CharacteristicName> = CharacteristicName.fetchRequest()
        let sortDescriptorForLocalCharacteristicName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequestForLocalCharacteristicName.sortDescriptors = [sortDescriptorForLocalCharacteristicName]
        do {
            self.characteristicsNames = try context.fetch(fetchRequestForLocalCharacteristicName)
        }   catch   {
            print(error)
        }
        
    }
    
    func addSensorIDs(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sensor")
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let records = try context.fetch(fetchRequest) as! [Sensor]
            
            if records.count != 2 {
                let sensor1 = Sensor(context: context)
                sensor1.id = 1
                let sensor2 = Sensor(context: context)
                sensor2.id = 2
                
                ad.saveContext()
            }
            
        } catch {
            print(error)
        }
        
        let fetchRequestForLocalSensors: NSFetchRequest<Sensor> = Sensor.fetchRequest()
        let sortDescriptorForLocalSensors = NSSortDescriptor(key: "id", ascending: true)
        fetchRequestForLocalSensors.sortDescriptors = [sortDescriptorForLocalSensors]
        do {
            self.sensors = try context.fetch(fetchRequestForLocalSensors)
        }   catch   {
            print(error)
        }
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        
        if sessionType == SessionType.OnlyPhone { return }
        
        print ("File with data received on iPhone!")
        print ("SessionType: \(sessionType)")
        
        let fm = FileManager.default
        let destURL = getDocumentsDirectory().appendingPathComponent("saved_file")
        
        do {
            if fm.fileExists(atPath: destURL.path) {
                try fm.removeItem (at: destURL)
            }

            try fm.copyItem(at: file.fileURL, to: destURL)
            
            // load the file and print it out
            let mutableData = NSMutableData(contentsOf: destURL)
            
            let data = mutableData?.copy() as! Data
            
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            do {
                if let sessionContainerCopy = try unarchiver.decodeTopLevelDecodable(SessionContainer.self, forKey: NSKeyedArchiveRootObjectKey) {
                    
                    
                    DispatchQueue.main.async {
                        print("We are in main thread")
                        
                        let bcf = ByteCountFormatter()
                        bcf.allowedUnits = [.useMB]
                        bcf.countStyle = .file
                        let string = bcf.string(fromByteCount: Int64(data.count))
                        print ("File size: \(string)")
                        
                        print ("Start handling file...")
                        if (self.sessionType == SessionType.PhoneAndWatch) {
                            
                            for sensorOutput in sessionContainerCopy.sensorOutputs {
                                
                                let characteristicGyro = Characteristic (context:context)
                                characteristicGyro.x = sensorOutput.gyroX!
                                characteristicGyro.y = sensorOutput.gyroY!
                                characteristicGyro.z = sensorOutput.gyroZ!
                                characteristicGyro.toCharacteristicName = self.characteristicsNames[1]
                                
                                let characteristicAcc = Characteristic (context:context)
                                characteristicAcc.x = sensorOutput.accX!
                                characteristicAcc.y = sensorOutput.accY!
                                characteristicAcc.z = sensorOutput.accZ!
                                characteristicAcc.toCharacteristicName = self.characteristicsNames[0]
                                
                                let sensorData = SensorData(context: context)
                                sensorData.timeStamp = sensorOutput.timeStamp as NSDate?
                                sensorData.toSensor = self.sensors[1]
                                sensorData.addToToCharacteristic(characteristicGyro)
                                sensorData.addToToCharacteristic(characteristicAcc)
                                
                                self.currentSession?.addToToSensorData(sensorData)
                            }
                            
                            print("Now starting saving to Data Core")
                            ad.saveContext()
                            print("After String saving")
                            self.sessionType = SessionType.OnlyPhone
                            self.sensorOutputs.removeAll()
                            // self.sensorWatchOutputs.removeAll()
                            self.currentSession = nil
                        }
                    }
                }
            } catch {
                print("unarchiving failure: \(error)")
            }
            
            print ("Finished saving into Data Core")
            
            
            let WCsession = WCSession.default
            if WCsession.activationState == .activated {
                let data = ["isFinishedHandling": true]
                WCsession.transferUserInfo(data)
                
                print("Sent callback to Watch")
            }
            
        }
            
        catch {
            print ("File copy failed")
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            
            if let isAlsoRun = message["Running"] as? Bool {
                
                if (isAlsoRun) {
                    
                    if let recID = message["RecordID"] as? Int {
                        self.recordID = recID
                        self.settingsTableVC?.recordID.text = "\(recID)"
                    }
                    
                    self.currentFrequency = 50
                    self.settingsTableVC?.periodSlider.setValue(50.0, animated: true)
                    self.settingsTableVC?.currentPeriodLabel.text = "50"
                    
                    self.sessionType = SessionType.PhoneAndWatch
                    self.StartButtonpressed((Any).self)
                    
                    replyHandler(["response": "Starting collecting data..."])
                    
                } else {
                    self.stopButtonPressed((Any).self)
                    
                    replyHandler(["response": "Stopping collecting data..."])
                }
                
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.sync {
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    print ("Watch app is installed")
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
}
