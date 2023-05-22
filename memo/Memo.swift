//
//  memo.swift
//  memo
//
//  Created by lxxeugene on 2023/05/05.
//

import Foundation
import UserNotifications

// 인스턴스를 표현할 구조체
struct Memo: Codable {
    var title: String  // 작업이름
    var due: Date      // 작업기한
    var memo: String?  // 작업메모
    var shouldNotify: Bool      // 사용자가 기한에 맞춰 알림을 받기 원하는지
    var id: String    // 작업 고유ID
}
    // memo 목록 저장/로드
extension Memo {
    
    static var all: [Memo] = Memo.loadMemosFromJSONFile()
    // memo json 파일 위치
    private static var memosPathURL: URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true).appendingPathComponent("memos.json")
        
    }
    // json 파일로부터 memo 배열 읽어오기
    private static func loadMemosFromJSONFile() -> [Memo] {
        do {
            let jsonData: Data = try Data(contentsOf: self.memosPathURL)
            let memos: [Memo] = try JSONDecoder().decode([Memo].self, from: jsonData)
            return memos
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    // 현재 memo 배열 상태를 json 파일로 저장
    @discardableResult private static func saveToJSONFile() -> Bool {
        do {
            let data: Data = try JSONEncoder().encode(self.all)
            try data.write(to: self.memosPathURL, options: Data.WritingOptions.atomicWrite)
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
}
// 현재 memo 배열에 추가/삭제/수정
extension Memo {
    @discardableResult static func remove(id: String) -> Bool {
        
        guard let index: Int = self.all.index(where: { (memo: Memo) -> Bool in
            memo.id == id
        }) else { return false }
        self.all.remove(at: index)
        return self.saveToJSONFile()
    }
    
    @discardableResult func save(completion: () -> Void) -> Bool {
        
        if let index = Memo.index(of: self) {
            Memo.removeNotification(memo: self)
            Memo.all.replaceSubrange(index...index, with: [self])
        } else {
            Memo.all.append(self)
        }
        let isSuccess: Bool = Memo.saveToJSONFile()
        if isSuccess {
            if self.shouldNotify {
                Memo.addNotification(memo: self)
            } else {
                Memo.removeNotification(memo: self)
            }
            completion()
        }
        return isSuccess
    }
    
    private static func index(of target: Memo) -> Int? {
        guard let index: Int = self.all.index(where: { (memo: Memo) -> Bool in
            memo.id == target.id
        }) else { return nil }
        return index
        
    }
}
// Memo의 User Notification 관련메서드
extension Memo {
    private static func addNotification(memo: Memo) {
        // 공용 UserNotification 객체
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        // 노티피케이션 콘텐츠 객체 생성
        let content = UNMutableNotificationContent()
        content.title = "할일 알림"
        content.body = memo.title
        content.sound = UNNotificationSound.default
        content.badge = 1
        // 기한 날짜 생성
        let dateInfo = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.day,
            Calendar.Component.hour, Calendar.Component.minute], from: memo.due)
        // 노티피케이션 트리거 생성
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        // 노티피케이션 요청 객체 생성
        let request = UNNotificationRequest(identifier: memo.id, content: content, trigger: trigger)
        // 노티피케이션 스테줄 추가
        center.add(request, withCompletionHandler: { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
                
            }
        })
    }
    private static func removeNotification(memo: Memo) {
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [memo.id])
    }
}
