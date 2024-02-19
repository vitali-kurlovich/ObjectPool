public final class ObjectPool<Value: AnyObject> {
    private var storage: [Value] = []

    public let create: () -> Value
    public let prepare: (Value) -> Void
    public let maxSize: Int

    public init(maxSize: Int = 0, create: @escaping () -> Value, prepare: @escaping (Value) -> Void) {
        self.create = create
        self.prepare = prepare
        self.maxSize = maxSize

        if maxSize > 0 {
            storage.reserveCapacity(maxSize)
        }
    }

    public convenience init(maxSize: Int = 0, create: @escaping () -> Value) {
        self.init(maxSize: maxSize, create: create, prepare: { _ in })
    }
}

public extension ObjectPool {
    var isEmpty: Bool {
        storage.isEmpty
    }

    var size: Int {
        storage.count
    }
}

public extension ObjectPool {
    func pull() -> Value {
        pull(prepare: prepare)
    }

    func pull(prepare: @escaping (Value) -> Void) -> Value {
        let object: Value

        if storage.isEmpty {
            object = create()
        } else {
            object = storage.removeLast()
        }

        prepare(object)

        return object
    }
}

public extension ObjectPool {
    func push(_ object: Value) {
        guard maxSize == 0 || storage.count < maxSize,
              !storage.contains(where: { $0 === object })
        else {
            return
        }

        storage.append(object)
    }
}
