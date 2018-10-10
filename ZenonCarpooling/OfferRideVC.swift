//
//  OfferRideVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 6/5/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import DateTimePicker
import Firebase
import GoogleMaps
import GooglePlacePicker

class OfferRideVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DateTimePickerDelegate, GMSPlacePickerViewControllerDelegate {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var hapticNotification = UINotificationFeedbackGenerator()
    
    @IBOutlet weak var pickersContainerBottonSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var inboundTripDateAndTimeStackView: UIStackView!
    @IBOutlet weak var inboundTripAvailableSeatsStackView: UIStackView!
    @IBOutlet weak var inboundTripDateTimeLabel: UILabel!
    @IBOutlet weak var outboundTripDateTimeLabel: UILabel!
    @IBOutlet weak var leavingFromLabel: UILabel!
    @IBOutlet weak var goingToLabel: UILabel!
    @IBOutlet var cityPickerView: UIPickerView!
    @IBOutlet var neighborhoodPickerView: UIPickerView!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var maxWaitingTimeLabel: UITextField!
    @IBOutlet weak var pricePerSeatLabel: UITextField!
    @IBOutlet weak var inboundRideNumOfOfferdSeats: UITextField!
    @IBOutlet weak var outboundRideNumOfOfferdSeats: UITextField!
    
    var listOfCites = [String]()
    var listOfNeighborhoods = [String]()
    var listOfLocations = Dictionary<String,[String]>()
    
    var goingToLabelSelected = false
    var leavingFromLabelSelected = false
    var inboundTripDateTimeLabelSelected = false
    var outboundTripDateTimeLabelSelected = false
    
    var leavingFromCity: String?
    var leavingFromNeighborhood: String?
    var goingToCity: String?
    var goingToNeighborhood: String?
    var outboundRideDateAndTime: Date?
    var inboundRideDateAndTime: Date?
    var isRoundTrip = false
    var outboundRideOfferedSeats: Int?
    var inboundRideOfferedSeats: Int?
    var pricePerSeat: Float?
    var maxWaitTime: Int?
    var posterId: String?
    var ridersIds: [String]?
    var rideId: String!
    
    
    var dateTimePicker: DateTimePicker?
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // warning label is initially hidden
        warningLabel.isHidden = true
        
        //Keyboard show/hide events obervers
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        inboundTripAvailableSeatsStackView.isHidden = true
        inboundTripDateAndTimeStackView.isHidden = true
        
        populateCityNeighborhoodList()
        
