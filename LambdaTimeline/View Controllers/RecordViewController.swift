
import UIKit

class RecordViewController: UIViewController, PlayerDelegate, RecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var titleTextField: UITextField!
    
    private let player = Player()
    private let recorder = Recorder()
    
    var postController = PostController()
    var post: Post?
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        f.allowedUnits = [.minute, .second]
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        recorder.delegate = self
    }
    
    
    @IBAction func tappedRecordButton(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    @IBAction func tappedPlayButton(_ sender: Any) {
        player.playPause(file: recorder.currentFile)
    }
    
    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
    
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    private func updateViews() {
        let isPlaying = player.isPlaying
        playButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        let isRecording = recorder.isRecording
        recordButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
        
        let elapsedTime = player.elapsedTime
        elapsedTimeLabel.text = timeFormatter.string(from: player.elapsedTime)
        
        remainingTimeLabel.text = timeFormatter.string(from: player.remainingTime)
        
        timerSlider.minimumValue = 0
        timerSlider.maximumValue = Float(player.totalTime)
        timerSlider.value = Float(player.elapsedTime)
    }
    
    @IBAction func addCommentButton(_ sender: Any) {
        
        // Save the comment here
        guard let audioURL = recorder.currentFile else { return }
        
        let title = titleTextField.text
        
        //let audioURLString = audioURL.absoluteString
        
//        postController.addAudioComment(with: title ?? "", audioURL: audioURL, to: post)
        
        let audioURLData = try! Data(contentsOf: audioURL)
        
        self.postController.store(mediaData: audioURLData, mediaType: .audio) { (url) in
            guard let url = url else { return }
            
            // Add the comment to firebase w/ reference to ...
           self.postController.addAudioComment(with: title ?? "", audioURL: url, to: self.post!)
            
            DispatchQueue.main.async {
                
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

