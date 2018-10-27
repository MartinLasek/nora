/// Implementation knowledge is based on following sources:
/// • https://www.sqlite.org/foreignkeys.html
/// • https://www.simplifiedios.net/swift-sqlite-tutorial/#Creating_a_new_Xcode_Project
/// • (https://www.raywenderlich.com/385-sqlite-with-swift-tutorial-getting-started)

import UIKit
import SQLite3

// globale singleton of database manager
let hashtagRepository = HashtagRepository()

typealias HashtagGroupId = Int
typealias HashtagId = Int

final class HashtagRepository {
    var db: OpaquePointer?

    deinit {
        sqlite3_close(db)
    }

    init() {
        prepare()
    }

    func prepare() {

        // the database file
        let fileURL = try! FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("TheNoraApp.sqlite")
print(fileURL)
        // opening the database
        let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(fileURL.path, &db, options, nil) != SQLITE_OK {
            print("error opening database")
        }

        // creating hashtag group table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS HashtagGroup (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating hashtag group table: \(errmsg)")
        }

        // creating hashtag table
        let createHashtagTableQuery = """
            CREATE TABLE IF NOT EXISTS Hashtag
            (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                usages INTEGER,
                state TEXT,
                hashtagGroupId,
                FOREIGN KEY(hashtagGroupId) REFERENCES HashtagGroup(id)
            )

        """

        if sqlite3_exec(db, createHashtagTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating hashtag table: \(errmsg)")
        }
    }

    // MARK: HashtagGroup

    func insert(_ hashtagGroup: HashtagGroup) {
        // creating a statement
        var stmt: OpaquePointer?

        // preparing the query
        if sqlite3_prepare(db, "INSERT INTO HashtagGroup (name) VALUES (?)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        //binding the parameters
        if sqlite3_bind_text(stmt, 1, hashtagGroup.name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }

        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hashtagGroup: \(errmsg)")
            return
        }
    }

    func selectHashtagGroup(by hashtagGroupId: Int) -> HashtagGroup? {
        // statement pointer
        var stmt: OpaquePointer?
        var hashtagGroup: HashtagGroup?

        // preparing the query
        if sqlite3_prepare(db, "SELECT * FROM HashtagGroup WHERE id=\(hashtagGroupId)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error select: \(errmsg)")
            return nil
        }

        // traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            //            let age = sqlite3_column_int(stmt, 2)

            hashtagGroup = HashtagGroup(id: Int(id), name: name)
        }

        hashtagGroup?.hashtags = selectAllHashtags(by: hashtagGroupId)

        return hashtagGroup
    }

    func selectAllHashtagGroups() -> ([HashtagGroup]) {
        // statement pointer
        var stmt: OpaquePointer?
        var hashtagGroupList = [HashtagGroup]()

        // preparing the query
        if sqlite3_prepare(db, "SELECT * FROM HashtagGroup", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error select: \(errmsg)")
            return hashtagGroupList
        }

        // traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))

            // adding values to list
            hashtagGroupList.append(HashtagGroup(id: Int(id), name: name))
        }

        for hashtagGroup in hashtagGroupList {
            if let id = hashtagGroup.id {
                hashtagGroup.hashtags = selectAllHashtags(by: id)
            }
        }

        return hashtagGroupList
    }

    func removeHashtagGroupBy(hashtagGroupId: Int) {
        var stmt: OpaquePointer?
        let id = String(hashtagGroupId)

        // preparing the query
        if sqlite3_prepare(db, "DELETE FROM HashtagGroup WHERE id=\(id)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error select: \(errmsg)")
            return
        }

        //executing the query to delete the hashtag group
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure delete hashtagGroup with id \(id): \(errmsg)")
            return
        }

        removeAllHashtags(by: hashtagGroupId)
    }

    func updateHashtagGroupName(by hashtagGroupId: HashtagGroupId, name: String) {
        var stmt: OpaquePointer?
        let id = String(hashtagGroupId)

        // preparing the query
        if sqlite3_prepare(db, "UPDATE HashtagGroup SET name='\(name)' WHERE id=\(id)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error update: \(errmsg)")
            return
        }

        //executing the query to update the hashtag group
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure update hashtagGroup name with id \(id): \(errmsg)")
            return
        }
    }

    // MARK: Hashtag

    func insert(_ hashtag: Hashtag) {
        var statement: OpaquePointer?

        // preparing the query
        let query = """
            INSERT INTO Hashtag
            (name, usages, state, hashtagGroupId)
            VALUES (?,?,?,?)
        """

        if sqlite3_prepare(db, query, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        //binding the parameters
        let namePos: Int32 = 1
        let usagesPos: Int32 = 2
        let statePos: Int32 = 3
        let hashtagGroupIdPos: Int32 = 4

        // name
        let n: NSString = NSString(string: hashtag.name) // if not converted: malfunctioning
        if sqlite3_bind_text(statement, namePos, n.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        // usages
        if sqlite3_bind_int(statement, usagesPos, Int32(hashtag.usages)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        // state
        let s: NSString = NSString(string: hashtag.name) // if not converted: malfunctioning
        if sqlite3_bind_text(statement, statePos, s.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        // hashtagGroupId
        if sqlite3_bind_int(statement, hashtagGroupIdPos, Int32(hashtag.hashtagGroupId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }

        //executing the query to insert values
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hashtagGroup: \(errmsg)")
            return
        }
    }

    func selectAllHashtags(by hashtagGroupId: HashtagGroupId) -> ([Hashtag]) {
        // statement pointer
        var stmt: OpaquePointer?
        var hashtagList = [Hashtag]()

        // preparing the query
        if sqlite3_prepare(db, "SELECT * FROM Hashtag WHERE hashtagGroupId=\(hashtagGroupId)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error select: \(errmsg)")
            return hashtagList
        }

        // traversing through all the records
        let idPos: Int32 = 0
        let namePos: Int32 = 1
        let usagesPos: Int32 = 2
        let statePos: Int32 = 3
        let hashtagGroupIdPos: Int32 = 4

        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, idPos))
            let name = String(cString: sqlite3_column_text(stmt, namePos))
            let usages = Int(sqlite3_column_int(stmt, usagesPos))
            let state = String(cString: sqlite3_column_text(stmt, statePos))
            let hashtagGroupId = Int(sqlite3_column_int(stmt, hashtagGroupIdPos))

            // adding values to list
            hashtagList.append(
                Hashtag(
                    id: id,
                    name: name,
                    usages: usages,
                    state: Hashtag.State(rawValue: state) ?? .none,
                    hashtagGroupId: hashtagGroupId
                )
            )
        }

        return hashtagList
    }

    func removeAllHashtags(by hashtagGroupId: HashtagGroupId) {
        var stmt: OpaquePointer?
        let id = String(hashtagGroupId)

        // preparing the query
        if sqlite3_prepare(db, "DELETE FROM Hashtag WHERE hashtagGroupId=\(id)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error select: \(errmsg)")
            return
        }

        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure delete hashtags with hashtag group id \(id): \(errmsg)")
            return
        }
    }

    func removeHashtag(by hashtagId: HashtagId) {
        var stmt: OpaquePointer?
        let id = String(hashtagId)

        // preparing the query
        if sqlite3_prepare(db, "DELETE FROM Hashtag WHERE id=\(id)", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error select: \(errmsg)")
            return
        }

        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure delete hashtag with id \(id): \(errmsg)")
            return
        }
    }
}
