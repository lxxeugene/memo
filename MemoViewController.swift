//
//  memoViewController.swift
//  memo
//
//  Created by lxxeugene on 2023/05/01.
//

import UIKit

class MemoViewController: UIViewController {
    
    private enum Mode {
        case edit, view
    }
    static let storyboardID: String = "MemoViewController"
        
    var memo: Memo?
    
    private var mode: Mode = Mode.edit {
        
        didSet {
            self.titleField.isUserInteractionEnabled = (mode == .edit)
            self.memoTextView.isEditable = (mode == .edit)
            self.dueDatePicker.isUserInteractionEnabled = (mode == .edit)
            self.shouldNotifySwitch.isEnabled = ( mode == .edit)
            
            if mode == Mode.edit {
                if memo == nil {
                    self.navigationItem.leftBarButtonItems = [self.cancelButton]
                } else {
                    self.navigationItem.rightBarButtonItems = [self.doneButton, self.cancelButton]
                }
            } else {
                    self.navigationItem.rightBarButtonItems = [self.editButton]
            }
        }
    }
    
    private var editButton: UIBarButtonItem {
        let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit,
                                                      target: self,
                                                      action: #selector(touchUpEditButton(_:)))
        return button
    }
    private var cancelButton: UIBarButtonItem {
        let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,                                                                                     target: self,
                                                      action: #selector(touchUpCancelButton(_:)))
        return button
    }
    private var doneButton: UIBarButtonItem {
        let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                      target: self,
                                                      action: #selector(touchUpDoneButton(_:)))
        return button
    }
    

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet var label: UIStackView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet var text: UIStackView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet var date: UIStackView!
    @IBOutlet weak var shouldNotifySwitch: UISwitch!
    @IBOutlet var alram: UIStackView!
    
    
    private func initializeViews() {
        
        if let memo: Memo = self.memo {
            self.navigationItem.title = memo.title
            self.titleField.text = memo.title
            self.memoTextView.text = memo.memo
            self.dueDatePicker.date = memo.due
            self.mode = Mode.view
        }
    }
    
    private func showSimpleAlert(message: String,
                                 cancelTitle: String = "확인",
                                 cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert: UIAlertController = UIAlertController(title: "알림",
                                                         message: message,
                                                         preferredStyle: UIAlertController.Style.alert)
        let action: UIAlertAction = UIAlertAction(title: cancelTitle,
                                                  style: UIAlertAction.Style.cancel,
                                                  handler: cancelHandler)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func touchUpEditButton(_ sender: UIBarButtonItem) {
        self.mode = Mode.edit
    }
    @objc private func touchUpCancelButton(_ sender: UIBarButtonItem) {
        if self.memo == nil {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
         } else {
                self.initializeViews()
            
        }
    }
    @objc private func touchUpDoneButton(_ sender: UIBarButtonItem) {
        
        guard let title: String = self.titleField.text,
            title.isEmpty == false else {
                self.showSimpleAlert(message: "제목은 꼭 작성해야합니다",
                                     cancelHandler: { (action: UIAlertAction) in
                                        self.titleField.becomeFirstResponder()
            })
            return
        }
        
        
        let memo: Memo
        memo = Memo(title: title,
                    due: self.dueDatePicker.date,
                    memo: self.memoTextView.text,
                    shouldNotify: self.shouldNotifySwitch.isOn,
                    id: self.memo?.id ?? String(Date().timeIntervalSince1970))
        let isSuccess: Bool
        
        if self.memo == nil {
            isSuccess = memo.save {
                self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        } else {
            isSuccess = memo.save(completion: {
                self.memo = memo
                self.mode = Mode.view
            })
        }
        
        if isSuccess == false {
            self.showSimpleAlert(message: "저장 실패")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleField.delegate = self
        
        if self.memo == nil {
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.navigationItem.rightBarButtonItem = self.doneButton
        } else {
            self.navigationItem.rightBarButtonItem = self.editButton
        }
        self.initializeViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.mode == Mode.edit {
            self.titleField.becomeFirstResponder()
        }
    }
}

extension MemoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationItem.title = textField.text
    }
}

