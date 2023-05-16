//
//  memo.swift
//  memo
//
//  Created by lxxeugene on 2023/05/05.
//

import Foundation
import UserNotifications

struct Memo: Codable {
    var title: String
    var due: Date
    var memo: String?
    var shouldNotify: Bool
    var id: String
}

extension Memo {
    
    static var all: [Memo] = Memo.loadMemosFromJSONFile()
    
    private static var memosPathURL: URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true).appendingPathComponent("memos.json")
        
    }
    
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

extension Memo {
    private static func addNotification(memo: Memo) {
        
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "할일 알림"
        content.body = memo.title
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let dateInfo = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.day,
            Calendar.Component.hour, Calendar.Component.minute], from: memo.due)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        let request = UNNotificationRequest(identifier: memo.id, content: content, trigger: trigger)
        
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
