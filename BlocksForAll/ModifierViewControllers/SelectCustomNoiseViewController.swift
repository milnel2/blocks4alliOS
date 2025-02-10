//
//  SelectCustomNoiseViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 11/10/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import AVFAudio

// Code for creating a UICollectionView programmatically is from: https://medium.com/@buttam1703/how-to-create-a-uicollectionview-programmatically-in-swift-a030da15d445
class SelectCustomNoiseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var NoisesCollectionView: UICollectionView! // Holds row of custom noise options
    @IBOutlet weak var SelectedNoiseImageView: UIImageView!
    //@IBOutlet weak var PlayNoiseButton: UIButton!
    //@IBOutlet weak var RecordNoiseButton: UIButton!
    
    
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var currentProject: Project? // Project user is currently working in
    
    
    
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
            
            freeplayWorkspaceVC.currentProject = currentProject // pass the current project back to the workspaceVC
            
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
