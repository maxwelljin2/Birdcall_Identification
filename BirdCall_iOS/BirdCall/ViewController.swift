//
//  ViewController.swift
//  BirdCall
//
//  Created by gene on 2020/12/19.
//


import UIKit
import AVKit
import SoundAnalysis

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = Birdcall()
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.custom.AnalysisQueue")
    
    //Display img from url
    func setImage(from url: String) {
        guard let URLKey = URL(string: url)
        else {
            return
        }
        //Avoid Crash
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: URLKey) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    let transcribedText:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        view.textAlignment = .center
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = UIColor.white
        return view
    }()
    
    let placeholderText:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .left
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = "Bird Classification"
        view.textColor = UIColor.white
        view.font = UIFont.boldSystemFont(ofSize: 25)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
        buildUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAudioEngine()
    }
    
    func buildUI()
    {
        self.view.addSubview(placeholderText)
        self.view.addSubview(transcribedText)
        NSLayoutConstraint.activate(
            [transcribedText.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             transcribedText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             transcribedText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             transcribedText.heightAnchor.constraint(equalToConstant: 200),
             transcribedText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [placeholderText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
             placeholderText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             placeholderText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             placeholderText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
        //Add Background color
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x:-0.5,y:-0.5)
        gradient.endPoint = CGPoint(x:1,y:1)
        let startColor: UIColor = UIColor(red: 97/255, green: 99/255, blue: 213/255, alpha: 0.8)
        let endColor: UIColor = UIColor(red: 122/255, green: 163/255, blue: 228/255, alpha: 1)

        gradient.colors = [endColor.cgColor, startColor.cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func startAudioEngine() {
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
       
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8000, format: inputFormat) { buffer, time in
                self.analysisQueue.async {
                    self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
        }
        
        do{
        try audioEngine.start()
        }catch( _){
            print("Error")
        }
    }
}

protocol BirdClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}

extension ViewController: BirdClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            self.setImage(from: "https://bird-image-1258623347.cos.ap-beijing.myqcloud.com/\(identifier).jpg" )
            self.transcribedText.text = ("Recognition: \(identifier)\nConfidence: \(Int(confidence))%")
        }
    }
}

struct bird_species{
    var name: String
    var num: Int = 0
}

class ResultsObserver: NSObject, SNResultsObserving {
    var num: Int = 0
    var list = [bird_species(name: "Duck"),bird_species(name: "Golden_Pheasant"),bird_species(name: "Grey_crown_crane"),bird_species(name: "Hornbill"),bird_species(name: "Kingfisher"),bird_species(name: "Magpie"),bird_species(name: "No Call"),bird_species(name: "Swallow"),bird_species(name: "Swan"),bird_species(name: "Trush")]
    
    var timer: Int = 0
    var delegate: BirdClassifierDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        let confidence = classification.confidence * 100.0
        var bird_name = classification.identifier
        if confidence > 99 {
            timer += 1
            print(timer)
        
            //Take the average
            for i in 0..<list.count{
                if list[i].name == bird_name{
                    print(bird_name)
                    list[i].num += 1
                }
            }
            print(list)
            
            var max_time: Int = list[0].num
            
            for i in 0..<list.count{
                if list[i].num > max_time{
                    max_time = list[i].num
                    bird_name = list[i].name
                }
            }
            print(bird_name)
            
            if timer % 15 == 0{
                for i in 0..<list.count{
                    list[i].num = 0
                }
            }
            //Because the possibility that regonize Swallow and Hornbill is so low, we should delete them
            if bird_name == "Swallow"{
                bird_name = "No_Call"
            }
            
            if bird_name == "Hornbill"{
                bird_name = "No_Call"
            }
        
            delegate?.displayPredictionResult(identifier: bird_name, confidence: confidence)
        }
    }
}
