import WatchKit
import Foundation
import CoreMotion
import HealthKit
import WatchConnectivity

// MARK: Main interface controller for the watch
class MainIC: WKInterfaceController, WCSessionDelegate {
    
    // MARK: Status of the watch application
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
    
    // MARK: The outlets of the UI
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var recIDLabel: WKInterfaceLabel!
    @IBOutlet var recNumberPicker: WKInterfacePicker!
    @IBOutlet var recordDataFromPhoneSwitch: WKInterfaceSwitch!
    
    // MARK: Constants
    let IDsAmount = 20
    let currentFrequency: Int = 50
    
    // MARK: Variables for session saving
    var nextSessionid: Int = 0
    var recordTime: String = ""
    var sensorOutputs = [SensorOutput]()
    var isRecordDataFromPhone = true
    var recordID: Int = 0
    var currentSessionDate: NSDate = NSDate()
    
    // MARK: For getting motion data
    let motion = CMMotionManager()
    let queue = OperationQueue()
    
    // MARK: For back-end HealthKit
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    
    
    // MARK: Events for WatchKit interface controller
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // MARK: prepare record number picker
        var items = [WKPickerItem]()
        for i in 0..<IDsAmount {
            let item = WKPickerItem()
            item.title = String (i)
            items.append(item)
        }
        recNumberPicker.setItems(items)
        
        // MARK: Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        status = .waiting
        
        
        // MARK: Configure WCSessionDelegate objects
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: Called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
    }
    
    // MARK: Called when watch view controller is no longer visible
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    
    // MARK: Gets motion data
    func startGettingData() {
        
        // MARK: Sends information to start data collection on phone
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
        
        // MARK: If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // MARK: Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        // MARK: Start the workout session and device motion updates.
        healthStore.start(session!)
        
        // MARK: Check motion availability
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
    
    // MARK: Stop getting motion data
    func stopGettingData(handler: @escaping(_ finishedGettingData: Bool) -> ()) {
        
        // MARK: If the workout is stopped, then do nothing.
        if (session == nil) {
            return
        }
        
        // MARK: Stop the device motion updates and workout session.
        motion.stopDeviceMotionUpdates()
        healthStore.end(session!)
        print("Ended health session")
        
        // MARK: Send information to start data collecting on phone
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
        
        // MARK: Clear the workout session.
        session = nil
        
        handler(true)
    }
    
    
    // MARK: Return the current time in hour:minutes:seconds:nanoseconds format
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
    
    
    
    // MARK: Action control for start button force push
    @IBAction func startButtonPressed() {
        if status == Status.recording { return }
        
        startGettingData()
        status = .recording
        
        currentSessionDate = NSDate()
    }
    
    // MARK: Action control for stop button force push
    @IBAction func stopButtonPressed() {
        if status == Status.waiting { return }
        
        timer.stop()
        
        stopGettingData { (finishedGettingData) in
            
            // MARK: Puts collected data into SessionContainer
            let sessionContainer = SessionContainer()
            sessionContainer.nextSessionid = self.nextSessionid
            sessionContainer.currentSessionDate = self.currentSessionDate as Date
            sessionContainer.currentFrequency = self.currentFrequency
            sessionContainer.recordID = self.recordID
            sessionContainer.duration = self.recordTime
            sessionContainer.sensorOutputs = self.sensorOutputs
            
            // MARK: Archives the session container
            let mutableData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: mutableData)
            try! archiver.encodeEncodable(sessionContainer, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
            
            
            // MARK: Saves data to file
            let sourceURL = self.getDocumentDirectory().appendingPathComponent("saveFile")
            mutableData.write(to: sourceURL, atomically: true)
            print ("Saved file")
            
            
            // MARK: Sends file to iPhone
            let session = WCSession.default
            if session.activationState == .activated {
                
                // MARK: Create a URL from where the file will be saved
                let fm = FileManager.default
                let sourceURL = self.getDocumentDirectory().appendingPathComponent("saveFile")
                
                if !fm.fileExists(atPath: sourceURL.path) {
                    // MARK: If the file doesn't exist - create it now
                    try? "Hello from Apple Watch!".write(to: sourceURL, atomically: true, encoding: String.Encoding.utf8)
                    
                }
                
                print ("Starting sending file")
                // MARK: the file exists now; send it across the session
                session.transferFile(sourceURL, metadata: nil)
                print ("File sent")
            }
            
            
            // MARK: Prepares the watch for the next session
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
    
    
    
    // MARK - Update changing state
    
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
    
    
    
    // MARK - Work with WCSessionDelegate
    
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
