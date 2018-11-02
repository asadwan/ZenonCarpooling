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
import SVProgressHUD

class OfferRideVC: UIViewController, DateTimePickerDelegate, PickLocationVCDelegate {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var hapticNotification = UINotificationFeedbackGenerator()
    
    @IBOutlet weak var inboundTripDateAndTimeStackView: UIStackView!
    @IBOutlet weak var inboundTripAvailableSeatsStackView: UIStackView!
    @IBOutlet weak var inboundTripDateTimeLabel: UILabel!
    @IBOutlet weak var outboundTripDateTimeLabel: UILabel!
    @IBOutlet weak var leavingFromLabel: UILabel!
    @IBOutlet weak var goingToLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var maxWaitingTimeLabel: UITextField!
    @IBOutlet weak var pricePerSeatLabel: UITextField!
    @IBOutlet weak var inboundRideNumOfOfferdSeats: UITextField!
    @IBOutlet weak var outboundRideNumOfOfferdSeats: UITextField!
    
    
    var goingToLabelSelected = false
    var leavingFromLabelSelected = false
    var inboundTripDateTimeLabelSelected = false
    var outboundTripDateTimeLabelSelected = false
    
    var outboundRide: Ride = Ride()
    var inboundRide: Ride = Ride()
    var isRoundTrip: Bool = false
    
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
        
