//
//  Observable.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/14.
//

final class Observable<T> {
    struct Observer<Value> {
        weak var observer: AnyObject?
        let block: (Value) -> Void
    }
    
    private var observers = [Observer<T>]()
    
    var value: T {
        didSet {
            notifyObservers(event: value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    deinit {
        observers.removeAll()
    }
    
    @discardableResult
    fileprivate func observe(on observer: AnyObject,
                             observerBlock: @escaping (T) -> Void
    ) -> Observable<T> {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(value)
        
        return self
    }
    
    private func notifyObservers(event: T) {
        for observer in observers {
            observer.block(event)
        }
    }
    
    fileprivate func removeDisposable(for observer: AnyObject) -> () -> Void {
        return { [weak self] in
            self?.remove(observer: observer)
        }
    }
    
    private func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    func subscribe(on observer: AnyObject,
                   disposeBag: DisposeBag,
                   onNext: ((T) -> Void)? = nil
    ) -> Subscription<T> {
        return Subscription(observable: self,
                            observer: observer,
                            disposeBag: disposeBag,
                            onNext: onNext
        )
    }
}

final class Subscription<Value> {
    private let observable: Observable<Value>
    private weak var observer: AnyObject?
    private let disposeBag: DisposeBag
    
    init(
        observable: Observable<Value>,
        observer: AnyObject,
        disposeBag: DisposeBag,
        onNext: ((Value) -> Void)? = nil
    ) {
        self.observable = observable
        self.observer = observer
        self.disposeBag = disposeBag
        
        if let onNext = onNext {
            self.onNext(onNext)
        }
    }
    
    @discardableResult
    func onNext(_ onNext: @escaping (Value) -> Void) -> Self {
        guard let observer = observer else { return self }
        
        let disposable = observable.observe(on: observer) { event in
          onNext(event)
        }.removeDisposable(for: observer)
        
        disposeBag.add(disposable)
        return self
    }
}
