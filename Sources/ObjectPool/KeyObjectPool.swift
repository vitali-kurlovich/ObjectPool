import Foundation

public final class KeyObjectPool<Key: Equatable, Value: AnyObject> {
    private struct Container {
        let key: Key
        let object: Value
    }

    private var starage: [Container] = []

    public let create: (Key) -> Value
    public let prepare: (Key, Value) -> Void
    public let maxSize: Int

    public init(maxSize: Int = 0, create: @escaping (Key) -> Value, prepare: @escaping (Key, Value) -> Void) {
        self.create = create
        self.prepare = prepare
        self.maxSize = maxSize

        if maxSize > 0 {
            starage.reserveCapacity(maxSize)
        }
    }

    public convenience init(maxSize: Int = 0, create: @escaping (Key) -> Value) {
        self.init(maxSize: maxSize, create: create, prepare: { _, _ in })
    }
}

public extension KeyObjectPool {
    var isEmpty: Bool {
        starage.isEmpty
    }

    var size: Int {
        starage.count
    }
}

public extension KeyObjectPool {
    func pull(for key: Key) -> Value {
        pull(for: key, prepare: prepare)
    }

    func pull(for key: Key, prepare: @escaping (Key, Value) -> Void) -> Value {
        let object: Value

        let index = starage.firstIndex { container in
            container.key == key
        }

        if let index {
            let container = starage.remove(at: index)
            object = container.object
        } else {
            object = starage.isEmpty ? create(key) : starage.removeLast().object
        }

        prepare(key, object)

        return object
    }
}

public extension KeyObjectPool {
    func push(_ object: Value, for key: Key) {
        guard maxSize == 0 || starage.count < maxSize,
              !starage.contains(where: { $0.object === object })
        else {
            return
        }

        let container = Container(key: key, object: object)

        starage.append(container)
    }
}
