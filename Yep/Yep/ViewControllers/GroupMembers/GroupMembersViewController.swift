import UIKit
import YepKit
import RealmSwift
import Ruler

final class GroupMembersViewController: BaseViewController, CanScrollsToTop {
    
    @IBOutlet fileprivate weak var membersTableView: UITableView! {
        didSet {
            membersTableView.separatorColor = UIColor.yepCellSeparatorColor()
            membersTableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            
            membersTableView.rowHeight = 80
            membersTableView.tableFooterView = UIView()
            
            membersTableView.registerNibOf(ContactsCell.self)
        }
    }
    
    // CanScrollsToTop
    var scrollView: UIScrollView? {
        return membersTableView
    }
    
    var groupId: String = ""
    
    fileprivate var members : [DiscoveredUser] = []
    
    fileprivate lazy var noMembersFooterView: InfoView = InfoView(String.trans_promptNoMembers)
    
    fileprivate var noMembers = false {
        didSet {
            //membersTableView.tableHeaderView = noContacts ? nil : searchBar
            
            if noMembers != oldValue {
                membersTableView.tableFooterView = noMembers ? noMembersFooterView : UIView()
            }
        }
    }
    
    fileprivate struct Listener {
        static let Nickname = "GroupMembersViewController.Nickname"
        static let Avatar = "GroupMembersViewController.Avatar"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        YepUserDefaults.avatarURLString.removeListenerWithName(Listener.Avatar)
        YepUserDefaults.nickname.removeListenerWithName(Listener.Nickname)
        
        membersTableView?.delegate = nil
        
        println("deinit GroupMembers")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = String.trans_titleCircleMembers
        
        NotificationCenter.default.addObserver(self, selector: #selector(GroupMembersViewController.syncMembers(_:)), name: YepConfig.NotificationName.groupMembers, object: nil)

        YepUserDefaults.nickname.bindListener(Listener.Nickname) { [weak self] _ in
            SafeDispatch.async {
                self?.updateMembersTableView()
            }
        }
        
        YepUserDefaults.avatarURLString.bindListener(Listener.Avatar) { [weak self] _ in
            SafeDispatch.async {
                self?.updateMembersTableView()
            }
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: membersTableView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Actions
    
    fileprivate func updateMembersTableView(scrollsToTop: Bool = false) {
        SafeDispatch.async { [weak self] in
            self?.membersTableView.reloadData()
            
            if scrollsToTop {
                self?.membersTableView.yep_scrollsToTop()
            }
        }
    }
    
    @objc fileprivate func syncMembers(_ sender: Notification) {
        getCircleMembers(self.groupId, failureHandler: nil, completion: { members in
            if !members.isEmpty {
                self.members = members
                self.updateMembersTableView()
            }
        })
    }
    
    func prepare(_ groupId: String) {
        self.groupId = groupId
        getCircleMembers(self.groupId, failureHandler: nil, completion: { members in
            if !members.isEmpty {
                self.members = members
                self.updateMembersTableView()
            }
        })
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "showProfile":
            let vc = segue.destination as! ProfileViewController
            let user = sender as! DiscoveredUser
            vc.prepare(with: user)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension GroupMembersViewController: UITableViewDataSource, UITableViewDelegate {
    
    enum Section: Int {
        case local
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    fileprivate func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .local:
            return members.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    
    fileprivate func memberAtIndexPath(_ indexPath: IndexPath) -> DiscoveredUser? {
        
        let index = indexPath.row
        let member = members[safe: index]
        return member
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ContactsCell = tableView.dequeueReusableCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ContactsCell else {
            return
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
            
        case .local:
            
            guard let member = memberAtIndexPath(indexPath) else {
                return
            }
            
            cell.configureWithDiscoveredUser(member)
            
            cell.showProfileAction = { [weak self] in
                if let member = self?.memberAtIndexPath(indexPath) {
                    self?.performSegue(withIdentifier: "showProfile", sender: member)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ContactsCell else {
            return
        }
        
        cell.avatarImageView.image = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
        case .local:
            if let member = memberAtIndexPath(indexPath) {
                performSegue(withIdentifier: "showProfile", sender: member)
            }
        }
    }
    
    // MARK: UITableViewRowAction
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return false
        }
        
        switch section {
        case .local:
            return true
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension GroupMembersViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = membersTableView.indexPathForRow(at: location), let cell = membersTableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        
        let vc = UIStoryboard.Scene.profile
        
        let user = members[indexPath.row]
        vc.prepare(with: user)
        return vc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
    }
}

