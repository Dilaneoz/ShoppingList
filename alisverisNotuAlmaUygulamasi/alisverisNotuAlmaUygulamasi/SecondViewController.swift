//
//  SecondViewController.swift
//  alisverisNotuAlmaUygulamasi
//
//  Created by Dilan Öztürk on 16.12.2022.
//

import UIKit
import CoreData

                                                          //kullanıcıyı galerisine yönlendirme
class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var kaydetButton: UIButton! // outlet seçildi kaydederken
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if secilenUrunIsmi != "" { // eğer seçilmiş ürün ismi boş değil ise (yani bir ürüne tıklandıysa) core data seçilen ürün bilgilerini gösterecek
            
            kaydetButton.isHidden = true // ürün bilgileri açıldığında kaydet butonunu gizliyor
            
            if let uuidString = secilenUrunUUID?.uuidString{ // uuid optionalı stringe çevirme
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                isimTextField.text = isim
                            }
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int{
                                fiyatTextField.text = String(fiyat)
                            }
                            if let beden = sonuc.value(forKey: "beden") as? String{
                                bedenTextField.text = beden
                            }
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data{
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                        }
                    }
                }catch{
                    print("hata var")
                }
            }
            
        }else{ // seçilmiş olan bir ürün değilse (yani artıya tıklandıysa) text fieldları boş gösterecek (artıya tıklanınca zaten boş gözükecek ama emin olmak için bu kod yazılıyor)
            kaydetButton.isHidden = false // artı tıklandığında kaydet butonunun gözükeceğinden emin olmak için
            kaydetButton.isEnabled = false // artı tıklandığında kaydet butonu gözükecek ama tıklanmayacak (görsel eklenene kadar)
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(gestureRecognizer)  //klavyeyi kapatma
        
        imageView.isUserInteractionEnabled = true   // galeriden görsel seçme
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func gorselSec(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {   // görsel seçmeyi bitir
        imageView.image = info[.originalImage] as? UIImage
        kaydetButton.isEnabled = true // görsel eklenince kaydet butonunun tıklanabilir olması için
        self.dismiss(animated: true)   // eski görseli kaldır
    }
    
    @objc func klavyeyiKapat (){
        view.endEditing(true)
    }
    
    @IBAction func kaydetTiklandi(_ sender: Any) { // core dataya verileri kaydetme
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        alisveris.setValue(isimTextField.text!, forKey: "isim")
        alisveris.setValue(bedenTextField.text!, forKey: "beden")
        
        if let fiyat = Int(fiyatTextField.text!){
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        alisveris.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
            print("kayıt edildi")
        } catch{
            print("hata var")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil) // veriler girilince ilk sayfa verileri çekicek
        self.navigationController?.popViewController(animated: true) // kaydete bastıktan sonra kullanıcıyı ilk sayfaya atma
        
    }
    
   
    
    
}
