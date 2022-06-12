//
//  ViewController.swift
//  CurvedText
//
//  Created by Rishabh Ganesh on 5/30/22.
//

import UIKit

//take two overlapping images and put them together
extension UIImage
{
    func overlayWith(image: UIImage, posX: CGFloat, posY: CGFloat) -> UIImage
    {
        let newWidth = posX < 0 ? abs(posX) + max(self.size.width, image.size.width) :
            size.width < posX + image.size.width ? posX + image.size.width : size.width
        let newHeight = posY < 0 ? abs(posY) + max(size.height, image.size.height) :
            size.height < posY + image.size.height ? posY + image.size.height : size.height
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let originalPoint = CGPoint(x: posX < 0 ? abs(posX) : 0, y: posY < 0 ? abs(posY) : 0)
        self.draw(in: CGRect(origin: originalPoint, size: self.size))
        let overLayPoint = CGPoint(x: posX < 0 ? 0 : posX, y: posY < 0 ? 0 : posY)
        image.draw(in: CGRect(origin: overLayPoint, size: image.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }

}
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var circleView: UIImageView!
    @IBOutlet weak var stampView: UIImageView!
    @IBOutlet weak var textView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = testRound()
        
        stampView.image = mergeImages(imageView: imageView, w: 400, h: 400)
        //UIImageWriteToSavedPhotosAlbum(stampView.image!, nil, nil, nil)
        
        
    }
    
    
    //put two images together in an imageview
    func mergeImages(imageView: UIImageView, w: Double, h: Double) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0)
        //UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 0.0)
        imageView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func centerArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, theta: CGFloat, color: UIColor, font: UIFont, clockwise: Bool)
    {
        // *******************************************************
        // This draws the String str around an arc of radius r,
        // with the text centred at polar angle theta
        // *******************************************************

        let characters: [String] = str.map { String($0) } // An array of single character strings, each character in str
        let l = characters.count
        let attributes = [NSAttributedString.Key.font: font]

        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string

        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l
        {
            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: r)]
            totalArc += arcs[i]
        }

        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection: CGFloat = clockwise ? -.pi / 2 : .pi / 2

        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        var thetaI = theta - direction * totalArc / 2

        for i in 0 ..< l
        {
            thetaI += direction * arcs[i] / 2
            // Call centerText with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            centre(text: characters[i], context: context, radius: r, theta: thetaI, colour: color, font: font, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
    }

    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat
    {
        return 2 * asin(chord / (2 * radius))
    }

    func centre(text str: String, context: CGContext, radius r: CGFloat, theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat)
    {
        // *******************************************************
        // This draws the String str centred at the position
        // specified by the polar coordinates (r, theta)
        // i.e. the x= r * cos(theta) y= r * sin(theta)
        // and rotated by the angle slantAngle
        // *******************************************************

        // Set the text attributes
        let attributes = [NSAttributedString.Key.foregroundColor: c, NSAttributedString.Key.font: font]
        //let attributes = [NSForegroundColorAttributeName: c, NSFontAttributeName: font]
        // Save the context
        context.saveGState()
        // Undo the inversion of the Y-axis (or the text goes backwards!)
        context.scaleBy(x: 1, y: -1)
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }

    //describe context size then test curved text
    var size = CGSize(width: 200, height: 200)
    func testRound()->UIImage
    {
        //if the bool parameter in below function is true, black background, no no
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        // *******************************************************************
        // Scale & translate the context to have 0,0
        // at the centre of the screen maths convention
        // Obviously change your origin to suit...
        // *******************************************************************
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.scaleBy(x: 1, y: -1)
        
        //let rect = CGRect(x: -90, y: -100, width: 180, height: 180)
        //context.addEllipse(in: rect)
        //context.drawPath(using: .fill)
        centerArcPerpendicular(text: "Everglades National Park", context: context, radius: 90, theta: .pi/2, color: UIColor.purple, font: UIFont.systemFont(ofSize: 16), clockwise: true)
        centerArcPerpendicular(text: "Royal Palm", context: context, radius: 90, theta: CGFloat(3*Double.pi/2), color: UIColor.purple, font: UIFont.systemFont(ofSize: 16), clockwise: false)
        centre(text: "INSERT DATE", context: context, radius: 0, theta: 0 , colour: UIColor.purple, font: UIFont.systemFont(ofSize: 16), slantAngle: 0)


        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

