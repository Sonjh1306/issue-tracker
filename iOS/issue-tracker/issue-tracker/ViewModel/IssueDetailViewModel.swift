import Foundation
import Combine

class IssueDetailViewModel {
    
    @Published private var issueDetail: IssueDetail?
    @Published private var resultMessage: String?
    private let issueDetailUseCase: IssueDetailUseCase
    private var issueID: Int
    private var commentID: Int
    private var newComment: String
    private let myInfo = MyInfo.shared
    
    init() {
        self.issueDetail = nil
        self.issueDetailUseCase = IssueDetailUseCase()
        self.issueID = 0
        self.commentID = 0
        self.newComment = ""
    }
    
    func fetchIssueDetail() {
        self.issueDetailUseCase.executeFetchingLabelList(issueID: issueID) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let issueDetail):
                self.issueDetail = issueDetail
            }
        }
    }
    
    func addNewComment() {
        self.issueDetailUseCase.executeAddingNewComment(issueID: issueID, comment: NewCommentDTO(content: newComment, file: nil)) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let resultMessage):
                self.resultMessage = resultMessage
            }
        }
    }
    
    func didUpdateIssueDetail() -> AnyPublisher<IssueDetail?, Never> {
        return $issueDetail
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func didUpdateResultMessage() -> AnyPublisher<String?, Never> {
        return $resultMessage
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func setIssueID(_ issueID: Int) {
        self.issueID = issueID
    }
    
    func relativeCreatedTime(_ time: String?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let createdTimeString = time,
            let createTimeDate = formatter.date(from: createdTimeString) else {
            return ""
        }
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        relativeFormatter.locale = Locale(identifier: "ko_KR")
        return relativeFormatter.localizedString(for: createTimeDate, relativeTo: Date())
    }
    
    func commentCount() -> Int {
        return self.issueDetail?.comments.count ?? 0
    }
    
    func commentProfileImage(indexPath: IndexPath) -> String {
        guard let imageUrl = self.issueDetail?.comments[indexPath.row].writer.profileImage else {
            return ""
        }
        
        return imageUrl
    }
    
    func commentUsername(indexPath: IndexPath) -> String {
        guard let username = self.issueDetail?.comments[indexPath.row].writer.username else {
            return ""
        }
        
        return username
    }
    
    func commentWriteTime(indexPath: IndexPath) -> String {
        return relativeCreatedTime(self.issueDetail?.comments[indexPath.row].createdTime)
    }
    
    func comment(indexPath: IndexPath) -> String {
        guard let content = self.issueDetail?.comments[indexPath.row].content else {
            return ""
        }
        
        return content
    }
    
    func file(indexPath: IndexPath) -> String? {
        return self.issueDetail?.comments[indexPath.row].file
    }
    
    func setNewComment(_ comment: String) {
        self.newComment = comment
    }
    
    func writer(indexPath: IndexPath) -> Bool {
        return self.issueDetail?.comments[indexPath.row].writer.id == myInfo.id
    }
    
    func setCommentID(indexPath: IndexPath) {
        guard let id = self.issueDetail?.comments[indexPath.row].commentID else {
            return
        }
        self.commentID = id
    }
}