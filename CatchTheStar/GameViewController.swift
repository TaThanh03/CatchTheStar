import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var currentGame: GameScene!
    var gameOverView: GameOverView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentGame = GameScene(size: CGSize(width: 2048, height: 1536))
        currentGame.viewController = self
        
        let view = self.view as! SKView
        // Set the scale mode to scale to fit the window
        currentGame.scaleMode = .aspectFill
        view.showsFPS = true
        //view.showsNodeCount = true
        view.ignoresSiblingOrder = true
        
        
        
        //SettingScene
        gameOverView = GameOverView(frame: UIScreen.main.bounds)
        gameOverView!.isHidden = true
        view.addSubview(gameOverView!)
        
        // Present the scene
        view.presentScene(currentGame)
    }
    
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func actionSettingButtonRestartTouched (sender: UIButton!) {
        gameOverView?.isHidden = true
        currentGame.startNewLevel()
    }
}
