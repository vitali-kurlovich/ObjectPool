import Foundation

public final class UniqueKeyObjectPool<Key: Hashable, Value: AnyObject> {
    private var storage: [Key: Value] = [:]

    public let create: (Key) -> Value
    public let prepare: (Key, Value) -> Void
    public let maxSize: Int

    public init(maxSize: Int = 0, create: @escaping (Key) -> Value, prepare: @escaping (Key, Value) -> Void) {
        self.create = create
        self.prepare = prepare
        self.maxSize = maxSize

        if maxSize > 0 {
            storage.reserveCapacity(maxSize)
        }
    }

    public convenience init(maxSize: Int = 0, create: @escaping (Key) -> Value) {
        self.init(maxSize: maxSize, create: create, prepare: { _, _ in })
    }
}

public extension UniqueKeyObjectPool {
    var isEmpty: Bool {
        storage.isEmpty
    }

    var size: Int {
        storage.count
    }
}

public extension UniqueKeyObjectPool {
    func pull(for key: Key) -> Value {
        pull(for: key, prepare: prepare)
    }

    func pull(for key: Key, prepare: @escaping (Key, Value) -> Void) -> Value {
        let object: Value

        if let value = storage[key] {
            object = value
            storage.removeValue(forKey: key)
        } else {
            if let keyValue = storage.first {
                object = keyValue.value
                storage.removeValue(forKey: keyValue.key)
            } else {
                object = create(key)
            }
        }

        prepare(key, object)

        return object
    }
}

public extension UniqueKeyObjectPool {
    func push(_ object: Value, for key: Key) {
        let containtsRef = storage[key] === object || storage.contains { _, value in
            value === object
        }

        guard maxSize == 0 || storage.count < maxSize,
              !containtsRef
        else {
            return
        }

        storage[key] = object
    }
}
