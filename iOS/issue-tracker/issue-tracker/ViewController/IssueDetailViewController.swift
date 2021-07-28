import UIKit
import Combine

class IssueDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var issueTitle: UILabel!
    @IBOutlet weak var issueNumber: UILabel!
    @IBOutlet weak var issueState: UILabel!
    @IBOutlet weak var writeTime: UILabel!
    @IBOutlet weak var writer: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    private let issueDetailViewModel = IssueDetailViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureCommentTextField()
        configureCommentTableView()
        configureIssueOptionButton()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
        commentTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func bind() {
        issueDetailViewModel.didUpdateIssueDetail()
            .sink { [weak self] issueDetail in
                guard let issueDetail = issueDetail else { return }
                self?.issueTitle.text = issueDetail.title
                self?.issueNumber.text = "#\(issueDetail.issueID)"
                self?.issueState.text = "\(issueDetail.isOpen ? "열림" : "닫힘")"
                self?.writer.text = ",\(issueDetail.writer.username)님이 작성했습니다."
                self?.writeTime.text = self?.issueDetailViewModel.relativeCreatedTime(issueDetail.createdTime)
                self?.commentTableView.reloadData()
            }.store(in: &subscriptions)
        
        issueDetailViewModel.fetchIssueDetail()
    }
    
    private func configureIssueOptionButton() {
        let buttonImage = UIImage(systemName: "ellipsis")
        let button = UIButton(type: .system)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(pressedIssueOptionButton(_:)), for: .touchUpInside)
        let selectButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = selectButton
    }
    
    func setIssueID(_ issueID: Int) {
        self.issueDetailViewModel.setIssueID(issueID)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func configureCommentTextField() {
        let commentPostButton = UIButton()
        let image = UIImage(systemName: "arrow.up.circle.fill")
        commentPostButton.setImage(image, for: .normal)
        commentPostButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        commentPostButton.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        commentPostButton.isEnabled = false
        
        commentTextField.rightView = commentPostButton
        commentTextField.rightViewMode = .always
        commentTextField.layer.masksToBounds = true
        commentTextField.layer.cornerRadius = 15
        commentTextField.layer.borderWidth = 1
        commentTextField.layer.borderColor = UIColor.systemGray3.cgColor
    }
    
    private func configureCommentTableView() {
        commentTableView.register(CommentTableViewCell.nib, forCellReuseIdentifier: CommentTableViewCell.identifier)
        configureTableViewFooterView()
    }
    
    private func configureTableViewFooterView() {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        commentTableView.tableFooterView = footerView
    }
    
    @objc func postComment() {
        
    }
    
    @objc func keyboardWillShow(_ sender: NSNotification) {
        self.view.frame.origin.y = -300
    }
    
    @objc func keyboardWillHide(_ sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func pressedIssueOptionButton(_ sender: UIBarButtonItem) {
        guard let popUpViewController = self.storyboard?.instantiateViewController(identifier: IssueDetailPopUpViewController.identifier) as? IssueDetailPopUpViewController else {
            return
        }
        
        popUpViewController.modalPresentationStyle = .overCurrentContext
        self.present(popUpViewController, animated: false, completion: nil)
    }
    
    @IBAction func textFieldAction(_ sender: UITextField) {
        guard let postButton = sender.rightView as? UIButton else { return }
        if sender.text == nil || sender.text == "" {
            postButton.isEnabled = false
        } else {
            postButton.isEnabled = true
        }
        
    }
    
}

extension IssueDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issueDetailViewModel.commentCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }
        
        DispatchQueue.global().async {
            let profileImageUrl = self.issueDetailViewModel.commentProfileImage(indexPath: indexPath)
            guard let imageURL = URL(string: profileImageUrl) else { return }
            let imageData = try? Data(contentsOf: imageURL)
            guard let data = imageData, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                cell.userImageView.image = image
            }
        }
        cell.userName.text = self.issueDetailViewModel.commentUsername(indexPath: indexPath)
        cell.writeTime.text = self.issueDetailViewModel.commentWriteTime(indexPath: indexPath)
        cell.comment.text = self.issueDetailViewModel.comment(indexPath: indexPath)
        
        return cell
    }
    
}

extension IssueDetailViewController: Identifying { }
