//
//  memoViewController.swift
//  memo
//
//  Created by lxxeugene on 2023/05/01.
//

import UIKit

class MemoViewController: UIViewController {
    // MARK: - Nested Types
    /// 동일한 화면을 편집상태와 보기 모드로 변환
    private enum Mode {
        case edit, view
    }
    // MARK:- Properties
    // MARK: Type Properties
    /// 스토리보드에 구현해 둔 인스턴스를 코드를 통해 더 생성하기 위하여 스토리보드 ID를 활용
    static let storyboardID: String = "MemoViewController"
    
    // MARK: Privates
    /// 현재 화면의 작업상태
    var memo: Memo?
    
    private var mode: Mode = Mode.edit {
        // mode 변경에 따라 적절한 처리
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
    /// 수정 - 내비게이션 바 버튼
    private var editButton: UIBarButtonItem {
        let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit,
                                                      target: self,
                                                      action: #selector(touchUpEditButton(_:)))
        return button
    }
    /// 취소 - 내비게이션 바 버튼
    private var cancelButton: UIBarButtonItem {
        let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,                                                                                     target: self,
                                                      action: #selector(touchUpCancelButton(_:)))
        return button
    }
    /// 완료 - 내비게이션 바 버튼
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
    
    // MARK: - Methods
    // MARK: Privates
    /// 화면초기화
    private func initializeViews() {
        /// 이전화면에서 전달받은 memo가 있다면 그에 맞게 화면 초기화
        if let memo: Memo = self.memo {
            self.navigationItem.title = memo.title
            self.titleField.text = memo.title
            self.memoTextView.text = memo.memo
            self.dueDatePicker.date = memo.due
            self.mode = Mode.view
        }
    }
    // 간단한 얼럿을 보여줄 때 코드 중복을 줄이기위한 메서드
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
    // 수정버튼을 눌렀을 때
    @objc private func touchUpEditButton(_ sender: UIBarButtonItem) {
        self.mode = Mode.edit
    }
    // 취소버튼을 눌렀을 때
    @objc private func touchUpCancelButton(_ sender: UIBarButtonItem) {
        if self.memo == nil {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
         } else {
                self.initializeViews()
            
        }
    }
    // 완료버튼을 눌렀을 때
    @objc private func touchUpDoneButton(_ sender: UIBarButtonItem) {
        // memo 제목은 필수사항이므로 입력했는지 확인
        guard let title: String = self.titleField.text,
            title.isEmpty == false else {
                self.showSimpleAlert(message: "제목은 꼭 작성해야합니다",
                                     cancelHandler: { (action: UIAlertAction) in
                                        self.titleField.becomeFirstResponder()
            })
            return
        }
        
        // 새로운 memo todtjd
        let memo: Memo
        memo = Memo(title: title,
                    due: self.dueDatePicker.date,
                    memo: self.memoTextView.text,
                    shouldNotify: self.shouldNotifySwitch.isOn,
                    id: self.memo?.id ?? String(Date().timeIntervalSince1970))
        let isSuccess: Bool
        
        if self.memo == nil {
            // 새로 작성하기 위한 상태라면 저장을 완료하고 모달을 내려줌
            isSuccess = memo.save {
                self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        } else {
            // 수정상태라면 저장을 완료하고 화면을 보기모드로 전환
            isSuccess = memo.save(completion: {
                self.memo = memo
                self.mode = Mode.view
            })
        }
        // 저장에 실패하면 알림
        if isSuccess == false {
            self.showSimpleAlert(message: "저장 실패")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 텍스트 필드 delegate 설정
        self.titleField.delegate = self
        // 이전 화면에서 전달받은 memo가 없다면 새로운 작성화면 설정
        if self.memo == nil {
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.navigationItem.rightBarButtonItem = self.doneButton
        } else {
            self.navigationItem.rightBarButtonItem = self.editButton
        }
        // 화면 초기화
        self.initializeViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 수정 모드라면 텍스트 필드에 바로 입력할 수 있도록 키보드 보여줌
        if self.mode == Mode.edit {
            self.titleField.becomeFirstResponder()
        }
    }
}
/// 텍스트 필드 delegate 메서드 구현
extension MemoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationItem.title = textField.text
    }
}

