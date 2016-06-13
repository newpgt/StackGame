//
//  GameViewController.swift
//  StackNeo
//
//  Created by NeoZ on 4/3/16.
//  Copyright (c) 2016年 NeoZ. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation
import AudioToolbox

class GameViewController: UIViewController, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var viewGame = SCNView()
    
    var gradient: CAGradientLayer = CAGradientLayer()
    
    var scoreLabel = UILabel()
    var gameoverLabel = UILabel()
    var startButton = UIButton()
    
    var redInt = CGFloat()
    var greenInt = CGFloat()
    var blueInt = CGFloat()
    
    var boxNeo = SCNNode()
    var cameraNode = SCNCamera()

    let oringinalWidth : CGFloat = 5.0
    
    let hardRateFloat : Float = 0.1 //难度，数值越大越容易
    
    var NextWidthX = CGFloat()
    var NextLengthZ = CGFloat()
    
    var dropWidthX = CGFloat()
    var dropLengthZ = CGFloat()
    
    var offsetX = Float()
    var offsetZ = Float()
    
    var dropOffsetX = Float()
    var dropOffsetZ = Float()
    
    var directionX = Bool()
    
    var boxNode = SCNNode()
    
    //var bottomNode = SCNNode()
    
    var boxNodeCut = SCNNode()
    
    //var boxDrop = SCNNode()
    
