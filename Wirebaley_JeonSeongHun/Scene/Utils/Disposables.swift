//
//  Disposables.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/14.
//

final class Disposables {
    private var disposables: [() -> Void] = []
    
    func add(_ disposable: @escaping () -> Void) {
        disposables.append(disposable)
    }
    
    func dispose() {
        disposables.forEach { $0() }
        disposables.removeAll()
    }
}

final class DisposeBag {
    private weak var disposables: Disposables?
    
    func add(_ disposable: @escaping () -> Void) {
        disposables?.add(disposable)
    }
    
    deinit {
        disposables?.dispose()
    }
}