        leavingFromLabel.isUserInteractionEnabled = true
        goingToLabel.isUserInteractionEnabled = true
        inboundTripDateTimeLabel.isUserInteractionEnabled = true
        outboundTripDateTimeLabel.isUserInteractionEnabled = true
        leavingFromLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLocationPickersForLeavingFromLocation)))
        goingToLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLocationPickersForGoingToLocation)))
        inboundTripDateTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentDateTimePickerForInboundTripDateTime)))
        outboundTripDateTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentDateTimePickerForOutboundTripDateTime)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Offer a Ride"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.selectedViewController = self
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPickerView {
            return  listOfCites.count
        } else {
            return listOfNeighborhoods.count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPickerView {
            return listOfCites[row]
        } else {
            return listOfNeighborhoods[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cityPickerView {
            setNeighborhoodList(city: listOfCites[row])
            neighborhoodPickerView.selectRow(0, inComponent: 0, animated: true)
            self.neighborhoodPickerView.reloadAllComponents()
        }
    }
    
    // MARK: - GMSPlacePickerViewControllerDelegate
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Private Methods
    
    private func populateCityNeighborhoodList() {
        let ammanNeighborhoods = ["University of Jordan", "Jabal Amman", "Abdoun", "Shmeisani", "Khlida", "Tabarbour"]
        let zarqaNeighborhoods = ["Jabal Tariq", "Awajan", "Al betrawi", "Al Wasat Al Tijari", "Jannaa'ah"]
        
        listOfLocations["Amman"] = ammanNeighborhoods
        listOfLocations["Zarqa"] = zarqaNeighborhoods
        
        listOfCites = Array(listOfLocations.keys)
        listOfNeighborhoods = ammanNeighborhoods
    }
    
    private func setNeighborhoodList(city: String) {
        listOfNeighborhoods = listOfLocations[city] ?? [String]()
    }
    
    // MARK: - Actions and Handlers
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func presentLocationPickersForGoingToLocation() {
        pickersContainerBottonSpacingConstraint.constant = 0
        goingToLabelSelected = true
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func presentLocationPickersForLeavingFromLocation() {
        pickersContainerBottonSpacingConstraint.constant = 0
        leavingFromLabelSelected = true
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func presentDateTimePickerForInboundTripDateTime() {
        inboundTripDateTimeLabelSelected = true
        presentDateTimePicker(for: "inbound")
    }
    
    @objc func presentDateTimePickerForOutboundTripDateTime() {
        outboundTripDateTimeLabelSelected = true
        presentDateTimePicker(for: "Outbound")
    }
    
    @IBAction func handleDoneWithPickingLocation(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
        
        pickersContainerBottonSpacingConstraint.constant = 300
        let selectedCityRow = cityPickerView.selectedRow(inComponent: 0)
        let selectedNeighbothoodRow = neighborhoodPickerView.selectedRow(inComponent: 0)
        let city = listOfCites[selectedCityRow]
        let neighborhood = listOfNeighborhoods[selectedNeighbothoodRow]
        if(leavingFromLabelSelected) {
            leavingFromCity = city
            leavingFromNeighborhood = neighborhood
            leavingFromLabel.text =  "From:  \(neighborhood) - \(city)"
            leavingFromLabelSelected = false
        } else if (goingToLabelSelected) {
            goingToCity = city
            goingToNeighborhood = neighborhood
            goingToLabel.text =  "To:  \(neighborhood) - \(city)"
            goingToLabelSelected = false
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func HandleIsRoundTripSwitchValueChange(_ sender: Any) {
        if let switch_ = sender as? UISwitch {
            if switch_.isOn {
                isRoundTrip = true
                inboundTripDateAndTimeStackView.isHidden = false
                inboundTripAvailableSeatsStackView.isHidden = false
            } else {
                isRoundTrip = false
                inboundTripDateAndTimeStackView.isHidden = true
                inboundTripAvailableSeatsStackView.isHidden = true
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func CancelLocationPicking(_ sender: Any) {
        pickersContainerBottonSpacingConstraint.constant = 300
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func submitRideToDatabase(_ sender: Any) {
        warningLabel.isHidden = true
        inboundRideOfferedSeats = Int(inboundRideNumOfOfferdSeats.text!) ?? nil
        outboundRideOfferedSeats = Int(outboundRideNumOfOfferdSeats.text!) ?? nil
        pricePerSeat = Float(pricePerSeatLabel.text!) ?? nil
        maxWaitTime = Int(maxWaitingTimeLabel.text!) ?? nil
        var warningMessage = ""
        if goingToCity == nil || leavingFromCity == nil {
            warningMessage =  "Please select source and destination locations."
            presentWarning(warningMessage)
            return
        } else if outboundRideDateAndTime == nil {
            warningMessage = "Please provide date and time for the ride."
            presentWarning(warningMessage)
            return
        } else if isRoundTrip && inboundRideDateAndTime == nil {
            warningMessage = "Please provide date and time for the return ride."
            presentWarning(warningMessage)
            return
        } else if outboundRideOfferedSeats == nil {
            warningMessage = "Please specify the number of offered seats for the ride."
            presentWarning(warningMessage)
            return
        } else if isRoundTrip && inboundRideOfferedSeats == nil {
            warningMessage = "Please specify the number of offered seats for the return ride."
            presentWarning(warningMessage)
            return
        } else if pricePerSeat == nil {
            warningMessage = "Please specify a price per seat for the ride."
            presentWarning(warningMessage)
            return
        } else if maxWaitTime == nil {
            warningMessage = "Please specify a maximum wait time for the riders of the ride."
            presentWarning(warningMessage)
            return
        }
        submitRideToDatabase()
    }
    
    // MARK: - Private Methods
    
    private func submitRideToDatabase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.presentWarning("Somthing went wrong, please try again.")
            return
        }
    
        posterId = uid
        rideId = NSUUID().uuidString
        let isRoundTrip = self.isRoundTrip ? "Yes": "No"
        
        let dbRef = Database.database().reference(fromURL: "https://zenoncarpooling.firebaseio.com/")
        let ridesListRef = dbRef.child("rides")
        let currentUserRef = dbRef.child("users").child(posterId!)
        let rideRef = ridesListRef.child(rideId)
        
        var rideInfo = [String:Any]()
        if (self.isRoundTrip) {
            rideInfo = ["posterId":posterId!, "leavingFromCity": leavingFromCity!, "leavingFromNeighborhood": leavingFromNeighborhood!, "goingToCity": goingToCity!, "goingToNeighborhood": goingToNeighborhood!, "isRoundTrip": isRoundTrip, "outboundRideWeekday": outboundRideDateAndTime!.dayOfWeek()!, "inboundRideWeekday": inboundRideDateAndTime!.dayOfWeek()!, "outboundRideDate": outboundRideDateAndTime!.getDateString()! ,"inboundRideDate": inboundRideDateAndTime!.getDateString()!, "outboundRideTime": outboundRideDateAndTime!.getTimeString()! , "inboundRideTime": inboundRideDateAndTime!.getTimeString()! , "outboundRideNumberOfOfferedSeats": outboundRideOfferedSeats!, "inboundRideNumberOfOfferedSeats": inboundRideOfferedSeats!, "pricePerSeat": pricePerSeat!, "maxWaitingTime": maxWaitTime!, "outboundRideAvailableSeats": outboundRideOfferedSeats!, "inboundRideAvailableSeats": inboundRideOfferedSeats!]
        } else {
            rideInfo = ["posterId":posterId!, "leavingFromCity": leavingFromCity!, "leavingFromNeighborhood": leavingFromNeighborhood!, "goingToCity": goingToCity!, "goingToNeighborhood": goingToNeighborhood!, "isRoundTrip": isRoundTrip, "outboundRideWeekday": outboundRideDateAndTime!.dayOfWeek()!, "outboundRideDate": outboundRideDateAndTime!.getDateString()!, "outboundRideTime": outboundRideDateAndTime!.getTimeString()! , "outboundRideNumberOfOfferedSeats": outboundRideOfferedSeats!, "pricePerSeat": pricePerSeat!, "maxWaitingTime": maxWaitTime!, "outboundRideAvailableSeats": outboundRideOfferedSeats!]
        }
        
        rideRef.updateChildValues(rideInfo)
        currentUserRef.child("offeredRides").childByAutoId().updateChildValues(["rideId": rideId])
        
    }
    
    fileprivate func presentWarning(_ warningMessage: String) {
        warningLabel.text = warningMessage
        warningLabel.isHidden = false
        hapticNotification.notificationOccurred(.error)
    }
    
    fileprivate func presentDateTimePicker(for trip: String) {
        let min = Date().addingTimeInterval(-1)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 365)
        
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker.show()
        picker.timeInterval = DateTimePicker.MinuteInterval.five
        if #available(iOS 11.0, *) {
            picker.highlightColor = UIColor(named: "uberBlue")!
            picker.darkColor = UIColor(named: "uberBlack")!
            picker.doneBackgroundColor = UIColor(named: "uberBlack")!
        } else {
            // Fallback on earlier versions
        }
        picker.doneBackgroundColor = .black
        picker.todayButtonTitle = "Today"
        picker.is12HourFormat = true
        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
        picker.includeMonth = true
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            if(self.outboundTripDateTimeLabelSelected) {
                self.outboundRideDateAndTime = date
                self.outboundTripDateTimeLabel.text = formatter.string(from: date)
                self.outboundTripDateTimeLabelSelected = false
            } else if (self.inboundTripDateTimeLabelSelected) {
                self.inboundRideDateAndTime = date
                self.inboundTripDateTimeLabelSelected = false
                self.inboundTripDateTimeLabel.text  = formatter.string(from: date)
            }
        }
        picker.delegate = self
        self.dateTimePicker = picker
    }
    
    // MARK: - DateTimePickerDelegate
    
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
        if outboundTripDateTimeLabelSelected {
            outboundTripDateTimeLabel.text = picker.selectedDateString
        } else if inboundTripDateTimeLabelSelected {
            inboundTripDateTimeLabel.text = picker.selectedDateString
        }
    }
}