//    let boxNeoCategory: Int = 0x1 << 0
//    let boxDropCategory: Int = 0x1 << 1
    
    var points : Int = 0
    
    //var hexValue : Int  = 0xBAE8E7
    
    //var audioCutPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("glassSound", ofType: "mp3")!))

    var soundID:SystemSoundID = 0
    var soundID2:SystemSoundID = 2
    var soundID3:SystemSoundID = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let view: UIView = UIView(frame: CGRectMake(0.0, 0.0, 320.0, 50.0))
        let view: UIView = UIView(frame: self.view.frame)
        //let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)

        self.view.addSubview(view)

        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        scene.physicsWorld.gravity = SCNVector3Make(0, -9.8, 0)
        scene.physicsWorld.contactDelegate = self
        
        
        redInt = 186
        greenInt = 232
        blueInt = 231

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)

        
        boxNeo = scene.rootNode.childNodeWithName("boxNeo", recursively: true)!
        
        boxNeo.geometry!.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)
        
        let boxGeometry = SCNBox(width: 5.0, height: 1.0, length: 5.0, chamferRadius: 0.0)
        boxGeometry.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)//UIColor(netHex: hexValue) // UIColor.redColor()
        
        boxNode = SCNNode(geometry: boxGeometry)
        
        directionX = false

        scene.rootNode.addChildNode(boxNode)
        
        viewGame = SCNView(frame: self.view.frame)
        viewGame.backgroundColor = UIColor.clearColor()
        self.view.addSubview(viewGame)
        
        let scnView = viewGame
        
        //label
        scoreLabel = UILabel(frame: CGRect( x: 50, y: 50, width: self.view.frame.size.width - 100, height: 50))
        scoreLabel.text = "score:"
        scoreLabel.textAlignment = NSTextAlignment.Center
        scoreLabel.font = UIFont(name: "Chalkduster", size: 30)
        scoreLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(scoreLabel)
        
        gameoverLabel = UILabel(frame: CGRect( x: 50, y: 120, width: self.view.frame.size.width - 100, height: 50))
        gameoverLabel.text = "Game Over"
        gameoverLabel.textAlignment = NSTextAlignment.Center
        gameoverLabel.font = UIFont(name: "Chalkduster", size: 30)
        gameoverLabel.textColor = UIColor.whiteColor()
        gameoverLabel.hidden = true
        self.view.addSubview(gameoverLabel)
        
        startButton.setImage(UIImage(named: "play"), forState: .Normal)
        startButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        startButton.frame = CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height / 2 - 40, 80, 80)
        startButton.addTarget(self, action: #selector(GameViewController.pressedToStart(_:)), forControlEvents: .TouchUpInside)

        self.view.addSubview(startButton)
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.clearColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleTap(_:)))
        tapGesture.delegate = self
        scnView.addGestureRecognizer(tapGesture)
        
        //beginNewGame()
        
        //scnView.scene?.physicsWorld.gravity = SCNVector3Make(0, -9.0, 0)
        
        
    }
    
    func pressedToStart(sender: UIButton!) {
        startButton.hidden = true
        gameoverLabel.hidden = true
        
        gradient.colors = [colorWithRGB(CGFloat(Int.random(120...180)), g: CGFloat(Int.random(120...180)), b: CGFloat(Int.random(120...180))).CGColor,UIColor.blackColor().CGColor]
        
        boxNeo.enumerateChildNodesUsingBlock { (node, stop) -> Void in
            node.removeFromParentNode()
        }

        redInt = CGFloat(Int.random(120...180))
        greenInt = CGFloat(Int.random(120...180))
        blueInt = CGFloat(Int.random(120...180))
        
        points = 0
        scoreLabel.text = "\(points)"
        
        let boxGeometryNew = SCNBox(width: 5.0, height: 30.0, length: 5.0, chamferRadius: 0.0)
        boxGeometryNew.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)
        
        boxNeo.position = SCNVector3Make(0.0, -15.0, 0.0)

        let boxGeometry = SCNBox(width: 5.0, height: 1.0, length: 5.0, chamferRadius: 0.0)
        boxGeometry.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)//UIColor(netHex: hexValue) // UIColor.redColor()
        
        boxNode.geometry = boxGeometry
        
        directionX = false
        
        boxNode.removeActionForKey("something")
        
        boxNode.position = SCNVector3Make(0.0, 0.5, -5.0)
        //boxNode.runAction(SCNAction.moveTo(SCNVector3Make(-5.0, 0.25, 0.0), duration: 0.0))
        let moveUp = SCNAction.moveTo(SCNVector3Make(0.0, 0.5, 5.0), duration: 1.5)
        let moveDown = SCNAction.moveTo(SCNVector3Make(0.0, 0.5, -5.0), duration: 1.5)
        let sequence = SCNAction.sequence([moveUp,moveDown])
        let repeatedSequence = SCNAction.repeatActionForever(sequence)
        boxNode.runAction(repeatedSequence, forKey: "something")
        
        //scene.rootNode.addChildNode(boxNode)
        
        NextWidthX = oringinalWidth
        NextLengthZ = oringinalWidth
        
        offsetX = 0.0
        offsetZ = 0.0
        
        dropLengthZ = 0.0
        dropWidthX = 0.0
        dropOffsetX = 0.0
        dropOffsetZ = 0.0
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        let scnView = viewGame
        
        var distance = Float()
        if directionX{
            distance = boxNode.presentationNode.position.x - offsetX
            if abs(distance) <= hardRateFloat {
                distance = 0
            }

            offsetX += distance / 2
            
            dropWidthX = CGFloat(abs(distance))
            dropLengthZ = NextLengthZ
            dropOffsetZ = offsetZ
            if distance < 0{
                dropOffsetX = offsetX - Float(NextWidthX / 2)
            }else{
                dropOffsetX = offsetX + Float(NextWidthX / 2)
            }
            
            NextWidthX = NextWidthX - CGFloat(abs(distance))
        }else{
            distance = boxNode.presentationNode.position.z - offsetZ

            if abs(distance) <= hardRateFloat {
                distance = 0
            }

            offsetZ += distance / 2
            
            dropWidthX = NextWidthX
            dropLengthZ = CGFloat(abs(distance))
            dropOffsetX = offsetX
            //dropOffsetZ = offsetZ + Float(NextLengthZ / 2)
            if distance < 0{
                dropOffsetZ = offsetZ - Float(NextLengthZ / 2)
            }else{
                dropOffsetZ = offsetZ + Float(NextLengthZ / 2)
            }
            
            NextLengthZ = NextLengthZ - CGFloat(abs(distance))//* oringinalWidth/5
        }
        
        
        boxNode.removeActionForKey("something")
        
        if NextLengthZ <= 0 || NextWidthX <= 0{
            //print("Game Over!")
            let filePath = NSBundle.mainBundle().pathForResource("punch", ofType: "mp3")
            let soundURL = NSURL(fileURLWithPath: filePath!)
            AudioServicesCreateSystemSoundID(soundURL, &soundID3)
            AudioServicesPlaySystemSound(soundID3)

            
            scoreLabel.text = "Best:\(points)"
            startButton.hidden = false
            gameoverLabel.hidden = false
        }else{
            
            let moveDown = SCNAction.moveBy(SCNVector3Make(0.0, -1.0, 0.0), duration: 0.2)
            boxNeo.runAction(moveDown)
            
            points += 1
            
            scoreLabel.text = "\(points)"
            
            let height = CGFloat (2.0 * Float(points)) + 30.0
            
            let boxGeometryNew = SCNBox(width: 5.0, height: height, length: 5.0, chamferRadius: 0.0)
            boxGeometryNew.firstMaterial?.diffuse.contents = UIColor.clearColor()

            
            if redInt >= 250{
                redInt = CGFloat(Int.random(120...180))
            }else{
                redInt += 3.0
            }
            
            if greenInt >= 250{
                greenInt = CGFloat(Int.random(120...180))

            }else{
                greenInt += 8.0
            }
            
            if blueInt >= 250{
                blueInt = CGFloat(Int.random(120...180))
            }else{
                blueInt += 10.0

            }
            
            gradient.colors = [colorWithRGB(255 - redInt, g: 255 - greenInt, b: 255 - blueInt).CGColor, colorWithRGB(redInt + 10, g: greenInt + 30, b: blueInt + 10).CGColor]
            
            let boxGeometry = SCNBox(width: NextWidthX, height: 1.0, length: NextLengthZ, chamferRadius: 0.0)
            boxGeometry.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)//UIColor(netHex: hexValue) //UIColor.greenColor()
            
            boxNodeCut = SCNNode(geometry: boxGeometry)
            //boxNode.opacity = 0.6
            boxNodeCut.position = SCNVector3Make(offsetX, Float(Double(boxGeometryNew.height) - 1.0) / 2, offsetZ)
            
            boxNodeCut.physicsBody = SCNPhysicsBody.kinematicBody()

            boxNeo.addChildNode(boxNodeCut)
            
            if distance == 0 {
                perfectMatchEmission()
                //let filePath = NSBundle.mainBundle().pathForResource("punch", ofType: "mp3")
                let filePath = NSBundle.mainBundle().pathForResource("perfect", ofType: "caf")//make sure selected a TARGET
                let soundURL = NSURL(fileURLWithPath: filePath!)
                AudioServicesCreateSystemSoundID(soundURL, &soundID)
                AudioServicesPlaySystemSound(soundID)
            }else{
                let filePath = NSBundle.mainBundle().pathForResource("blop", ofType: "mp3")
                let soundURL = NSURL(fileURLWithPath: filePath!)
                AudioServicesCreateSystemSoundID(soundURL, &soundID2)
                AudioServicesPlaySystemSound(soundID2)
                
                let boxDropGeometry = SCNBox(width: dropWidthX, height: 1.0, length: dropLengthZ, chamferRadius: 0.0)
                boxDropGeometry.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)//UIColor(netHex: hexValue)
                //boxDropGeometry.firstMaterial?.diffuse.contents = UIColor.redColor()
                //添加被切下的块
                let boxDrop = SCNNode(geometry: boxDropGeometry)
                boxDrop.physicsBody?.physicsShape = SCNPhysicsShape(geometry: boxDropGeometry, options: nil)
                boxDrop.physicsBody = SCNPhysicsBody.dynamicBody()
                boxDrop.position = SCNVector3Make(dropOffsetX, 0.5, dropOffsetZ)
                boxDrop.physicsBody?.affectedByGravity = true
                boxDrop.physicsBody?.mass = 10
                boxDrop.physicsField?.active = true
                
                scnView.scene?.rootNode.addChildNode(boxDrop)
            }

            boxNode.geometry = boxGeometry
            
            //
            if !directionX{
                boxNode.position = SCNVector3Make(-5.0, 0.5, offsetZ)
                //boxNode.runAction(SCNAction.moveTo(SCNVector3Make(-5.0, 0.25, 0.0), duration: 0.0))
                let moveUp = SCNAction.moveTo(SCNVector3Make(5.0, 0.5, offsetZ), duration: 1.5)
                let moveDown = SCNAction.moveTo(SCNVector3Make(-5.0, 0.5, offsetZ), duration: 1.5)
                let sequence = SCNAction.sequence([moveUp,moveDown])
                let repeatedSequence = SCNAction.repeatActionForever(sequence)
                boxNode.runAction(repeatedSequence, forKey: "something")
            }else{
                boxNode.position = SCNVector3Make(offsetX, 0.5, -5.0)
                //boxNode.runAction(SCNAction.moveTo(SCNVector3Make(0.0, 0.25, -5.0), duration: 0.0))
                let moveUp = SCNAction.moveTo(SCNVector3Make(offsetX, 0.5, 5.0), duration: 1.5)
                let moveDown = SCNAction.moveTo(SCNVector3Make(offsetX, 0.5, -5.0), duration: 1.5)
                let sequence = SCNAction.sequence([moveUp,moveDown])
                let repeatedSequence = SCNAction.repeatActionForever(sequence)
                boxNode.runAction(repeatedSequence, forKey: "something")
            }
            directionX = !directionX
            
            boxNode.geometry!.firstMaterial?.diffuse.contents = colorWithRGB(redInt, g: greenInt, b: blueInt)//UIColor(netHex: hexValue)
        }

    }
    
    func perfectMatchEmission(){
        // get its material
        let material = boxNode.geometry!.firstMaterial!
        let material2 = boxNodeCut.geometry!.firstMaterial!
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.3)
        
        // on completion - unhighlight
        SCNTransaction.setCompletionBlock {
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.3)
            
            material.emission.contents = UIColor.blackColor()
            material2.emission.contents = UIColor.blackColor()
            
            SCNTransaction.commit()
        }
        
        material.emission.contents = UIColor.redColor()
        material2.emission.contents = UIColor.redColor()
        
        SCNTransaction.commit()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if startButton.hidden == true{
            return true
        }else{
            return false
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        //print("contacted.....")

    }
    
    func colorIntToString(netHex:Int)->String{
        print("redInt = \(netHex >> 16);greenInt = \(netHex >> 8);blueInt = \(netHex)")
        
        let redInt = (netHex >> 16) & 0xff
        let greenInt = (netHex >> 8) & 0xff
        let blueInt = netHex & 0xff
        
        let hexString = String(format:"0x%X%X%X", redInt,greenInt,blueInt)
        print("hexString = \(hexString)")
        
        return hexString
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("x")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    func colorWithRGB(r:CGFloat, g:CGFloat,b:CGFloat)->UIColor{
        //print("redInt = \(r)")
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    

}
