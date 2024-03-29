//
//  EditPostViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import SCLAlertView
import Kingfisher
import YPImagePicker
import DynamicBlurView
import GSImageViewerController
import Smile
import Emoji

class EditPostViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var view_picturelist: UIView!
    @IBOutlet weak var image_scrollview: UIScrollView!
    @IBOutlet weak var pagecontroll: UIPageControl!
    @IBOutlet weak var view_postname: UIView!
    @IBOutlet weak var edt_postname: UITextField!
    @IBOutlet weak var view_category: UIView!
    @IBOutlet weak var edt_category: UITextField!
    @IBOutlet weak var view_desc: UIView!
    @IBOutlet weak var edt_desc: UITextView!
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var view_notify: UIView!
    @IBOutlet weak var edt_notify: UITextField!
    @IBOutlet weak var lbl_newfiles: UILabel!
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var scheduleBox: UITextField!
    @IBOutlet weak var scheduleNoteBox: UILabel!
    
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var linkViewH: NSLayoutConstraint!
    
    var blurView:DynamicBlurView!
        
    var sliderImagesArray = NSMutableArray()
    var sliderImageFilesArray = NSMutableArray()
        
    var picker:YPImagePicker!
    let thePicker = UIPickerView()
        
    var categories = [String]()
    
    var selectedTime:String = ""
    var postPictures = [PostPicture]()
    
    @IBOutlet weak var xxxTop: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
            
        gEditPostViewController = self
        
        scheduleNoteBox.visibility = .gone
        xxxTop.constant = 0
        scheduleView.visibility = .gone
            
        gSelectedUsers.removeAll()
        
        lbl_title.text = "edit_post".localized().uppercased()
            
        setRoundShadowView(view: view_postname, corner: view_postname.frame.height / 2)
        setRoundShadowView(view: view_category, corner: view_category.frame.height / 2)
        setRoundShadowView(view: view_notify, corner: view_notify.frame.height / 2)
        setRoundShadowView(view: view_desc, corner: 5)
        setRoundShadowButton(button: btn_submit, corner: btn_submit.frame.height / 2)
        setRoundShadowView(view: scheduleView, corner: scheduleView.frame.height / 2)
            
        edt_desc.delegate = self
        
        edt_postname.attributedPlaceholder = NSAttributedString(
            string: "enter_title".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        edt_category.attributedPlaceholder = NSAttributedString(
            string: "choose_category".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        edt_notify.attributedPlaceholder = NSAttributedString(
            string: "select_members_notified".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        scheduleBox.attributedPlaceholder = NSAttributedString(
            string: "select_scheduled_time".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        btn_submit.setTitle("submit".localized(), for: .normal)
        
        edt_desc.setPlaceholder(string: "write_something_".localized())
        edt_desc.textContainerInset = UIEdgeInsets(top: edt_desc.textContainerInset.top, left: 8, bottom: edt_desc.textContainerInset.bottom, right: edt_desc.textContainerInset.right)
            
        image_scrollview.delegate = self
            
        image_scrollview.layer.cornerRadius = 8
        image_scrollview.layer.masksToBounds = true
            
        pagecontroll.numberOfPages = 0
        
        lbl_newfiles.isHidden = true
            
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "gallery".localized()
        config.wordings.cameraTitle = "camera".localized()
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
            
        thePicker.delegate = self
        edt_category.inputView = thePicker
        thePicker.backgroundColor = UIColor.white
        createToolbar()
        
        if gPost.sch_status.count == 0 {
            self.scheduleView.visibility = .gone
            self.scheduleNoteBox.text = "schedule_activated".localized() + " (" + gPost.scheduled_time.convertToDateFormate(current: "yyyy-M-d-H-m", convertTo: "MM/dd/yyyy HH:mm a")
        }else {
            scheduleNoteBox.text = "edit_scheduled_time".localized()
        }
        
        if gPost.scheduled_time.count > 0 {
            scheduleBox.text = gPost.scheduled_time.convertToDateFormate(current: "yyyy-M-d-H-m", convertTo: "MM/dd/yyyy HH:mm a")
            selectedTime = gPost.scheduled_time
        }
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openUsersPage(_:)))
        view_notify.addGestureRecognizer(tap)
        
        edt_postname.text = self.processingEmoji(str:gPost.title)
        edt_category.text = gPost.category
        edt_desc.text = self.processingEmoji(str:gPost.content)
        edt_desc.checkPlaceholder()
        
        linkpreviews = gPost.previews
        if gPost.previews.count > 0 {
            linkView.visibility = .visible
            stackView.arrangedSubviews
                .filter({ $0 is LinkView})
                .forEach({ $0.removeFromSuperview() })
            var i = 0
            for prev in gPost.previews {
                i += 1
                let linkView = (Bundle.main.loadNibNamed("LinkView", owner: self, options: nil))?[0] as! LinkView
                if prev.image_url.count > 0{
                    linkView.linkImageBox.visibilityh = .visible
                    loadPicture(imageView: linkView.linkImageBox, url: URL(string: prev.image_url)!)
                }else {
                    linkView.linkImageBox.visibilityh = .gone
                }
                linkView.linkTitleBox.text = prev.title
                if prev.icon_url.count > 0{
                    linkView.linkiconBox.visibilityh = .visible
                    loadPicture(imageView: linkView.linkiconBox, url: URL(string: prev.icon_url)!)
                }else {
                    linkView.linkiconBox.visibilityh = .gone
                }
                linkView.linkUrlBox.text = prev.site_url
                linkView.frame.size.height = 60
                linkView.linkImageW.constant = CGFloat(linkView.frame.size.height * 1.2)
                linkView.tag = i
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedLinkPreview(gesture:)))
                linkView.addGestureRecognizer(tap)
                stackView.addArrangedSubview(linkView)
                linkView.layoutIfNeeded()
            }
            linkViewH.constant = CGFloat(60 * gPost.previews.count)
        }else {
            linkView.visibility = .gone
        }
        linkView.sizeToFit()
        
        self.getPostPictures(post: gPost)
        
        self.getPostCategories()
            
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == edt_desc {
            print("Lost focus")
            getPostLinks(desc: textView.text)
        }
        return true
    }
        
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        textView.checkPlaceholder()
    }
        
    @IBAction func delPicture(_ sender: Any) {
        if self.sliderImagesArray.count > 0{
            if self.postPictures.count > self.pagecontroll.currentPage {
                let picture_id = self.postPictures[self.pagecontroll.currentPage].idx
                let alert = UIAlertController(title: "delete".localized(), message: "sure_delete_picture".localized(), preferredStyle: .alert)
                let noAction = UIAlertAction(title: "no".localized(), style: .cancel, handler: {
                    (action : UIAlertAction!) -> Void in })
                let yesAction = UIAlertAction(title: "yes".localized(), style: .destructive, handler: { alert -> Void in
                    self.deletePostPicture(picture_id: picture_id, post_id: gPost.idx)
                })
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                
                self.present(alert, animated: true, completion: nil)
            }else{
                self.sliderImagesArray.remove(self.sliderImagesArray[self.pagecontroll.currentPage])
                print("Current Page: \(self.pagecontroll.currentPage)")
                print("Images Count: \(self.sliderImagesArray.count)")
                if self.sliderImageFilesArray.count > 0 && self.pagecontroll.currentPage >= self.postPictures.count{
                    self.sliderImageFilesArray.remove(self.sliderImageFilesArray[self.pagecontroll.currentPage - self.postPictures.count])
                }
                self.loadPictures(imageOperation: true)
            }
        }
    }
        
    func loadPictures(imageOperation:Bool){
            
        print("Files: \(sliderImageFilesArray.count)")
        if sliderImageFilesArray.count > 0{
            lbl_newfiles.isHidden = false
            lbl_newfiles.text = "new_".localized() + ": " + String(sliderImageFilesArray.count)
        }else{
            lbl_newfiles.isHidden = true
        }
        for i in 0..<sliderImagesArray.count {
            var imageView : UIImageView
            let xOrigin = self.image_scrollview.frame.width * CGFloat(i)
            imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: self.image_scrollview.frame.width, height: self.image_scrollview.frame.height))
            imageView.isUserInteractionEnabled = true
        //  let urlStr = sliderImagesArray.object(at: i)
        //  print(image_scrollview,imageView, urlStr)
        //
        //  let url = URL(string: sliderImagesArray[i] as! String)
        //  let data = try? Data(contentsOf: url!)
        //  let image = UIImage(data: data!)
            imageView.image = (sliderImagesArray.object(at: i) as! UIImage)
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
            imageView.tag = i
            imageView.addGestureRecognizer(tap)
            
            self.image_scrollview.addSubview(imageView)
        }
                
        self.image_scrollview.isPagingEnabled = true
        self.image_scrollview.bounces = false
        self.image_scrollview.showsVerticalScrollIndicator = false
        self.image_scrollview.showsHorizontalScrollIndicator = false
        self.image_scrollview.contentSize = CGSize(width: self.image_scrollview.frame.size.width * CGFloat(sliderImagesArray.count), height: self.image_scrollview.frame.size.height)
        self.pagecontroll.addTarget(self, action: #selector(self.changePage(_ :)), for: UIControl.Event.valueChanged)
        
        self.pagecontroll.numberOfPages = sliderImagesArray.count
        
        var x = CGFloat(self.pagecontroll.numberOfPages - 1) * self.image_scrollview.frame.size.width
        if !imageOperation{
            x = 0
            self.image_scrollview.setContentOffset(CGPoint(x: x, y :0), animated: true)
            self.pagecontroll.currentPage = 0
        }else{
            self.image_scrollview.setContentOffset(CGPoint(x: x, y :0), animated: true)
            self.pagecontroll.currentPage = self.pagecontroll.numberOfPages - 1
        }
    }
            
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "appicon.jpg"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
        
    @IBAction func addPicture(_ sender: Any) {
        self.pickPostPicture()
    }
        
    func pickPostPicture(){
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.sliderImagesArray.add(photo.image)
                let imageFile = photo.image.jpegData(compressionQuality: 0.8)
                self.sliderImageFilesArray.add(imageFile!)
                self.loadPictures(imageOperation: true)
            }
            picker!.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
        
    @IBAction func changePage(_ sender: Any) {
        let x = CGFloat(pagecontroll.currentPage) * image_scrollview.frame.size.width
        image_scrollview.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            
        let pageNumber = round(image_scrollview.contentOffset.x / image_scrollview.frame.size.width)
        pagecontroll.currentPage = Int(pageNumber)
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            edt_category.text = categories[row]
        }else{
            edt_category.text = ""
        }
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
        
    @objc func closePickerView()
    {
        view.endEditing(true)
    }
        
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
        
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
        var label:UILabel
            
        if let v = view as? UILabel{
            label = v
        }
        else{
            label = UILabel()
        }
            
        if row == 0{
            label.textColor = UIColor.systemOrange
        }else{
            label.textColor = UIColor.black
        }
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 20)
        label.text = self.categories[row]
            
        return label
    }
        
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = primaryDarkColor
        toolbar.backgroundColor = UIColor.lightGray
        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(SignupViewController.closePickerView))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        edt_category.inputAccessoryView = toolbar
    }
        
    @objc func openUsersPage(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotifiedUsersViewController")
        self.present(vc, animated: true, completion: nil)
    }
        
        
    @IBAction func createNewPost(_ sender: Any) {
            
        if self.edt_postname.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.showToast(msg: "enter_title".localized())
            return
        }
            
        if self.edt_category.text == ""{
            self.showToast(msg: "choose_category".localized())
            return
        }
            
        if self.edt_desc.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.showToast(msg: "write_about_post".localized())
            return
        }
            
        var selectedUsersJsonStr = ""
        if gSelectedUsers.count > 0{
            selectedUsersJsonStr = createSelUsersJsonString()
        }
            
        let parameters: [String:Any] = [
            "post_id" : String(gPost.idx),
            "member_id" : String(thisUser.idx),
            "title" : self.edt_postname.text?.encodeEmoji as Any,
            "category" : self.edt_category.text as Any,
            "content" : self.edt_desc.text.encodeEmoji as Any,
            "pic_count" : String(self.sliderImageFilesArray.count) as Any,
            "members" : selectedUsersJsonStr,
            "scheduled_time": selectedTime,
        ]
            
        let ImageArray:NSMutableArray = []
        for image in self.sliderImageFilesArray{
            ImageArray.add(image as! Data)
        }
            
        self.showLoadingView()
        APIs().postImageArrayRequestWithURL(withUrl: ReqConst.SERVER_URL + "createpost", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Post Response: \(response)")
            if isSuccess == true{
                let result = response["result_code"] as Any
                print("Result: \(result)")
                if result as! String == "0"{
                    if gRecentViewController == gPostViewController{
                        gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                    }else if gRecentViewController == gMyPostViewController{
                        gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }else if result as! String == "1"{
                    self.showToast(msg: "account_not_exist".localized())
                    self.logout()
                }else{
                    self.showToast(msg: "something_wrong".localized())
                    if gRecentViewController == gPostViewController{
                        gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                    }else if gRecentViewController == gMyPostViewController{
                        gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                self.showToast(msg: "something_wrong".localized())
//                let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
//                self.showToast(msg: "Issue: \n" + message)
            }
        }
    }
        
    func createSelUsersJsonString() -> String{
        var jsonArray = [Any]()
        for user in gSelectedUsers{
            let jsonObject: [String: String] = [
                "member_id": String(user.idx),
                "name": String(user.name),
            ]
                
            jsonArray.append(jsonObject)
        }
            
        let jsonItemsObj:[String: Any] = [
            "members":jsonArray
        ]
            
        let jsonStr = self.stringify(json: jsonItemsObj)
        return jsonStr
            
    }
        
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
            
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    
    func getPostPictures(post: Post){
        self.showLoadingView()
        APIs.getPostPictures(post_id: post.idx,handleCallback: {
            pictures, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.postPictures = pictures!
                self.sliderImagesArray.removeAllObjects()
                    
                for pic in pictures! {
                    let image = self.getImageFromURL(url: URL(string: pic.image_url)!)
                    self.sliderImagesArray.add(image)
                }
                
                self.loadPictures(imageOperation: false)
                    
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
                self.image_scrollview.addGestureRecognizer(tap)
            }
        })
            
    }
    
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let imageView:UIImageView = (sender?.view as? UIImageView)!
        let index = imageView.tag
        let image = self.sliderImagesArray[index]
            
        let imageInfo   = GSImageInfo(image: image as! UIImage , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: imageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }
    
    func deletePostPicture(picture_id: Int64, post_id:Int64){
        self.showLoadingView()
        APIs.deletePostPicture(picture_id: picture_id, post_id: post_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.sliderImagesArray.remove(self.sliderImagesArray[self.pagecontroll.currentPage])
                self.loadPictures(imageOperation: true)
                if gRecentViewController == gPostViewController{
                    gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                }else if gRecentViewController == gMyPostViewController{
                    gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                }
            }else if result_code == "1"{
                self.showToast(msg: "post_not_exist".localized())
                self.dismiss(animated: true, completion: nil)
                if gRecentViewController == gPostViewController{
                    gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                }else if gRecentViewController == gMyPostViewController{
                    gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                }
            }else {
                self.showToast(msg:"something_wrong".localized())
            }
        })
    }
    
    
    @available(iOS 13.4, *)
    @IBAction func openDateTimePicker(_ sender: Any) {
        let pick:PresentedViewController = PresentedViewController()
        pick.style = DefaultStyle()
        pick.style.titleString = "pick_date_time".localized()
        let lang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
//        if lang == "es" { pick.picker.locale = .init(identifier: "es_ES") }
        pick.block = { [weak self] (date) in
            self?.scheduleBox.text = date?.convertToDateFormate(current: "yyyy/MM/dd HH:mm:ss", convertTo: "MM/dd/yyyy HH:mm a")
            self?.selectedTime = date!.convertToDateFormate(current: "yyyy/MM/dd HH:mm:ss", convertTo: "yyyy-M-d-H-m")
            print("selected date: \(String(describing: date))")
        }
        self.present(pick, animated: true, completion: nil)
    }
    
    var linkpreviews = [PostPreview]()
    func getPostLinks(desc:String) {
        if desc.count == 0 || !desc.contains("http") { return }
        showLoadingView()
        linkView.visibility = .gone
        self.stackView.arrangedSubviews
            .filter({ $0 is LinkView})
            .forEach({ $0.removeFromSuperview() })
        APIs.getPostLinks(content: desc, handleCallback: {
            previews, result in
            self.dismissLoadingView()
            self.linkpreviews = previews!
            if previews!.count > 0 {
                self.linkView.visibility = .visible
                var i = 0
                for prev in previews! {
                    i += 1
                    let linkView = (Bundle.main.loadNibNamed("LinkView", owner: self, options: nil))?[0] as! LinkView
                    if prev.image_url.count > 0{
                        linkView.linkImageBox.visibilityh = .visible
                        self.loadPicture(imageView: linkView.linkImageBox, url: URL(string: prev.image_url)!)
                    }else {
                        linkView.linkImageBox.visibilityh = .gone
                    }
                    linkView.linkTitleBox.text = prev.title
                    if prev.icon_url.count > 0{
                        linkView.linkiconBox.visibilityh = .visible
                        self.loadPicture(imageView: linkView.linkiconBox, url: URL(string: prev.icon_url)!)
                    }else {
                        linkView.linkiconBox.visibilityh = .gone
                    }
                    linkView.linkUrlBox.text = prev.site_url
                    linkView.frame.size.height = 60
                    linkView.linkImageW.constant = CGFloat(linkView.frame.size.height * 1.2)
                    linkView.tag = i
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedLinkPreview(gesture:)))
                    linkView.addGestureRecognizer(tap)
                    self.stackView.addArrangedSubview(linkView)
                    linkView.layoutIfNeeded()
                }
                self.linkViewH.constant = CGFloat(60 * previews!.count)
            }
            self.linkView.sizeToFit()
                          
        })
    }
    
    @objc func tappedLinkPreview(gesture:UITapGestureRecognizer) {
        let linkprev = linkpreviews[gesture.view!.tag - 1]
        if let url = URL(string: linkprev.site_url) {
            UIApplication.shared.open(url)
        }
    }
    
    func getPostCategories() {
        self.showLoadingView()
        APIs.getpostcategories(admin_id: thisUser.admin_id, handleCallback: {
            us_categories, es_categories, result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                let lang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
                if lang == "es" {
                    self.categories = es_categories!.split(separator: ",").map { String($0) }
                }else {
                    self.categories = us_categories!.split(separator: ",").map { String($0) }
                }
                self.categories.insert("- " + "choose_category".localized() + " -", at: 0)
                self.thePicker.selectRow(self.categories.firstIndex(of: gPost.category)!, inComponent: 0, animated: false)
            }
            
        })
    }
    
        
}
