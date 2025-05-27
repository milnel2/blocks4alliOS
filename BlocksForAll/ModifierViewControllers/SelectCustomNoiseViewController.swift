//
//  SelectCustomNoiseViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 11/10/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import AVFAudio
import AVFoundation

// Code for creating a UICollectionView programmatically is from: https://medium.com/@buttam1703/how-to-create-a-uicollectionview-programmatically-in-swift-a030da15d445
// Code for recording audio is from https://vikaskore.medium.com/record-audio-in-ios-swift-4-2-a6a4d53e31b0#:~:text=In%20your%20.,to%20play%20recorded%20audio%20respectively.

class SelectCustomNoiseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var NoisesCollectionView: UICollectionView! // Holds row of custom noise options
    @IBOutlet weak var SelectedNoiseImageView: UIImageView! // Large imsge that displays which audio slot is currently selected
    @IBOutlet weak var DeleteNoiseButton: UIButton! // Delete buttom that is displayed in the corner of the SelectedNoiseImageView
    @IBOutlet weak var PlayNoiseButton: UIButton! // Green play button to play currently selected noise
    @IBOutlet weak var RecordNoiseButton: UIButton! // Red circle button to record in currently selected slot
    @IBOutlet weak var RecordingProgressViewHolder: UIView! // View used to show how much time is left to record
    @IBOutlet weak var RecordingProgressBar: UIView! // View within the progress view that is the actual bar which moves to show progress
    @IBOutlet weak var RecordingProgressBarWidth: NSLayoutConstraint! // The width constraint of the RecordingProgressBar
    @IBOutlet weak var BackButton: UIButton! // Arrow button to return to workspace
    @IBOutlet weak var SelectCustomNoiseTitleLabel: UILabel! // Select Custom Noise label at top of screen
    
    // Audio variables
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    private let MAX_AUDIO_LENGTH = 5
    
    private var selectedNoiseSlotNum: Int = 1 // noise num that is currently selected
  
    // Project Info
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen
    
    var currentProject: Project! { // Project that is currently being edited
        get {
            return UserData.data.getCurrentProject()
        }
    }
    private let buttonSize = (((defaults.value(forKey: "blockSize") as! Int) * 10) / 9) // the size of each button that is showed in the collection view // TODO: handle different block sizes
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up NoisesCollectionView
        NoisesCollectionView.delegate = self
        NoisesCollectionView.dataSource = self
        NoisesCollectionView.register(CustomAudioSlotCell.self, forCellWithReuseIdentifier: "customAudioSlotCell")
        
        preserveLastSelection()
        
        DeleteNoiseButton.addTarget(self, action: #selector(deleteNoiseTapped), for: .touchUpInside)
        
        // Set up audio recording
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            // Get permission to record
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("no permission to record")
                    }
                }
            }
        } catch {
            print("failed to record")
        }
        
        // Code to listen for when a VoiceOver announcement finishes is from: https://vikramios.medium.com/swift-notification-observers-bbc5b86a7781
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverAnnouncementFinished), name: UIAccessibility.announcementDidFinishNotification, object: nil) // Listen for when VoiceOver announcements finish

        updateAccessibility()
    }
    
    /// Set up recording elements
    func loadRecordingUI() {
        // Stop voice over from talking when record/play are pressed is from https://stackoverflow.com/questions/45578888/ios-voiceover-wait-on-element-to-finish-reading-before-changing-to-next-element
        RecordNoiseButton.accessibilityTraits.formUnion(UIAccessibilityTraits.startsMediaSession)
        PlayNoiseButton.accessibilityTraits.formUnion(UIAccessibilityTraits.startsMediaSession)
        RecordingProgressViewHolder.isAccessibilityElement = false // VoiceOver and Switch Control should ignore the progress bar
        RecordingProgressBarWidth.constant = 0
        RecordingProgressViewHolder.layer.borderWidth = 3
        RecordingProgressViewHolder.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        
        RecordNoiseButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        PlayNoiseButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        updateRecordPlayButtons()
    }
    
    /// Update accessibility elements based on state of screen
    func updateAccessibility() {
        RecordNoiseButton.accessibilityHint = "Can record up to \(MAX_AUDIO_LENGTH) seconds.".localized // TODO: localize
        BackButton.accessibilityLabel = "Back".localized
        if (hasNoise(forNum: selectedNoiseSlotNum)) {
            // Current slot has a noise, show selected noise, delete button, and play button and update record button
            SelectedNoiseImageView!.isAccessibilityElement = true
            SelectedNoiseImageView.accessibilityLabel = "\("Noise".localized) \(selectedNoiseSlotNum)."
            DeleteNoiseButton.accessibilityLabel = "\("Delete".localized) \("Noise".localized) \(selectedNoiseSlotNum)."
            
            accessibilityElements = [BackButton!, SelectCustomNoiseTitleLabel!, SelectedNoiseImageView!, DeleteNoiseButton!, PlayNoiseButton!, RecordNoiseButton!, NoisesCollectionView!]
            PlayNoiseButton.accessibilityLabel = "\("Play Noise".localized) \(selectedNoiseSlotNum)." // TODO: localize
            RecordNoiseButton.accessibilityLabel = "\("Re-record Noise".localized) \(selectedNoiseSlotNum)." //TODO: localize
        } else {
            // Current slot does not have a noise
            SelectedNoiseImageView!.isAccessibilityElement = false
            accessibilityElements = [BackButton!, SelectCustomNoiseTitleLabel!, PlayNoiseButton!, RecordNoiseButton!, NoisesCollectionView!]
            PlayNoiseButton.accessibilityLabel = "\("Play Noise".localized) \(selectedNoiseSlotNum). No noise recorded yet." // localize
            RecordNoiseButton.accessibilityLabel = "\("Record Noise".localized) \(selectedNoiseSlotNum)." // Localize
        }
    }
    
    // MARK: Record audio
    var isRecording = false
    var isCountingDown = false
    var isAudioPlayingBack = false
    /// When record button is tapped, either start or stop recording
    @objc func recordTapped() {
        if isRecording {
            finishRecording(success: true)
            return
        }
        
        if UIAccessibility.isVoiceOverRunning { // Count down recording
            isCountingDown = true
            RecordNoiseButton.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: "You will have up to \(self.MAX_AUDIO_LENGTH) seconds to record. Tap to end early. Recording will begin in 3. 2. 1.") // TODO: localize
            }
        } else {
            beginRecording()
        }
    }
    
    /// Called each time a voiceOver announcement finishes. If voiceOver just finished counting down for recording, start recording
    @objc func voiceOverAnnouncementFinished() {
        if isCountingDown {
            // Stop counting down and begin recording
            isCountingDown = false
            RecordNoiseButton.isEnabled = true
            beginRecording()
        }
    }
    
    /// Prepare for and begin recording
    func beginRecording() {
        eraseNoiseFile(forSlotNumber: selectedNoiseSlotNum) // erase any previous noise data
        
        let fileName = currentProject.getAudioFileURL(forSlotNumber: selectedNoiseSlotNum) // file name where this audio file will be saved
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            updateRecordPlayButtons()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Start recording
                self.oneSecondRecorded()
            }
        } catch {
            finishRecording(success: false)
        }
    }
    
    var numSecondsRecorded = 0
    /// Each second of recording, update the progress bar as well as determine if the recording has reached the max length
    func oneSecondRecorded() {
        numSecondsRecorded += 1
        let fullProgressBarWidth = Int(RecordingProgressViewHolder.bounds.width)
        RecordingProgressBarWidth.constant = CGFloat(numSecondsRecorded * (fullProgressBarWidth / MAX_AUDIO_LENGTH)) // Increase the progress bar width
        
        if (isRecording) {
            if (numSecondsRecorded < self.MAX_AUDIO_LENGTH) { // Set another timer
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.oneSecondRecorded()
                }
            } else { // Recording has reached max length
                self.finishRecording(success: true)
            }
        } else { // Not recording, reset progress bar
            numSecondsRecorded = 0
            RecordingProgressBarWidth.constant = 0
        }
    }
    
    // Called when a recording session is finished. Save audio file name and fill the slot
    func finishRecording(success: Bool) {
        if (isRecording) {
            audioRecorder?.stop()
            audioRecorder = nil
            isRecording = false
            
            // Reset recording progress bar
            numSecondsRecorded = 0
            RecordingProgressBarWidth.constant = 0
            
            if success {
                // Save noise file name to user data
                setNoiseFileName(forSlotNumber: selectedNoiseSlotNum, toFileName: currentProject.getAudioFileName(forSlotNumber: selectedNoiseSlotNum))
                
                // Fill the selected slot
                let selectedCell  = NoisesCollectionView.cellForItem(at: IndexPath(row: selectedNoiseSlotNum - 1, section: 0)) as! CustomAudioSlotCell
                
                selectedCell.fillSlot()
                updateSelectedNoiseImageView()
                
                updateRecordPlayButtons()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // need to wait a tiny bit to post the announcement so that it doesn't get muted by the button press
                    UIAccessibility.post(notification: .announcement, argument: "Recording finished.") // TODO: localize
                }
            } else {
                print("record fail")
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

    
    //MARK: Play audio
    /// Called when play button is tapped. Either starts or stops audio
    @objc func playTapped() {
        if !isAudioPlayingBack {
            // Start audio
            RecordNoiseButton.isEnabled = false
            prepareAudioPlayer()
            audioPlayer?.play()
            isAudioPlayingBack = true
            updateRecordPlayButtons()
        } else {
            // Stop audio
            audioPlayer?.stop()
            isAudioPlayingBack = false
            updateRecordPlayButtons()
        }
    }
    
    private func playNoiseFile(forSlotNumber slotNumber : Int) {
        if !hasNoise(forNum: slotNumber) { return }
        let soundName = getNoiseFileName(forSlotNumber: slotNumber)!
        
        // Code to play audio is from https://www.tutorialspoint.com/how-to-play-a-sound-using-swift
        guard let path = Bundle.main.path(forResource: soundName, ofType:"mp3") else {
            print("Couldn't find sound file for", soundName)
                 return }
        let url = URL(fileURLWithPath: path)
        do {
            
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
        
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isAudioPlayingBack = false
        updateRecordPlayButtons()
    }
    
    /// Get audio player ready ro play the audio for the current slot
    func prepareAudioPlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: currentProject.getAudioFileURL(forSlotNumber: selectedNoiseSlotNum) as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 2.0
        }
    }
    
    /// Update the record and play buttons based on the state of the screen
    func updateRecordPlayButtons() {
        if isRecording { // disable playback while recording
            PlayNoiseButton.isEnabled = false
            RecordNoiseButton.isEnabled = true
            RecordNoiseButton.setBackgroundImage(HelperFunctions.getUIImage(named: "stopSign"), for: .normal)
            RecordingProgressViewHolder.layer.opacity = 100
        } else {
            RecordNoiseButton.isEnabled = true
            RecordNoiseButton.setBackgroundImage(HelperFunctions.getUIImage(named: "record"), for: .normal)
            RecordingProgressViewHolder.layer.opacity = 0
            
            if isAudioPlayingBack { // disable recording during playback
                RecordNoiseButton.isEnabled = false
                PlayNoiseButton.isEnabled = true
                PlayNoiseButton.setBackgroundImage(HelperFunctions.getUIImage(named: "stopSign"), for: .normal)
            } else {
                RecordNoiseButton.isEnabled = true
                PlayNoiseButton.setBackgroundImage(HelperFunctions.getUIImage(named: "GreenArrow"), for: .normal)
                if hasNoise(forNum: selectedNoiseSlotNum) { // Only enable play button if there is a sound saved
                    PlayNoiseButton.isEnabled = true
                    RecordNoiseButton.setBackgroundImage(HelperFunctions.getUIImage(named: "rerecord"), for: .normal)
                } else {
                    PlayNoiseButton.isEnabled = false
                    RecordNoiseButton.setBackgroundImage(HelperFunctions.getUIImage(named: "record"), for: .normal)
                }
            }
        }
    }
    
    // MARK: Selected Noise
    /// Called when the delete current noise button is tapped. Confirms action with a popup and then clears and erases the current slot.
    @objc func deleteNoiseTapped() {
        // Create popup alert
        let titleString = NSLocalizedString("Are you sure you want to delete this sound?", comment: "Popup to confirm deleting a custom sound")
        let alert = UIAlertController(title: titleString, message: "This action cannot be undone.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: {action in
            // When delete is clicked, delete the sound
            if let selectedCell  = self.NoisesCollectionView.cellForItem(at: IndexPath(row: self.selectedNoiseSlotNum - 1, section: 0)) as? CustomAudioSlotCell { // Find the selected cell
                selectedCell.clearSlot()
                self.eraseNoiseFile(forSlotNumber: self.selectedNoiseSlotNum)
                self.updateSelectedNoiseImageView()
                self.updateRecordPlayButtons()
            }
        }))
        present(alert, animated: true)
    }
    
    /// Show audio image when the slot is filled, otherwise show nothing
    func updateSelectedNoiseImageView() {
        if hasNoise(forNum: selectedNoiseSlotNum) {// show audio image when slot is filled
            let audioImage = HelperFunctions.getUIImage(named: currentProject.getCustomAudioImageFileName(forSlotNumber: selectedNoiseSlotNum))
            SelectedNoiseImageView.image = audioImage
            DeleteNoiseButton.isHidden = false
        } else {
            SelectedNoiseImageView.image = nil // show no image, only record and play buttons
            DeleteNoiseButton.isHidden = true
        }
        // Always update accessibility
        updateAccessibility()
    }
    
   
    // MARK: User Data
    /// Check if the given number has a noise saved to it
    private func hasNoise(forNum num : Int) -> Bool{
        return currentProject.hasNoise(forSlotNumber: num)
    }
    
    /// If the slot has a noise, return its file name. Otherwise return nil
    private func getNoiseFileName(forSlotNumber slotNumber : Int) -> String? {
        return currentProject.getCustomAudioPaths()[slotNumber - 1] ?? nil
    }
    
    private func setNoiseFileName(forSlotNumber slotNum : Int, toFileName fileName : String) {
        currentProject.addCustomAudio(path: fileName, forSlotNumber: slotNum)
    }
    
    /// Remove noise file from project and from file directory
    private func eraseNoiseFile(forSlotNumber slotNum : Int) {
        currentProject.clearAudio(forSlotNumber: slotNum)
    }
    
    /// Select the slot that was previously selected
    func preserveLastSelection() {
        if let previousSlotString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["slotNumber"] {
            if let previousSlotNumber: Int = Int(previousSlotString) {
                selectedNoiseSlotNum = previousSlotNumber
                updateSelectedNoiseImageView()
                return
            }
        }
        // By default, focus on the first sound
        selectedNoiseSlotNum = 1
        updateSelectedNoiseImageView()
    }
    
    // MARK: Collection View
    
    // Code for creating a UICollectionView programmatically is from: https://medium.com/@buttam1703/how-to-create-a-uicollectionview-programmatically-in-swift-a030da15d445

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentProject.getCustomAudioPaths().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentCellIndex = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomAudioSlotCell.identifier, for: indexPath) as! CustomAudioSlotCell
        cell.configure(withProject: currentProject, withSlotNumber: currentCellIndex + 1, withNoise: currentProject.getCustomAudioPaths()[currentCellIndex] ?? "")
        
        if selectedNoiseSlotNum == currentCellIndex + 1 { // This cell is selected. Highlight it
            cell.highlight()
        }
        if hasNoise(forNum: currentCellIndex + 1) { // fill the slot if there is a noise file associated with the slot
            cell.fillSlot()
        }
        updateSelectedNoiseImageView()
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect all cells
        for cell in collectionView.visibleCells{
            let currentCell = cell as! CustomAudioSlotCell
            currentCell.removeHighlight()
            currentCell.isSelected = false
        }
        
        // Highlight the one selected cell
        let selectedCell = collectionView.cellForItem(at: indexPath) as! CustomAudioSlotCell
        selectedCell.highlight()
        selectedCell.isSelected = true
        
        // Stop recording
        if isRecording {
            finishRecording(success: true)
        }
        
        // Stop any audio that is playing
        if isAudioPlayingBack {
            audioPlayer?.stop()
            isAudioPlayingBack = false
        }
        
        // Update UI
        selectedNoiseSlotNum = selectedCell.getSlotNumber()
        updateSelectedNoiseImageView()
        updateRecordPlayButtons()
    }
    
    /// Return the size for the item at a given index path
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: CGFloat(buttonSize), height: CGFloat(buttonSize))
        return size
    }
    
    /// Center cells horizonally
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       // Centering cells horizonally is from  https://stackoverflow.com/questions/34267662/how-to-center-horizontally-uicollectionview-cells#:~:text=301-,Its%20not%20a%20good,-idea%20to%20use
        let totalCellWidth = buttonSize * currentProject.getCustomAudioPaths().count
        let totalSpacingWidth = 15 * (currentProject.getCustomAudioPaths().count - 1)

        let leftInset = (NoisesCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    // MARK: Navigation
    @IBAction func backButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "backToFreeplay") {
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["slotNumber"] = String(selectedNoiseSlotNum)// Tell BlocksViewController which index was selected
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["customNoise"] = getNoiseFileName(forSlotNumber: selectedNoiseSlotNum)// Tell BlocksViewController which noise goes with that index
        }
    }
}

