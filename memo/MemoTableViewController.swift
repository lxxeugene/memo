//
//  memoTableViewController.swift
//  memo
//
//  Created by lxxeugene on 2023/05/01.
//

import UIKit
import UserNotifications

class MemosTableViewController: UITableViewController {
    // MARK: - Properties
    // MARK: Privates
    /// memo 목록 - dummy 데이터
    private var memos: [Memo] = Memo.all
           
    /// 셀에 표시할 날짜를 포맷하디 위한 Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        return formatter
    }()
    // MARK: - Methods
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIViewController에서 제공하는 기본 수정버튼
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 보여질때마다 memo 목록을 새로고침
        self.memos = Memo.all
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.automatic)
      }
    // MARK: - Table view data source
    // 테이블뷰의 섹션 수 (기본값 1)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    ///테이블뷰의 섹션 별 로우 수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memos.count
    }
    
    /// 인덱스에 해당하는 cell 변환
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //스토리보드에 구현해 둔 셀을 재사용 큐에서 꺼내옴
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)

        guard indexPath.row < self.memos.count else { return cell }
        
        let memo: Memo = self.memos[indexPath.row]
        // 셀에 내용 설정
        cell.textLabel?.text = memo.title
        cell.detailTextLabel?.text = self.dateFormatter.string(from: memo.due)
        // Configure the cell...

        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // O verride to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let memoViewController: MemoViewController = segue.destination as? MemoViewController else {
            return
        }
        guard let cell: UITableViewCell = sender as? UITableViewCell else { return }
        guard let index: IndexPath = self.tableView.indexPath(for: cell) else { return }
        
        guard index.row < memos.count else { return }
        let memo: Memo = memos[index.row]
        memoViewController.memo = memo
    }
}
/// User Notification의 delegate 메서드 구현
extension MemosTableViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let idToShow: String = response.notification.request.identifier
        
        guard let memoToShow: Memo = self.memos.filter({ (memo: Memo) -> Bool in
            return memo.id == idToShow
        }).first else {
            return
        }
        
        guard let memoViewController: MemoViewController = self.storyboard?.instantiateViewController(withIdentifier:
            MemoViewController.storyboardID) as? MemoViewController else { return }
        
        memoViewController.memo = memoToShow
        
        self.navigationController?.pushViewController(memoViewController, animated: true)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
}
