//
//  ViewController.swift
//  emojiTornado
//
//  Created by iGuest on 5/11/17.
//  Copyright © 2017 iGuest. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let emojis = ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "☺️", "😊", "😇" ]
    
    // Dedicated to rendering text, renders label text
    let textLayer = CATextLayer()
    
    // font size works well with core animation
    let fontSize: CGFloat = 24.0
    
    // Color doesn't matter since we're rending emojies
    let fontColor = UIColor(white: 0.1, alpha: 1.0)
    
    // Emitter layer -> for particles / animations?
    let emitterLayer = CAEmitterLayer()
    
    // Constants for these values
    let fallRate: CGFloat = 72
    let spinRange: CGFloat = 0
    let birthRate: Float = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.masksToBounds = true
        
        // utility layer -> to render things, we'll call it
        configureTextLayer()
        
        configureEmitterLayer()
        
        beginRotatingIn3D()
    }
    
    // UI cycle method
    override func viewDidLayoutSubviews() {
        // set emitterLayer to full screen
        emitterLayer.frame = view.bounds
        // Move up by half the screen
        let paddingAboveScreen = view.bounds.height
        emitterLayer.emitterPosition = CGPoint(x : emitterLayer.frame.midX, y: -paddingAboveScreen / 2)
        emitterLayer.emitterSize = CGSize(width: emitterLayer.frame.width, height: paddingAboveScreen)
    }
    
    
    // MARK: Raining Emojies
    
    func configureTextLayer() {
        textLayer.contentsScale = UIScreen.main.scale
        
        textLayer.fontSize = fontSize
        
        textLayer.alignmentMode = kCAAlignmentCenter
        
        textLayer.backgroundColor = UIColor.clear.cgColor
        
        textLayer.foregroundColor = fontColor.cgColor
        
        textLayer.frame = CGRect(x : 0, y : 0, width: fontSize * 2, height: fontSize * 2)
    }
    
    // MARK: Emitter Layer
    
    func configureEmitterLayer() {
        emitterLayer.contentsScale = UIScreen.main.scale
        // volume ?
        emitterLayer.emitterMode = kCAEmitterLayerVolume
        emitterLayer.emitterShape = kCAEmitterLayerRectangle
        
        emitterLayer.preservesDepth = true
        
//        emitterLayer.backgroundColor = UIColor.red.cgColor
//        emitterLayer.frame = CGRect(x : 0, y : 0, width: 50, height: 50)
        
        // like table view cell in the sense that they are reused
        emitterLayer.emitterCells = generateEmitterCells()
        
        // Grab view, add our emitter layer
        view.layer.addSublayer(emitterLayer)
    }
    
    func generateEmitterCells() -> [CAEmitterCell] {
        var emitterCells = Array<CAEmitterCell>()
        
        for emoji in self.emojis {
            let emitterCell = emitterCellWith(text: emoji)
            emitterCells.append(emitterCell)
        }
        
        return emitterCells
    }
    
    func emitterCellWith(text:String) -> CAEmitterCell {
        let emitterCell = CAEmitterCell()
        
        // gonna be a bitmap
        emitterCell.contents = cgImageFrom(text: text)
        emitterCell.contentsScale = UIScreen.main.scale
        
        // set birth rate (particles)
        emitterCell.birthRate = birthRate
        // set lifetime (5 seconds)
        emitterCell.lifetime = Float(view.bounds.height * 2 / fallRate) // calculate fall time
        
        emitterCell.emissionLongitude = CGFloat.pi * 0.5
        // give some sideways motion
        emitterCell.emissionRange = CGFloat.pi * 0.25
        
        emitterCell.velocity = fallRate
        
        emitterCell.spinRange = spinRange
        
        return emitterCell
    }
    
    func cgImageFrom(text:String) -> CGImage? {
        textLayer.string = text
        
        // for drawing -> like drawing panel
        UIGraphicsBeginImageContextWithOptions(textLayer.frame.size, false, 0.0) // Scale 0.0 = use scale of device
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        // tell text layer to render
        textLayer.render(in: context)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        // tell to stop -> Hey I'm done you can dump this context
        UIGraphicsEndImageContext()
        
        return renderedImage?.cgImage
    }

    func beginRotatingIn3D() {
        // complex matrix stuff
        // describes distance from camera
        view.layer.sublayerTransform.m34 = 1 / 500.0
        let rotationAnimation = infiniteRotatingAnimation()
        // key to look up animation
        emitterLayer.add(rotationAnimation, forKey: "anything")
    }
    
    func infiniteRotatingAnimation() -> CABasicAnimation {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.toValue = 4 * Double.pi
        rotation.duration = 10
        rotation.isCumulative = true
        rotation.repeatCount = HUGE
        return rotation
    }

}