/// Cell used in NoisesCollectionView that represents a slot that can hold a custom audio file
class CustomAudioSlotCell: UICollectionViewCell {
    static let identifier = "customAudioSlotCell"
    
    // Lazy initialization of the UIImageView
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Lazy initialization of the add sound image view
    private lazy var addSoundImageView: UIImageView = {
        let addSoundImageView = UIImageView()
        addSoundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSoundImageView.contentMode = .scaleAspectFit
        return addSoundImageView
    }()
    
    private var slotNumber: Int = 1
    
    private var isFilled = false
    
    private var project: Project // Project this slot is a part of
    
    override init(frame: CGRect) {
        self.project = UserData.data.getCurrentProject()!
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withProject project: Project, withSlotNumber num: Int, withNoise noise: String) {
        self.slotNumber = num
        self.project = project
        backgroundColor = UIColor(named: "gray_color")
        addSoundImageView.image = HelperFunctions.getUIImage(named: "addCustomNoise")
        
        if isFilled {
            let audioImage = HelperFunctions.getUIImage(named: self.project.getCustomAudioImageFileName(forSlotNumber: slotNumber))
            imageView.image = audioImage
        }
        
        self.isAccessibilityElement = true
        updateAccessibility()
    }
    
    func fillSlot() {
        isFilled = true
        let audioImage = HelperFunctions.getUIImage(named: project.getCustomAudioImageFileName(forSlotNumber: slotNumber))
        imageView.image = audioImage
        
        updateAccessibility()
    }
    
    func clearSlot() {
        isFilled = false
        imageView.image = nil
        updateAccessibility()
    }
    
    func updateAccessibility() {
        var formattedString: String
        if isFilled {
            formattedString = NSLocalizedString("custom_noise_cell_access_label_filled", comment: "Accessibility label for Custom Noise Cell that has a sound associated with it")
            
        } else {
            formattedString = NSLocalizedString("custom_noise_cell_access_label_empty", comment: "Accessibility label for Custom Noise Cell that does not have a sound associated with it")
        }
        let resultString = String.localizedStringWithFormat(formattedString, slotNumber, UserData.data.getMaxNumCustomNoises())
        
        self.accessibilityLabel = resultString
    }

    private func isSlotFilled() -> Bool {
        return isFilled
    }
    
    func getSlotNumber() -> Int {
        return slotNumber
    }
    
    func highlight() {
        layer.borderWidth = 10
        layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        isSelected = true
    }
    func removeHighlight() {
        layer.borderWidth = 0
        isSelected = false
    }
    
    // Setup the view and add imageView with constraints
    private func setupView() {
        contentView.addSubview(addSoundImageView)
        NSLayoutConstraint.activate([
            addSoundImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            addSoundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -10),
            addSoundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            addSoundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
