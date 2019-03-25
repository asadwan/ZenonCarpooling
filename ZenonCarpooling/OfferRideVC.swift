//
//  OfferRideVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 11/2/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Material
import Localize_Swift
import RLBAlertsPickers
import SVProgressHUD

class OfferRideVC: UITableViewController {
    
    
    @IBOutlet weak var originLocationLabel: UILabel!
    @IBOutlet weak var originLocationLabelHeaderLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationHeaderLabel: UILabel!
    @IBOutlet weak var roundTripSwitch: Switch!
    @IBOutlet weak var roundTripLabel: UILabel!
    @IBOutlet weak var outboundTripDateAndTime: UILabel!
    @IBOutlet weak var outboundTripDateAndTimeHeaderLabel: UILabel!
    @IBOutlet weak var inboundTripDateAndTime: UILabel!
    @IBOutlet weak var inboundTripDateAndTimeHeaderLabel: UILabel!
    @IBOutlet weak var outboundOfferedSeatsTextField: UITextField!
    @IBOutlet weak var outboundOfferedSeatsLabel: UILabel!
    @IBOutlet weak var outboudSeatsLabel: UILabel!
    @IBOutlet weak var inboundOfferedSeatsTextField: UITextField!
    @IBOutlet weak var inboundOfferedSeatsLabel: UILabel!
    @IBOutlet weak var inboundSeatsLabel: UILabel!
    @IBOutlet weak var pricePerSeatTextField: UITextField!
    @IBOutlet weak var pricePerSeatLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var pricePerSeatStackView: UIStackView!
    @IBOutlet weak var outboundOfferedSeatsStackView: UIStackView!
    @IBOutlet weak var inboundOfferdSeatsStackView: UIStackView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var submitRideButton: RaisedButton!
    
    
    var hapticNotification = UINotificationFeedbackGenerator()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var isRoundTrip = false
    var originLocationSelected = false
    var destinationLocationSelected = false
    var outboundTripDateAndTimeSelected = false
    var inboundTripDateAndTimeSelected = false;
    var warningIsOn = false;
    
    var outboundRide: Ride = Ride()
    var inboundRide: Ride = Ride()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSwitch()
        setLoclizedTextForLabels()
        destinationLocationLabel.isHidden = true
        originLocationLabel.isHidden = true
        outboundOfferedSeatsStackView.isHidden = true
        
