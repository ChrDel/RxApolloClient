//
//  ViewModel.swift
//  RxApolloClient_Example
//
//  Created by Kanghoon on 18/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    // Input
    let searchRelay = PublishRelay<(String, String?)>()
    
    // Output
    let repoList = BehaviorRelay<List<Repository>?>(value: nil)
    
    let disposeBag = DisposeBag()
    
    init(_ githubService: GithubServiceType) {
        searchRelay
            .distinctUntilChanged { $0.0 == $1.0 && $0.1 == $1.1 }
            .flatMapLatest { githubService.searchRepositories(request: $0) }
            .scan(nil) { (old, new) -> List<Repository> in
                guard let old = old,
                    old.query == new.query else { return new }
                return .init(query: new.query,
                             items: old.items + new.items,
                             after: new.after)
            }
            .bind(to: repoList)
            .disposed(by: disposeBag)
    }
}
