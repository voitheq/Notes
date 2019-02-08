//
//  NoteDetailsViewController.swift
//  Notes
//
//  Created by Wojciech Karaś on 19/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

protocol NoteDetailsViewControllerDelegate: class {
    func noteDetailsVievControllerDidCancel(_ controller: NoteDetailsViewController)
    func noteDetailsViewController(_ controller: NoteDetailsViewController, didFinishEditing note: Note)
    func noteDetailsViewController(_ controller: NoteDetailsViewController, didFinishAdding note: Note)
}

class NoteDetailsViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var categoryButtonsBackgroundView: UIView!
    @IBOutlet weak var categoryButtonsBackgroundBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstCategoryButton: UIButton!
    
    private var categoryButtonsBackgroundBottomConstraintConstant: CGFloat?
    
    weak var delegate: NoteDetailsViewControllerDelegate?
    
    var noteToEdit: Note?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryButtonsBackgroundBottomConstraintConstant = categoryButtonsBackgroundBottomConstraint.constant
        
        if let noteToEdit = noteToEdit{
            title = "Edit Note"
            titleTextField.text = noteToEdit.title
            contentTextView.text = noteToEdit.content
            setBackgroundColor(to: UIColor(displayP3Red: noteToEdit.r, green: noteToEdit.g, blue: noteToEdit.b, alpha: noteToEdit.a))
        }else{
            title = "Add Note"
            if let backgroundColor = firstCategoryButton.backgroundColor {
                 setBackgroundColor(to: backgroundColor)
            }
        }
        
//        titleTextField.layer.borderColor = UIColor.black.cgColor
//        titleTextField.layer.borderWidth = 1
//        titleTextField.layer.cornerRadius = 5
        titleTextField.delegate = self
        titleTextField.becomeFirstResponder()
    
//        contentTextView.layer.borderColor = titleTextField.layer.borderColor
//        contentTextView.layer.borderWidth = titleTextField.layer.borderWidth
//        contentTextView.layer.cornerRadius = titleTextField.layer.cornerRadius
        contentTextView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        delegate?.noteDetailsVievControllerDidCancel(self)
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        if let noteToEdit = noteToEdit {
            setNote(noteToEdit)
            delegate?.noteDetailsViewController(self, didFinishEditing: noteToEdit)
        } else {
            let note = Note()
            setNote(note)
            delegate?.noteDetailsViewController(self, didFinishAdding: note)
        }
    }
    
    private func setNote(_ note: Note) {
        note.title = titleTextField.text
        note.content = contentTextView.text
        titleBackgroundView.backgroundColor?.getRed(&note.r, green: &note.g, blue: &note.b, alpha: &note.a)
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        if let backgroundColor = sender.backgroundColor {
            setBackgroundColor(to: backgroundColor)
        }
        setDoneButton(newTitle: nil)
    }
    
    private func setDoneButton(newTitle: String?) {
        if newTitle != nil {
            setDoneButtonWith(string1: newTitle, and: contentTextView.text)
        }else{
            setDoneButtonWith(string1: titleTextField.text, and: contentTextView.text)
        }
    }
    
    private func setDoneButtonWith(string1: String?, and string2: String?) {
        if let string1 = string1, let string2 = string2 {
            doneButton.isEnabled = !string1.isEmpty || !string2.isEmpty
        }
    }
    
    private func setBackgroundColor(to color: UIColor) {
        titleBackgroundView.backgroundColor = color
        contentBackgroundView.backgroundColor = color
        categoryButtonsBackgroundView.backgroundColor = color
    }
    
}

//MARK: - TextFieldDelegateMethods
extension NoteDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldTitle = textField.text {
            if let stringRange = Range(range, in: oldTitle){
                let newTitle = oldTitle.replacingCharacters(in: stringRange, with: string)
                setDoneButton(newTitle: newTitle)
            }
        }
        return true
    }
}

//MARK: - TextViewDelegateMethods
extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        setDoneButton(newTitle: nil)
    }
}

//MARK: - Keyboard Methods
extension NoteDetailsViewController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                    if let duration = animationDuration as? TimeInterval {
                        self.categoryButtonsBackgroundBottomConstraint.constant = categoryButtonsBackgroundBottomConstraintConstant! + keyboardFrameEnd.height
                        UIView.animate(withDuration: duration) {
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                if let duration = animationDuration as? TimeInterval {
                    self.categoryButtonsBackgroundBottomConstraint.constant = categoryButtonsBackgroundBottomConstraintConstant!
                    UIView.animate(withDuration: duration) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
}
