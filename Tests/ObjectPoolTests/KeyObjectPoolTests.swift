//
//  KeyObjectPoolTests.swift
//
//
//  Created by vkurlovich on 16.02.24.
//

@testable import ObjectPool
import XCTest

final class KeyObjectPoolTests: XCTestCase {
    func testObjectPool() throws {
        let objectPool = KeyObjectPool<Int, MocObject> { key in
            MocObject(intValue: key, stringValue: "\(key)")
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertEqual(MocObject(intValue: 1, stringValue: "1"), objectPool.pull(for: 1))

        XCTAssertTrue(objectPool.isEmpty)

        let object = objectPool.pull(for: 2) { key, object in
            object.intValue = key + 1
            object.stringValue = ""
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertEqual(MocObject(intValue: 3, stringValue: ""), object)

        objectPool.push(object, for: 5)

        XCTAssertFalse(objectPool.isEmpty)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(MocObject(intValue: 6, stringValue: "666"), for: 6)

        XCTAssertEqual(objectPool.size, 2)

        XCTAssertTrue(objectPool.pull(for: 5) === object)

        XCTAssertEqual(objectPool.size, 1)
    }

    func testObjectPoolPreparation() throws {
        let objectPool = KeyObjectPool<Int, MocObject> { key in
            MocObject(intValue: key, stringValue: String(key))
        } prepare: { key, object in
            object.intValue = key
            object.stringValue = "\(key)"
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertEqual(MocObject(intValue: 6, stringValue: "6"), objectPool.pull(for: 6))

        XCTAssertTrue(objectPool.isEmpty)

        objectPool.push(MocObject(intValue: 10, stringValue: "10"), for: 1)

        XCTAssertEqual(objectPool.size, 1)

        XCTAssertEqual(MocObject(intValue: 5, stringValue: "5"), objectPool.pull(for: 5))

        XCTAssertTrue(objectPool.isEmpty)
    }

    func testObjectPoolTheSameRef() throws {
        let objectPool = KeyObjectPool<Int, MocObject>(maxSize: 3) { key in
            MocObject(intValue: key, stringValue: "\(key)")
        }

        let object_1 = objectPool.pull(for: 1)

        objectPool.push(object_1, for: 1)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(object_1, for: 2)

        XCTAssertEqual(objectPool.size, 1)
    }

    func testObjectPoolMaxSize() throws {
        let objectPool = KeyObjectPool<Int, MocObject>(maxSize: 3) { key in
            MocObject(intValue: key, stringValue: "\(key)")
        }

        let object_1 = objectPool.pull(for: 1)
        let object_2 = objectPool.pull(for: 2)
        let object_3 = objectPool.pull(for: 3)
        let object_4 = objectPool.pull(for: 4)
        let object_5 = objectPool.pull(for: 5)

        XCTAssertTrue(objectPool.isEmpty)

        objectPool.push(object_1, for: 1)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(object_1, for: 2)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(object_2, for: 3)

        XCTAssertEqual(objectPool.size, 2)

        objectPool.push(object_2, for: 4)

        XCTAssertEqual(objectPool.size, 2)

        objectPool.push(object_3, for: 5)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_3, for: 6)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_4, for: 7)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_4, for: 8)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_5, for: 9)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_5, for: 10)

        XCTAssertEqual(objectPool.size, 3)
    }
}
