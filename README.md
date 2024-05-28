# iOS Motion Collector

![Platform](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

iOS application for collecting data from Apple Watch's sensors (gyroscope, accelerometer). Each session could be marked by record label for example, to mark Bear Walk session as record id 1 = 'Bear' and Spider Climbing session as record id 2 = 'Spider'. The result could be exported as *.csv file that contains all the sessions.

The iOS application is used to primarily to compare sensor data output with Android Motion Collector (Galaxy Watch 4) and being a substitute application to collect children data instead of `SenseKid` application. The application is one of the 3 applications used to finish Computer BSc thesis at Eötvös Loránd University, Spring semester of 2023/2024 `Machine Learning Based Real-time Movement Detection of Children`.

## Features
- **Data Collection:** Capture real-time motion data from Apple Watch and iPhone sensors.
- **Session Labeling:** Tag sessions with custom record IDs to differentiate activities.
- **Data Export:** Export session data to CSV files for analysis and comparison.

## Acknowledgements
Special thanks to the contributors of the [MotionCollector GitHub repository](https://github.com/degtiarev/MotionCollector), which provided essential functionalities that supported the development of this application. This resource was instrumental in enabling the iOS Motion Collector to serve its role in a comparative study alongside the Galaxy Watch.

## Setup and Installation
To set up the iOS Motion Collector on your device, follow these steps:
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-repository/iOS-Motion-Collector.git
   ```
2. **Open the project in Xcode:**
   ```bash
   Launch Xcode and open the cloned project directory.
   ```
3. **Configure your Apple Watch and iPhone:**
   - Ensure that your Apple Watch is properly paired with your iPhone.
   - Build and Run:
     - Select your target device from the top device toolbar in Xcode.
     - Press the 'Run' button to compile the application and install it on your Apple Watch.

## Usage
- To start collecting data:
  1. Open the iOS Motion Collector app on your Apple Watch.
  2. Select the desired session type and start the session.

- To stop and save the session, navigate through the menu and tap 'End Session'.
- Access the collected data through the iOS app for export or review.

## Contributing
Contributions to the iOS Motion Collector are welcome. Please read through my contributing guidelines and submit pull requests to the development branch.

## License
This project is licensed under the MIT License - see the LICENSE.md file for details.


