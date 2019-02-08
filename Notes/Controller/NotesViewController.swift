//
//  ViewController.swift
//  Notes
//
//  Created by Wojciech Karaś on 19/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    
    private var notes = [Note]()
    
    lazy var dataFilePath: URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            editDoneButton.title = "Edit"
            tableView.isEditing = false
        }else{
            editDoneButton.title = "Done"
            tableView.isEditing = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNote" {
            if let noteDetailsViewController = segue.destination as? NoteDetailsViewController {
                noteDetailsViewController.delegate = self
            }
        }else if segue.identifier == "EditNote" {
            if let noteDetailsViewController = segue.destination as? NoteDetailsViewController {
                if let cell = sender as? UITableViewCell{
                    if let indexPath = tableView.indexPath(for: cell){
                        noteDetailsViewController.noteToEdit = notes[indexPath.row]
                        noteDetailsViewController.delegate = self
                    }
                }
            }
        }
    }
    
    private func saveData(){
        if let dataFilePath = dataFilePath {
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(notes)
                try data.write(to: dataFilePath)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadData(){
        if let dataFilePath = dataFilePath {
            do {
                let data = try Data(contentsOf: dataFilePath)
                let decoder = PropertyListDecoder()
                notes = try decoder.decode([Note].self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - TableViewMethods
extension NotesViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        setCell(cell: cell, with: notes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "EditNote", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        notes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
        saveData()
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedNote = notes[sourceIndexPath.row]
        notes.remove(at: sourceIndexPath.row)
        notes.insert(movedNote, at: destinationIndexPath.row)
        saveData()
    }
    
    private func setCell(cell: UITableViewCell, with note: Note) {
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.content
        cell.backgroundColor = UIColor(displayP3Red: note.r, green: note.g, blue: note.b, alpha: note.a)
    }
}

//MARK: - NoteDetailsDelegateMethods
extension NotesViewController: NoteDetailsViewControllerDelegate {
    
    func noteDetailsVievControllerDidCancel(_ controller: NoteDetailsViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func noteDetailsViewController(_ controller: NoteDetailsViewController, didFinishEditing note: Note) {
        if let index = notes.index(of: note){
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath){
                setCell(cell: cell, with: note)
                saveData()
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func noteDetailsViewController(_ controller: NoteDetailsViewController, didFinishAdding note: Note) {
        notes.append(note)
        tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
        saveData()
        navigationController?.popViewController(animated: true)
    }
}
