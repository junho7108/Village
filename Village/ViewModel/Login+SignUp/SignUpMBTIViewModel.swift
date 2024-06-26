import RxSwift
import RxCocoa
import os

final class SignUpMBTIViewModel: ViewModelType {
   
    struct Input {
        let tapMBTIEnergy: Observable<MBTIEnergy>
        let tapMBTIInformation: Observable<MBTIInformation>
        let tapMBTIDecisions: Observable<MBTIDecisions>
        let tapMBTILifestyle: Observable<MBTILifestyle>
        let tapComplete: Observable<Void>
        let tapMBTILink: Observable<Void>
        let tapSimpleMBTITest: Observable<Void>
        let tapDetailMBTITest: Observable<Void>
    }
    
    struct Output {
        let selectButtonEnabled: Observable<Bool>
        let selectedMBTI: Observable<MBTIType?>
        let showSignInPage: Observable<SignUpRequest>
        let showMBTILinkPage: Observable<Void>
        let showSimpleMBTITestPage: Observable<Void>
        let showDetailMBTITestPage: Observable<Void>
    }
    
    struct Dependencies {
        let signUpRequest: SignUpRequest
    }
    
    var disposeBag: DisposeBag = .init()
    
    let selectedMBTI = BehaviorRelay<MBTIType?>(value: nil)
    
    let dependencies: Dependencies
    
    required init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func transform(input: Input) -> Output {
        
        let showSignInPage = PublishRelay<SignUpRequest>()
        let selectButtonEnabled = BehaviorRelay<Bool>(value: false)
    
        let selectedMBTIFirst = PublishRelay<MBTIEnergy>()
        let selectedMBTISecond = PublishRelay<MBTIInformation>()
        let selectedMBTIThird = PublishRelay<MBTIDecisions>()
        let selectedMBTILast = PublishRelay<MBTILifestyle>()
        
        let request = BehaviorRelay<SignUpRequest>(value: dependencies.signUpRequest)
        
        input.tapMBTIEnergy
            .bind(to: selectedMBTIFirst)
            .disposed(by: disposeBag)
        
        input.tapMBTIInformation
            .bind(to: selectedMBTISecond)
            .disposed(by: disposeBag)
        
        input.tapMBTIDecisions
            .bind(to: selectedMBTIThird)
            .disposed(by: disposeBag)
        
        input.tapMBTILifestyle
            .bind(to: selectedMBTILast)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(selectedMBTIFirst, selectedMBTISecond, selectedMBTIThird, selectedMBTILast) {
            MBTIType(firstIndex: $0, secondIndex: $1, thirdIndex: $2, lastIndex: $3)
        }
        .bind(to: selectedMBTI)
        .disposed(by: disposeBag)
        
        selectedMBTI
            .bind { mbti in
                selectButtonEnabled.accept(mbti != nil)
            }
            .disposed(by: disposeBag)
        
        input.tapComplete
            .withLatestFrom(selectedMBTI)
            .map { mbti -> SignUpRequest in
                guard let mbti = mbti else {  Logger.printLog("MBTI가 nil입니다."); fatalError() }
                
                var request = request.value
                
                request.mbtiType = mbti
                request.mbtiEnergy = mbti.firstIndex
                request.mbtiInformation = mbti.secondIndex
                request.mbtiDecisions = mbti.thirdIndex
                request.mbtiLifestyle = mbti.lastIndex
                return request
            }
            .bind(to: showSignInPage)
            .disposed(by: disposeBag)
        
        return Output(selectButtonEnabled: selectButtonEnabled.asObservable(),
                      selectedMBTI: selectedMBTI.asObservable(),
                      showSignInPage: showSignInPage.asObservable(),
                      showMBTILinkPage: input.tapMBTILink.asObservable(),
                      showSimpleMBTITestPage: input.tapSimpleMBTITest.asObservable(),
                      showDetailMBTITestPage: input.tapDetailMBTITest.asObservable())
    }
}
