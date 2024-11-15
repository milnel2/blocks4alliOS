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
class SelectCustomNoiseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var currentProject: Project? // Project user is currently working in
   
    let shapes: [CustomNoiseShape] = [.circle, .square, .triangle, .star, .pentagon ] // an ordered list of all of the shapes
    private var noiseShapeDictionary: Dictionary<CustomNoiseShape, String?> = [.circle: nil,
        .square: nil,
        .triangle: nil,
        .star: nil,
        .pentagon: nil] // TODO: should it be colors? Fruits? Shapes? // shapes and their associated audio paths
    
    private var selectedNoise: CustomNoiseShape = CustomNoiseShape.circle // noise that is currently selected
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        preserveLastSelection()
    }
    
    // Check if the given shape has a noise saved to it
    private func hasNoise(forShape shape : CustomNoiseShape) -> Bool{
        return noiseShapeDictionary[shape] != nil
    }
    
    private func getNoiseFileName(forShape shape : CustomNoiseShape) -> String? {
        return noiseShapeDictionary[shape] ?? nil
    }
    
    private func setNoiseFileName(forShape shape : CustomNoiseShape, toFileName fileName : String) {
        noiseShapeDictionary[shape] = fileName
    }
    
    private func eraseNoiseFile(forShape shape : CustomNoiseShape) {
        noiseShapeDictionary[shape] = nil
    }
    
    private func playNoiseFile(forShape shape : CustomNoiseShape) {
        if !hasNoise(forShape: shape) { return }
        let soundName = getNoiseFileName(forShape: shape)!
        
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
        if let previousShapeString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["shape"] {
            // Look for shape that has the same name
            for shape in shapes {
                if shape.rawValue == previousShapeString {
                    selectedNoise = shape
                    return
                }
            }
        }
        // By default, focus on the circle
        selectedNoise = .circle
   }
    
    
    // MARK: Collection View
    
    // Code for creating a UICollectionView programmatically is from: https://medium.com/@buttam1703/how-to-create-a-uicollectionview-programmatically-in-swift-a030da15d445

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noiseShapeDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentShape = shapes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShapeCell.identifier, for: indexPath) as! ShapeCell
        cell.configure(withShape: currentShape, withNoise: noiseShapeDictionary[currentShape]! ?? "")
        
        if selectedNoise == currentShape {
            cell.highlight()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells{
            let selectedCell = cell as! ShapeCell
            selectedCell.removeHighlight()
        }
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ShapeCell // highlight the one selected cell
        selectedCell.highlight()
        selectedNoise = selectedCell.getShape()
    }
    
    // Return the size for the item at a given index path
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let size = mainCollectionView.frame.width
           return CGSize(width: size, height: size)
       }
    
    private lazy var mainCollectionView: UICollectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            collectionView.register(ShapeCell.self, forCellWithReuseIdentifier: ShapeCell.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
            collectionView.showsVerticalScrollIndicator = false
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
    
    // Method to reload the collection view on the main thread
       func reloadCollectionView() {
           DispatchQueue.main.async { [weak self] in
               self?.mainCollectionView.reloadData()
           }
       }
       
       // Setup the view and add collection view with constraints
       private func setupView() {
           view.addSubview(mainCollectionView)
           NSLayoutConstraint.activate([
            mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
               mainCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 200),
               mainCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 100),
               mainCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
           ])
       }
    
    
    // MARK: Navigation
    @IBAction func backButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "backToFreeplay") {
            let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
            
            freeplayWorkspaceVC.currentProject = currentProject // pass the current project back to the workspaceVC
            
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["shape"] = selectedNoise.rawValue// Tell BlocksViewController which shape was selected
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["customNoise"] = getNoiseFileName(forShape: selectedNoise)// Tell BlocksViewController which noise goes with that shape
        }
         
    }
    
}

enum CustomNoiseShape: String {
    case circle = "circle"
    case square = "square"
    case triangle = "triangle"
    case star = "star"
    case pentagon = "pentagon"
}

class ShapeCell: UICollectionViewCell {
    static let identifier = "ShapeCell"
    
    // Lazy initialization of the UIImageView
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var shape: CustomNoiseShape = .circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with the image name
    func configure(withShape shape: CustomNoiseShape, withNoise noise: String) {
        self.shape = shape
        let shapeImage = HelperFunctions.getUIImage(named: shape.rawValue)
        imageView.image = shapeImage
    }
    
    func getShape() -> CustomNoiseShape {
        return shape
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
