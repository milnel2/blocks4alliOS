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
    @IBOutlet weak var SelectedNoiseImageView: UIImageView!
    @IBOutlet weak var PlayNoiseButton: UIButton!
    @IBOutlet weak var RecordNoiseButton: UIButton!
    
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
    private var noiseFiles: [String?] = [nil, nil, nil, nil, nil] // audio path associated with each index
    
    private var selectedNoiseIndex: Int = 0 // noise index that is currently selected
   
    private let buttonSize = (((defaults.value(forKey: "blockSize") as! Int) * 10) / 9) // the size of each button that is showed in the collection view // TODO: handle different block sizes
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedNoiseFiles()
        
        NoisesCollectionView.delegate = self
        NoisesCollectionView.dataSource = self
        NoisesCollectionView.register(AudioCell.self, forCellWithReuseIdentifier: "AudioCell")
        
        preserveLastSelection()
        
        // Set up audio recording
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
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
       
    }
    
    func loadRecordingUI() {
        RecordNoiseButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        PlayNoiseButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        updateRecordPlayButtons()
    }
    
    
    let index = 0
    var isRecording = false
    var isAudioPlayingBack = false
    @objc func recordTapped() {
        if isRecording {
            finishRecording(success: true)
            return
        }
        let fileName = UserData.data.getAudioFileURL(forIndex: selectedNoiseIndex)
        
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.finishRecording(success: true)
            }
        } catch {
            finishRecording(success: false)
        }

    }
    
    func finishRecording(success: Bool) {
        if (isRecording) {
            audioRecorder?.stop()
            audioRecorder = nil
            isRecording = false
           
            if success {
                setNoiseFileName(forIndex: selectedNoiseIndex, toFileName: UserData.data.getAudioFileName(forIndex: selectedNoiseIndex))
            } else {
                print("record fail")
            }
            
            updateRecordPlayButtons()
        }
       
    }
    
    @objc func playTapped() {
        if !isAudioPlayingBack {
            RecordNoiseButton.isEnabled = false
            prepareAudioPlayer()
            audioPlayer?.play()
            isAudioPlayingBack = true
            updateRecordPlayButtons()
        } else {
            audioPlayer?.stop()
            isAudioPlayingBack = false
            updateRecordPlayButtons()
        }
       
    }
    
    func prepareAudioPlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: UserData.data.getAudioFileURL(forIndex: selectedNoiseIndex) as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 5.0
            print("prepared")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isAudioPlayingBack = false
        updateRecordPlayButtons()
    }
    
    func updateRecordPlayButtons() {
        print(noiseFiles)
        print("isRecording = \(isRecording), isPlaying = \(isAudioPlayingBack)")
        if isRecording { // disable playback while recording
            PlayNoiseButton.isEnabled = false
            RecordNoiseButton.isEnabled = true // TODO: turn into stop button
            RecordNoiseButton.setTitle("Stop", for: .normal)
        } else {
            RecordNoiseButton.setTitle("", for: .normal)
            RecordNoiseButton.isEnabled = true
            
            if isAudioPlayingBack { // disable recording during playback
                RecordNoiseButton.isEnabled = false
                PlayNoiseButton.isEnabled = true // TODO: turn into stop button
                PlayNoiseButton.setTitle("Stop", for: .normal)
            } else {
                PlayNoiseButton.setTitle("", for: .normal)
                RecordNoiseButton.isEnabled = true
                if hasNoise(forIndex: selectedNoiseIndex) { // Only enable play button if there is a sound saved
                    PlayNoiseButton.isEnabled = true
                } else {
                    PlayNoiseButton.isEnabled = false
                }
            }
        }
    }
    
    func updateSelectedNoiseImageView() {
        let audioImage = HelperFunctions.getUIImage(named: UserData.data.getAudioFileName(forIndex: selectedNoiseIndex))
        SelectedNoiseImageView.image = audioImage
    }
    
    // Loads all custom audio paths into the noise files list
    func loadSavedNoiseFiles() {
        noiseFiles = UserData.data.getCustomAudioPaths()
    }
    
    // Check if the given index has a noise saved to it
    private func hasNoise(forIndex index : Int) -> Bool{
        return noiseFiles[index] != nil
    }
    
    private func getNoiseFileName(forIndex index : Int) -> String? {
        return noiseFiles[index] ?? nil
    }
    
    private func setNoiseFileName(forIndex index : Int, toFileName fileName : String) {
        noiseFiles[index] = fileName
    }
    
    private func eraseNoiseFile(forIndex index : Int) {
        noiseFiles[index] = nil
    }
    
    private func playNoiseFile(forIndex index : Int) {
        if !hasNoise(forIndex: index) { return }
        let soundName = getNoiseFileName(forIndex: index)!
        
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
    
    // select the shape that was previously selected
    func preserveLastSelection() {
        if let previousIndexString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["index"] {
            if let previousIndex: Int = Int(previousIndexString) {
                selectedNoiseIndex = previousIndex
                updateSelectedNoiseImageView()
                return
            }
        }
        // By default, focus on the first sound
        selectedNoiseIndex = 0
        updateSelectedNoiseImageView()
    }
       
    
    
    // MARK: Collection View
    
    // Code for creating a UICollectionView programmatically is from: https://medium.com/@buttam1703/how-to-create-a-uicollectionview-programmatically-in-swift-a030da15d445

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noiseFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentCellIndex = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCell.identifier, for: indexPath) as! AudioCell
        cell.configure(withIndex: currentCellIndex, withNoise: noiseFiles[currentCellIndex] ?? "")
        
        if selectedNoiseIndex == currentCellIndex { // This cell is selected. Highlight it
            cell.highlight()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells{
            let selectedCell = cell as! AudioCell
            selectedCell.removeHighlight()
        }
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! AudioCell // highlight the one selected cell
        selectedCell.highlight()
        selectedNoiseIndex = selectedCell.getIndex()
        updateSelectedNoiseImageView()
        updateRecordPlayButtons()
    }
    
    // Return the size for the item at a given index path
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: CGFloat(buttonSize), height: CGFloat(buttonSize))
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       // Centering cells horizonally is from  https://stackoverflow.com/questions/34267662/how-to-center-horizontally-uicollectionview-cells#:~:text=301-,Its%20not%20a%20good,-idea%20to%20use
        let totalCellWidth = buttonSize * noiseFiles.count
        let totalSpacingWidth = 15 * (noiseFiles.count - 1)

        let leftInset = (NoisesCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
          
    }
    

    // Method to reload the collection view on the main thread
       func reloadCollectionView() {
           DispatchQueue.main.async { [weak self] in
               self?.NoisesCollectionView.reloadData()
           }
       }
    
    
    // MARK: Navigation
    @IBAction func backButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "backToFreeplay") {
            let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
            
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["index"] = String(selectedNoiseIndex)// Tell BlocksViewController which index was selected
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["customNoise"] = getNoiseFileName(forIndex: selectedNoiseIndex)// Tell BlocksViewController which noise goes with that index
        }
         
    }
    
}



class AudioCell: UICollectionViewCell {
    static let identifier = "AudioCell"
    
    // Lazy initialization of the UIImageView
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with the image name
    func configure(withIndex index: Int, withNoise noise: String) {
        self.index = index
        let audioImage = HelperFunctions.getUIImage(named: UserData.data.getAudioFileName(forIndex: index))
        imageView.image = audioImage
    }
    
    func getIndex() -> Int {
        return index
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
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
