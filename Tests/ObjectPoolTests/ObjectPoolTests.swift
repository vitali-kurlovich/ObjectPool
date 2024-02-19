@testable import ObjectPool
import XCTest

final class ObjectPoolTests: XCTestCase {
    func testObjectPool() throws {
        let objectPool = ObjectPool {
            MocObject(intValue: 0, stringValue: "")
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertEqual(MocObject(intValue: 0, stringValue: ""), objectPool.pull())

        XCTAssertTrue(objectPool.isEmpty)

        let object = objectPool.pull { object in
            object.intValue = 1
            object.stringValue = "1"
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertEqual(MocObject(intValue: 1, stringValue: "1"), object)

        let object1 = objectPool.pull { object in
            object.intValue = 2
            object.stringValue = "1"
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertEqual(MocObject(intValue: 2, stringValue: "1"), object1)

        XCTAssertNotEqual(object, object1)

        object1.intValue = 1
        XCTAssertEqual(object, object1)

        XCTAssertFalse(object === object1)

        objectPool.push(object1)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(object1)

        XCTAssertEqual(objectPool.size, 1)

        let object2 = objectPool.pull { object in
            object.intValue = 2
            object.stringValue = "1"
        }

        XCTAssertTrue(objectPool.isEmpty)

        XCTAssertTrue(object1 === object2)
    }

    func testMaxSizeObjectPool() throws {
        let objectPool = ObjectPool(maxSize: 3) {
            MocObject(intValue: 0, stringValue: "")
        }

        let object_1 = objectPool.pull { object in
            object.intValue = 1
            object.stringValue = "1"
        }

        let object_2 = MocObject(intValue: 2, stringValue: "2")
        let object_3 = MocObject(intValue: 3, stringValue: "3")
        let object_4 = MocObject(intValue: 4, stringValue: "4")
        let object_5 = MocObject(intValue: 5, stringValue: "5")

        XCTAssertTrue(objectPool.isEmpty)

        objectPool.push(object_1)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(object_1)

        XCTAssertEqual(objectPool.size, 1)

        objectPool.push(object_2)

        XCTAssertEqual(objectPool.size, 2)

        objectPool.push(object_2)

        XCTAssertEqual(objectPool.size, 2)

        objectPool.push(object_3)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_3)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_4)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_4)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_5)

        XCTAssertEqual(objectPool.size, 3)

        objectPool.push(object_5)

        XCTAssertEqual(objectPool.size, 3)
    }
}