        leavingFromLabel.isUserInteractionEnabled = true
        goingToLabel.isUserInteractionEnabled = true
        inboundTripDateTimeLabel.isUserInteractionEnabled = true
        outboundTripDateTimeLabel.isUserInteractionEnabled = true
        leavingFromLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLocationPickerForLeavingFromLocation)))
        goingToLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLocationPickerForGoingToLocation)))
        inboundTripDateTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentDateTimePickerForInboundTripDateTime)))
        outboundTripDateTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentDateTimePickerForOutboundTripDateTime)))
        
        
        leavingFromLabel.text = "Leaving From".localized()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Offer a Ride".localized()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.selectedViewController = self
    }
    
    // MARK: - Private Methods
    
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
    
    @objc func presentLocationPickerForGoingToLocation() {
        let navController = UINavigationController()
        let locationPickerVC = PickLocationVC()
        locationPickerVC.delegate = self
        navController.viewControllers = [locationPickerVC]
        self.present(navController, animated: true
            , completion: nil)
        goingToLabelSelected = true
    }
    
    @objc func presentLocationPickerForLeavingFromLocation() {
        let navController = UINavigationController()
        let locationPickerVC = PickLocationVC()
        locationPickerVC.delegate = self
        navController.viewControllers = [locationPickerVC]
        self.present(navController, animated: true
            , completion: nil)
        leavingFromLabelSelected = true
    }
    
    @objc func presentDateTimePickerForInboundTripDateTime() {
        inboundTripDateTimeLabelSelected = true
        presentDateTimePicker(for: "inbound")
    }
    
    @objc func presentDateTimePickerForOutboundTripDateTime() {
        outboundTripDateTimeLabelSelected = true
        presentDateTimePicker(for: "Outbound")
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
    
    @IBAction func submitRideToDatabase(_ sender: Any) {
        inboundRide.offeredSeats = Int(inboundRideNumOfOfferdSeats.text!) ?? nil
        outboundRide.offeredSeats = Int(outboundRideNumOfOfferdSeats.text!) ?? nil
        outboundRide.pricePerSeat = Float(pricePerSeatLabel.text!) ?? nil
        outboundRide.maxWaitingTime = Int(maxWaitingTimeLabel.text!) ?? nil
        outboundRide.availableSeats = outboundRide.offeredSeats
        
        if isInputValid() {
            FirebaseManager.addNewRide(ride: outboundRide)
            if(isRoundTrip) {
                inboundRide.leavingFromCity = outboundRide.goingToCity
                inboundRide.leavingFromNeighborhood = outboundRide.goingToNeighborhood
                inboundRide.goingToCity = outboundRide.leavingFromCity
                inboundRide.goingToNeighborhood = outboundRide.leavingFromNeighborhood
                inboundRide.pricePerSeat = outboundRide.pricePerSeat
                inboundRide.maxWaitingTime = outboundRide.maxWaitingTime
                inboundRide.availableSeats = inboundRide.offeredSeats
                inboundRide.toLatitude = outboundRide.fromLatitude
                inboundRide.toLongitude = outboundRide.fromLongitude
                inboundRide.fromLatitude = outboundRide.toLatitude
                inboundRide.fromLongitude = outboundRide.toLongitude
                FirebaseManager.addNewRide(ride: inboundRide)
            }
            SVProgressHUD.showSuccess(withStatus: "   Done   ")
        }
    }
    
    // MARK: - Private Methods
    
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
                self.outboundRide.dateAndTime = date
                self.outboundTripDateTimeLabel.text = formatter.string(from: date)
                self.outboundTripDateTimeLabelSelected = false
            } else if (self.inboundTripDateTimeLabelSelected) {
                self.inboundRide.dateAndTime = date
                self.inboundTripDateTimeLabelSelected = false
                self.inboundTripDateTimeLabel.text  = formatter.string(from: date)
            }
        }
        picker.delegate = self
        self.dateTimePicker = picker
    }
    
    private func isInputValid() -> Bool {
        warningLabel.isHidden = true
        var warningMessage = ""
        if outboundRide.goingToCity == nil || outboundRide.leavingFromCity == nil {
            warningMessage =  "Please select source and destination locations."
            presentWarning(warningMessage)
            return false
        } else if outboundRide.dateAndTime == nil {
            warningMessage = "Please provide date and time for the ride."
            presentWarning(warningMessage)
            return false
        } else if isRoundTrip && inboundRide.dateAndTime == nil {
            warningMessage = "Please provide date and time for the return ride."
            presentWarning(warningMessage)
            return false
        } else if outboundRide.offeredSeats == nil {
            warningMessage = "Please specify the number of offered seats for the ride."
            presentWarning(warningMessage)
            return false
        } else if isRoundTrip && inboundRide.offeredSeats == nil {
            warningMessage = "Please specify the number of offered seats for the return ride."
            presentWarning(warningMessage)
            return false
        } else if outboundRide.pricePerSeat == nil {
            warningMessage = "Please specify a price per seat for the ride."
            presentWarning(warningMessage)
            return false
        } else if outboundRide.maxWaitingTime == nil {
            warningMessage = "Please specify a maximum wait time for the riders of the ride."
            presentWarning(warningMessage)
            return false
        }
        return true
    }
    
    // MARK: - DateTimePickerDelegate
    
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
        if outboundTripDateTimeLabelSelected {
            outboundTripDateTimeLabel.text = picker.selectedDateString
        } else if inboundTripDateTimeLabelSelected {
            inboundTripDateTimeLabel.text = picker.selectedDateString
        }
    }
    
    // MARK: - PickLocationVCDeleagte
    
    func didFinishPickingLocation(location: Location) {
        if(leavingFromLabelSelected) {
            outboundRide.leavingFromCity = location.cityFirDBKey
            outboundRide.leavingFromNeighborhood = location.neighborhoodFirDBKey
            outboundRide.fromLatitude = location.coordinates.latitude.magnitude
            outboundRide.fromLongitude = location.coordinates.longitude.magnitude
            leavingFromLabel.text =  "From:  \(location.neighborhood) - \(location.city)"
            leavingFromLabelSelected = false
        } else if (goingToLabelSelected) {
            outboundRide.goingToCity = location.cityFirDBKey
            outboundRide.goingToNeighborhood = location.neighborhoodFirDBKey
            outboundRide.toLatitude = location.coordinates.latitude.magnitude
            outboundRide.toLongitude = location.coordinates.longitude.magnitude
            goingToLabel.text =  "To:  \(location.neighborhood) - \(location.city)"
            goingToLabelSelected = false
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}
