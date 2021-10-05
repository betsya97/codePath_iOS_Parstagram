//
//  CameraViewController.swift
//  parstagram
//
//  Created by Betsy Avila on 10/4/21.
//

import UIKit
import AlamofireImage
//create objects onto table
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    @IBAction func submitButton(_ sender: Any) {
        //new object of PF type
        //Parse can create a table for you on the fly
        //parse can read the created schema and create tables according to it
        let post = PFObject(className: "Posts") //like a dictionary put arbitrary keys and numbers
        post["caption"] = commentField.text
        post["author"] = PFUser.current()! //current person
        
        //grab imagedata binary
        let imageData = imageView.image!.pngData() //saved as png
        //let file = PFFileObject(data: imageData!) //binary object
        let file = PFFileObject(name: "image.png", data: imageData!)
        post["image"] = file //column will have the file url containing the image
        
        post.saveInBackground { (success, erorr) in
            if success{
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            }else{
                print("eror!")
            }
        }
    }
    
    //after selecting tap gesture recognition element on placeholder photo, ctrl+drag to make action onCameraButton
    //mark checkbox containing "user interaction enabled" inside properties of image
    @IBAction func onCameraButton(_ sender: Any) {
        //to launch camera
        let picker = UIImagePickerController()
        picker.delegate = self //call funciton that has photo ready to go
        picker.allowsEditing = true
        
        //need to check if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
            
        }else{
            picker.sourceType = .photoLibrary //if camera is not available, use photo library
        }
        present(picker, animated: true, completion: nil)//upon tapping the camera button, show the photo album
    }
    
    //for the image to show on the imageView
    //import AlamofireImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage //access dictionary
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
