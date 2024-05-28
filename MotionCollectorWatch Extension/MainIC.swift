import WatchKit
import Foundation
import CoreMotion
import HealthKit
import WatchConnectivity

class MainIC: WKInterfaceController, WCSessionDelegate {
    
    enum Status {
        case waiting
        case recording
    }
    
    var status: Status = Status.waiting {
        willSet(newStatus) {
            
            switch(newStatus) {
            case .waiting:
                waiting()
                break
                
            case .recording:
                recording()
                break
            }
        }
        didSet {
            
        }
    }
    
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var recIDLabel: WKInterfaceLabel!
    @IBOutlet var recNumberPicker: WKInterfacePicker!
    @IBOutlet var recordDataFromPhoneSwitch: WKInterfaceSwitch!
    
    let IDsAmount = 20
    let currentFrequency: Int = 50
    
    var nextSessionid: Int = 0
    var recordTime: String = ""
    var sensorOutputs = [SensorOutput]()
    var isRecordDataFromPhone = true
    var recordID: Int = 0
    var currentSessionDate: NSDate = NSDate()
    
    let motion = CMMotionManager()
    let queue = OperationQueue()
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var items = [WKPickerItem]()
        for i in 0..<IDsAmount {
            let item = WKPickerItem()
            item.title = String (i)
            items.append(item)
        }
        recNumberPicker.setItems(items)
        
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        status = .waiting
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func startGettingData() {
        if (isRecordDataFromPhone) {
            let WCsession = WCSession.default
            if WCsession.isReachable {
                let data = ["Running": true, "RecordID": recordID] as [String : Any]
                
                WCsession.sendMessage(data, replyHandler: { (response) in
                    DispatchQueue.main.async {
                        print ("received response: \(response)")
                    }
                }, errorHandler: nil)
            }
        }
        
        if (session != nil) {
            return
        }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(session!)
        
        if !motion.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        motion.deviceMotionUpdateInterval = 1.0 / Double(currentFrequency)
        motion.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                let GyroX = deviceMotion!.rotationRate.x
                let GyroY = deviceMotion!.rotationRate.y
                let GyroZ = deviceMotion!.rotationRate.z
                
                let AccX = deviceMotion!.gravity.x + deviceMotion!.userAcceleration.x
                let AccY = deviceMotion!.gravity.y + deviceMotion!.userAcceleration.y
                let AccZ = deviceMotion!.gravity.z + deviceMotion!.userAcceleration.z
                
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
    }
    
    func stopGettingData(handler: @escaping(_ finishedGettingData: Bool) -> ()) {
        if (session == nil) {
            return
        }
        
        motion.stopDeviceMotionUpdates()
        healthStore.end(session!)
        print("Ended health session")
        
        if (isRecordDataFromPhone) {
            let WCsession = WCSession.default
            if WCsession.isReachable {
                let data = ["Running": false]
                
                WCsession.sendMessage(data, replyHandler: { (response) in
                    DispatchQueue.main.async {
                        print ("received response: \(response)")
                    }
                }, errorHandler: nil)
            }
        }
        
        session = nil
        
        handler(true)
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
    
    @IBAction func startButtonPressed() {
        if status == Status.recording { return }
        
        startGettingData()
        status = .recording
        
        currentSessionDate = NSDate()
    }
    
    @IBAction func stopButtonPressed() {
        if status == Status.waiting { return }
        
        timer.stop()
        
        stopGettingData { (finishedGettingData) in
            let sessionContainer = SessionContainer()
            sessionContainer.nextSessionid = self.nextSessionid
            sessionContainer.currentSessionDate = self.currentSessionDate as Date
            sessionContainer.currentFrequency = self.currentFrequency
            sessionContainer.recordID = self.recordID
            sessionContainer.duration = self.recordTime
            sessionContainer.sensorOutputs = self.sensorOutputs
            
            let mutableData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: mutableData)
            try! archiver.encodeEncodable(sessionContainer, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
            
            let sourceURL = self.getDocumentDirectory().appendingPathComponent("saveFile")
            mutableData.write(to: sourceURL, atomically: true)
            print ("Saved file")
            
            let session = WCSession.default
            if session.activationState == .activated {
                let fm = FileManager.default
                let sourceURL = self.getDocumentDirectory().appendingPathComponent("saveFile")
                
                if !fm.fileExists(atPath: sourceURL.path) {
                    try? "Hello from Apple Watch!".write(to: sourceURL, atomically: true, encoding: String.Encoding.utf8)
                    
                }
                
                print ("Starting sending file")
                session.transferFile(sourceURL, metadata: nil)
                print ("File sent")
            }
            
            self.sensorOutputs.removeAll()
            self.nextSessionid += 1
            
            
        }
        
        
    }
    
    func getDocumentDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func recordDataFromPhoneSwitchChanged(_ value: Bool) {
        isRecordDataFromPhone = value
    }
    
    @IBAction func recNumberPickerChanged(_ value: Int) {
        recordID = value
    }
    
    func waiting() {
        recNumberPicker.setEnabled(true)
        timer.setDate(Date(timeIntervalSinceNow: 0.0))
        recordDataFromPhoneSwitch.setEnabled(true)
    }
    
    func recording() {
        recNumberPicker.setEnabled(false)
        timer.setDate(Date(timeIntervalSinceNow: 0.0))
        timer.start()
        recordDataFromPhoneSwitch.setEnabled(false)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            
            if let isFinishedHanflingFile = userInfo["isFinishedHandling"] as? Bool {
                if isFinishedHanflingFile {
                    print("Finished handling file")
                    self.status = .waiting
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}
