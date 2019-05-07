//
//  ActiveViewController.swift
//  Yep
//
//  Created by zzzl on 2018/9/22.
//  Copyright © 2018年 Sinbane Inc. All rights reserved.
//

import UIKit

class ActiveViewController: BaseViewController {
    @IBOutlet weak var studentIdTF: BorderTextField!
    @IBOutlet weak var sexTF: BorderTextField!
    @IBOutlet weak var sexSgm: UISegmentedControl!
    @IBOutlet weak var brithdayTF: BorderTextField!
    @IBOutlet weak var rootYearTF: BorderTextField!
    @IBOutlet weak var addressTF: BorderTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sexTF.text = "女生"
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

extension ActiveViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == sexTF {
            return false
        }
        
        if textField == brithdayTF {
            clickToDatePicker("选择您的生日", tf: brithdayTF)
            return false
        }
        
        if textField == rootYearTF {
            clickToDatePicker("选择您的入学日期", tf: rootYearTF)
            return false
        }
        return true
    }
}

extension ActiveViewController {
    func clickToDatePicker(_ title: String, tf: UITextField) -> Void {
        let datePicker = DatePickerDialog(textColor: .white,
                                          buttonColor: .white,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        datePicker.show(title,
                        doneButtonTitle: "确定",
                        cancelButtonTitle: "取消",
                        datePickerMode: .date) { (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy/dd/MM"
                                tf.text = formatter.string(from: dt)
                            }
        }
    }
    
    @IBAction func clickToSex(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sexTF.text = "女生"
        } else {
            sexTF.text = "男生";
        }
    }
}
