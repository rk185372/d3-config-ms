//
//  SavedUsernamesViewController.swift
//  Authentication
//
//  Created by Elvin Bearden on 12/2/20.
//

import UIKit
import ComponentKit
import RxSwift
import UITableViewPresentation

protocol SavedUsernamesDelegate: class {
    func usernameSelected(_ username: String)
    func usernameDeleted(_ username: String)
}

class SavedUsernamesViewController: UIViewControllerComponent,UsernamerowDelegate {
    @IBOutlet weak var tableView: UITableView!

    private let persistenceHelper: ChallengePersistenceHelper
    private var dataSource: UITableViewPresentableDataSource!
    private let currentTabIndex: Int
    public var savedBusinessUsernamesCount: Int = 0
    public var savedPersonalUsernamesCount: Int = 0
    
    weak var delegate: SavedUsernamesDelegate?

    init(componentConfig: ComponentConfig, persistenceHelper: ChallengePersistenceHelper, currentTabIndex: Int) {
        self.persistenceHelper = persistenceHelper
        self.currentTabIndex = currentTabIndex

        super.init(
            l10nProvider: componentConfig.l10nProvider,
            componentStyleProvider: componentConfig.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: AuthenticationBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = l10nProvider.localize("login.multiprofile.title")

        setupTableView()
        setupCloseButton()
    }
    
    func rowDeleted(at delete: UIButton) {
       showDeleteConfirmation(for: delete)
    }
}

// MARK: - Private
private extension SavedUsernamesViewController {
    func setupTableView() {
        tableView.separatorStyle = .none

        dataSource = UITableViewPresentableDataSource(tableView: tableView)
        dataSource.tableViewModel = createTableViewModel()
        dataSource.delegate = self
    }

    func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            title: l10nProvider.localize("login.multiprofile.btn.done"),
            style: .done,
            target: nil,
            action: nil
        )

        closeButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)

        navigationItem.leftBarButtonItem = closeButton
    }

    func setupEditButton() {
        let editTitle = l10nProvider.localize("login.multiprofile.btn.edit")
        let doneTitle = l10nProvider.localize("login.multiprofile.btn.done")
        let editButton = UIBarButtonItem(
            title: editTitle,
            style: .plain,
            target: nil,
            action: nil
        )

        editButton.rx.tap.bind {
            self.tableView.isEditing.toggle()
            editButton.title = self.tableView.isEditing ? doneTitle : editTitle
        }.disposed(by: bag)

        navigationItem.rightBarButtonItem = editButton
    }

    func createTableViewModel() -> UITableViewModel {
        let savedPersonalUsernames = persistenceHelper.savedUsernames(currentTabIndex: 0)
        savedPersonalUsernamesCount = savedPersonalUsernames.count
        let savedPersonalRows = savedPersonalUsernames.map {
            return UsernameRow(username: $0, delegate: self)
        }
        
        let savedBusinessUsernames = persistenceHelper.savedUsernames(currentTabIndex: 1)
        savedBusinessUsernamesCount = savedBusinessUsernames.count
        let savedBusinessRows = savedBusinessUsernames.map {
            return UsernameRow(username: $0, delegate: self)
        }

        var sections: [UITableViewSection] = []
        if !savedPersonalRows.isEmpty {
            sections.append(UITableViewSection(
                rows: savedPersonalRows,
                header: .title(l10nProvider.localize("login.multiprofile.header.personalusernames")),
                footer: .none
            ))
        }
        
        if !savedBusinessRows.isEmpty {
            sections.append(UITableViewSection(
                rows: savedBusinessRows,
                header: .title(l10nProvider.localize("login.multiprofile.header.businessusernames")),
                footer: .none
            ))
        }
        
        let savedProfilesFooterString = L10NStringDisplayRow(l10nString:
                                                                l10nProvider.localize("login.multiprofile.savedprofilestext.description"))
        sections.append(UITableViewSection(
            rows: [savedProfilesFooterString],
            header: .none,
            footer: .none
        ))

        return UITableViewModel(sections: sections)
    }

    func showDeleteConfirmation(for selectedBtn: UIButton) {
        guard let cell = selectedBtn.superview?.superview as? UsernameCell else {
            return // or fatalError() or whatever
        }
        
        let indexPath = tableView.indexPath(for: cell)
        var currentSectionIndex = indexPath?.section == 0 ? 0 : 1
        
        // we are dipslying personal userlist in section 0.
        // If there are no personal users we will display business list in section 0.
        // So inorder to get the business usernames we need to modify current index to 1
        if (savedPersonalUsernamesCount == 0 && indexPath?.section == 0) {
            currentSectionIndex = 1
        }
        
        let message = l10nProvider.localize("login.multiprofile.delete.modal.message", parameterMap: [
            "username": persistenceHelper.savedUsernames(currentTabIndex: currentSectionIndex)[indexPath!.row].masked()
        ])
        let alertController = UIAlertController(
            title: l10nProvider.localize("login.multiprofile.delete.modal.title"),
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
                                    title: l10nProvider.localize("login.multiprofile.delete.modal.cancel"),
                                    style: .default,
                                    handler: { (_) in })
        )

        alertController.addAction(UIAlertAction(
                                    title: l10nProvider.localize("login.multiprofile.delete.modal.delete"),
                                    style: .destructive,
                                    handler: { (_) in
                                        self.deleteRow(index: indexPath!.row, section: currentSectionIndex)
                                    })
        )
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }

    func deleteRow(index: Int, section: Int) {
        let username = persistenceHelper.savedUsernames(currentTabIndex: section)[index]
        persistenceHelper.deleteUsername(username: username)

        dataSource.setTableViewModel(to: createTableViewModel(), animated: true)
        tableView.reloadData()
        persistenceHelper.deleteUsername(username: username)
        
        delegate?.usernameDeleted(username)
    }
}

// MARK: - UITableViewPresentableDataSourceDelegate
extension SavedUsernamesViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 || indexPath.section == 1 {
           return
            
        } else if let row = presentable.base as? UsernameRow {
            delegate?.usernameSelected(row.username)
            self.dismiss(animated: true, completion: nil)
        }        
    }

    func rowDeleted(at indexPath: IndexPath) {}
}