        if(Localize.currentLanguage() == "ar") {
            view.semanticContentAttribute = .forceRightToLeft
            tableView.semanticContentAttribute = .forceRightToLeft
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        snackbarController?.tabBarController?.navigationItem.title = "Offer a Ride".localized()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 8
        default:
            return 1;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 4 || indexPath.row == 6) {
            if !isRoundTrip {
                return 0.0
            }
        } else if ((indexPath.section == 0) && !warningIsOn) {
            return 0
        }
        return 66.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) {
            return "Ride Details".localized()
        }
        return ""
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        switch indexPath {
        case IndexPath(row: 0, section: 1):
            originLocationSelected = true
            presentLocationPicker()
        case IndexPath(row: 1, section: 1):
            destinationLocationSelected = true
            presentLocationPicker()
        case IndexPath(row: 3, section: 1):
            outboundTripDateAndTimeSelected = true
            outboundTripDateAndTime.isHidden = false
            presentDatePicker()
        case IndexPath(row: 4, section: 1):
            inboundTripDateAndTimeSelected = true
            inboundTripDateAndTime.isHidden = false
            presentDatePicker()
        case IndexPath(row: 5, section: 1):
            outboundOfferedSeatsStackView.isHidden = false
            outboundOfferedSeatsTextField.becomeFirstResponder()
        case IndexPath(row: 6, section: 1):
            inboundOfferdSeatsStackView.isHidden = false
            inboundOfferedSeatsTextField.becomeFirstResponder()
        case IndexPath(row: 7, section: 1):
            pricePerSeatStackView.isHidden = false
            pricePerSeatTextField.becomeFirstResponder()
            
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Private methods
    
    private func setUpSwitch() {
        roundTripSwitch.switchStyle = .light
        roundTripSwitch.switchSize = .large
        roundTripSwitch.delegate = self
        roundTripSwitch.isOn = false
    }
    
    private func setLoclizedTextForLabels() {
        originLocationLabelHeaderLabel.text = "Origin Location".localized()
        destinationLocationHeaderLabel.text = "Destination Location".localized()
        roundTripLabel.text = "Round Trip".localized()
        outboundTripDateAndTimeHeaderLabel.text = "Trip Date and Time".localized()
        inboundTripDateAndTimeHeaderLabel.text = "Inbound Trip Date and Time".localized()
        outboundOfferedSeatsLabel.text = "Trip Offered Seats".localized()
        inboundOfferedSeatsLabel.text = "Inbound Trip Offered Seats".localized()
        pricePerSeatLabel.text = "Price per Seat".localized()
        outboudSeatsLabel.text = "Seats".localized()
        inboundSeatsLabel.text = "Seats".localized()
        currencyLabel.text = "JOD".localized()
        submitRideButton.titleLabel?.text = "SUBMIT".localized()
    }
    
    private func presentLocationPicker() {
        let navController = UINavigationController()
        let locationPickerVC = PickLocationVC()
        locationPickerVC.delegate = self
        navController.viewControllers = [locationPickerVC]
        self.present(navController, animated: true
            ,completion: nil)
    }
    
    private func presentDatePicker() {
        let alert = UIAlertController(style: .actionSheet, title: "Select date and time".localized())
        alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: Date(timeIntervalSinceNow: 900), maximumDate: Date().addingTimeInterval(60 * 60 * 24 * 365)) { date in
            if(self.inboundTripDateAndTimeSelected) {
                self.inboundTripDateAndTime.text = date.getLocalizedDateTimeString()
                self.inboundRide.dateAndTime = date
                self.inboundTripDateAndTimeSelected = false
            } else {
                self.outboundTripDateAndTime.text = date.getLocalizedDateTimeString()
                self.outboundRide.dateAndTime = date
                self.outboundTripDateAndTimeSelected = false
            }
        }
        alert.addAction(title: "Pick".localized(), style: .default)
        alert.show()
    }
    
    private func isInputValid() -> Bool {
        if outboundRide.goingToCity == nil || outboundRide.leavingFromCity == nil {
            warningLabel.text =  "Please select source and destination locations."
            return false
        } else if outboundRide.dateAndTime == nil {
            warningLabel.text = "Please provide date and time for the ride."
            return false
        } else if isRoundTrip && inboundRide.dateAndTime == nil {
            warningLabel.text = "Please provide date and time for the return ride."
            return false
        } else if outboundRide.offeredSeats == nil {
            warningLabel.text = "Please specify the number of offered seats for the ride."
            return false
        } else if isRoundTrip && inboundRide.offeredSeats == nil {
            warningLabel.text = "Please specify the number of offered seats for the return ride."
            return false
        } else if outboundRide.pricePerSeat == nil {
            warningLabel.text = "Please specify a price per seat for the ride."
            return false
        }
        return true
    }
    
    private func setUpInboundRide() {
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
    }

    private func presentSnackbar() {
        guard let snackbarController = snackbarController else {
            return
        }
        snackbarController.snackbar.text = "Ride has been submitted"
        snackbarController.snackbar.backgroundColor = #colorLiteral(red: 0.1220000014, green: 0.7289999723, blue: 0.8389999866, alpha: 1)
        snackbarController.animate(snackbar: .visible, delay: 1)
        snackbarController.animate(snackbar: .hidden, delay: 5)
    }
    
    // - MARK: Actions & Handlers
    
    @IBAction func submitRide(_ sender: Any) {
        presentSnackbar()
        outboundRide.offeredSeats = Int(outboundOfferedSeatsTextField.text!) ?? nil
        inboundRide.offeredSeats = Int(inboundOfferedSeatsTextField.text!) ?? nil
        outboundRide.pricePerSeat = Float(pricePerSeatTextField.text!) ?? nil
        if isInputValid() {
            FirebaseManager.addNewRide(ride: outboundRide)
            if(isRoundTrip) {
                setUpInboundRide()
                FirebaseManager.addNewRide(ride: inboundRide)
            }
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                SVProgressHUD.dismiss()
                self.presentSnackbar()
            }
        } else {
            warningIsOn = true
            tableView.beginUpdates()
            tableView.endUpdates()
            hapticNotification.notificationOccurred(.error)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.warningIsOn = false
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}

extension OfferRideVC: SwitchDelegate {
    func switchDidChangeState(control: Switch, state: SwitchState) {
        isRoundTrip = control.isOn
        if(isRoundTrip) {
            outboundTripDateAndTimeHeaderLabel.text = "Outbound Trip Date and Time".localized()
            outboundOfferedSeatsLabel.text = "Outbound Trip Offered Seats".localized()
        } else {
            outboundTripDateAndTimeHeaderLabel.text = "Trip Date and Time".localized()
            outboundOfferedSeatsLabel.text = "Trip Offered Seats".localized()
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension OfferRideVC: PickLocationVCDelegate {
    func didFinishPickingLocation(location: Location) {
        if(originLocationSelected) {
            outboundRide.leavingFromCity = location.cityFirDBKey
            outboundRide.leavingFromNeighborhood = location.neighborhoodFirDBKey
            outboundRide.fromLatitude = location.coordinates.latitude.magnitude
            outboundRide.fromLongitude = location.coordinates.longitude.magnitude
            originLocationSelected = false
            originLocationLabel.text = "\(location.neighborhood) - \(location.city)".uppercased()
            originLocationLabel.isHidden = false
        } else if (destinationLocationSelected) {
            outboundRide.goingToCity = location.cityFirDBKey
            outboundRide.goingToNeighborhood = location.neighborhoodFirDBKey
            outboundRide.toLatitude = location.coordinates.latitude.magnitude
            outboundRide.toLongitude = location.coordinates.longitude.magnitude
            destinationLocationSelected = false
            destinationLocationLabel.text = "\(location.neighborhood) - \(location.city)".uppercased()
            destinationLocationLabel.isHidden = false
        }
    }
}


extension OfferRideVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

