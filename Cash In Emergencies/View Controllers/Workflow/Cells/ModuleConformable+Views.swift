//
//  ModuleConformable+Views.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 04/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import ARCDM
import ThunderTable

protocol ModuleConformable {
    func module() -> Module?
}

class ModuleView: ModuleConformable, Row {
    
    var internalModule: Module?
    
    private var toolkitTableViewController: ToolkitTableViewController?
    
    var shouldShowModuleRoadmap: Bool = false
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    //ROW
    public var cellClass: AnyClass? {
        return ModuleTableViewCell.self
    }
    
    public var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    @objc func handleToggle(of button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _module = internalModule {
            
            _tableView.handleToggle(of: _module)
        }
    }
    
    @objc func handleRoadmap(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _moduleContent = internalModule?.content {
            
            _tableView.handleLoadMarkdown(for: _moduleContent)
        }
    }
    
    public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        
        if let _cell = cell as? ModuleTableViewCell {
            
            if let _module = internalModule {
                _cell.moduleTitleLabel.text = _module.moduleTitle
                _cell.moduleBackgroundImageView.image = UIImage(named: "module-backdrop-\(_module.order)")
                _cell.moduleChevronButton.removeTarget(nil, action: nil, for: .allEvents)
                _cell.moduleChevronButton.addTarget(self, action: #selector(handleToggle(of:)), for: .primaryActionTriggered)
                
                _cell.moduleIdentifierLabel.backgroundColor = ModuleColourUtility.colour(for: _module)
                
                _cell.moduleRoadmapButton.isHidden = !shouldShowModuleRoadmap
                _cell.moduleRoadmapButton.removeTarget(nil, action: nil, for: .allEvents)
                _cell.moduleRoadmapButton.addTarget(self, action: #selector(handleRoadmap(button:)), for: .primaryActionTriggered)
                
                if let _hierarchy = _module.metadata?["hierarchy"] as? String {
                    _cell.moduleIdentifierLabel.text = _hierarchy
                }
            }
        }
    }
}

class Step: ModuleConformable, Row {
    
    var internalModule: Module?
    
    private var toolkitTableViewController: ToolkitTableViewController?
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    //ROW
    var cellClass: AnyClass? {
        return ModuleStepTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        
        if let _cell = cell as? ModuleStepTableViewCell {
            
            _cell.stepHierarchyLabel.text = internalModule?.metadata?["hierarchy"] as? String
            _cell.stepTitleLabel.text = internalModule?.moduleTitle
            _cell.stepRoadmapButton.isHidden = internalModule?.content == nil
            
            _cell.stepRoadmapButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.stepRoadmapButton.addTarget(self, action: #selector(handleRoadmap(button:)), for: .primaryActionTriggered)
        }
    }
    
    //Actions
    @objc func handleRoadmap(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _moduleContent = internalModule?.content {
            
            _tableView.handleLoadMarkdown(for: _moduleContent)
        }
    }
}

class SubStep: ModuleConformable, Row {
    
    private var toolkitTableViewController: ToolkitTableViewController?
    
    var internalModule: Module?
    
    func module() -> Module? {
        return internalModule
    }
    
    var shouldShowAddNoteButton: Bool = false
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    var cellClass: AnyClass? {
        return ModuleSubStepTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        
        if let _cell = cell as? ModuleSubStepTableViewCell {
            
            _cell.substepHierarchyLabel.text = internalModule?.metadata?["hierarchy"] as? String
            _cell.substepTitleLabel.text = internalModule?.moduleTitle
            _cell.moduleSubstepChevronButton.addTarget(self, action: #selector(handleToggle(of:)), for: .primaryActionTriggered)
 
            _cell.substepAddNoteButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.substepCheckableButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.substepAddNoteButton.addTarget(self, action: #selector(handleAddNote(button:)), for: .primaryActionTriggered)
            _cell.substepCheckableButton.addTarget(self, action: #selector(handleChecking(of:)), for: .primaryActionTriggered)
            
            
            _cell.substepAddNoteButton.setTitle("Add Note", for: .normal)
            
            if let moduleIdentifier = internalModule?.identifier {
                if ProgressManager().note(for: moduleIdentifier) != nil {
                     _cell.substepAddNoteButton.setTitle("Edit Note", for: .normal)
                }
            }
            
            _cell.substepAddNoteButton.isHidden = !shouldShowAddNoteButton
            _cell.substepButtonContainerStackView.isHidden = !shouldShowAddNoteButton
            
            if let _moduleIdentifier = internalModule?.identifier {
                _cell.substepCheckableButton.isSelected = ProgressManager().checkState(for: _moduleIdentifier)
            }
        }
    }
    
    @objc func handleToggle(of button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _module = internalModule {
            
            _tableView.handleToggle(of: _module)
        }
    }
    
    @objc func handleChecking(of checkView: UIButton) {
        
        if let _moduleIdentifier = internalModule?.identifier {
            ProgressManager().toggle(moduleIdentifier: _moduleIdentifier)
            
            checkView.isSelected = !checkView.isSelected
        }
    }
    
    //Actions
    @objc func handleRoadmap(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _moduleContent = internalModule?.content {
            
            _tableView.handleLoadMarkdown(for: _moduleContent)
        }
    }
    
    @objc func handleAddNote(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let internalModule = internalModule {
            
            _tableView.addNote(for: internalModule)
        }
    }
}

class Tool: ModuleConformable, Row {
    
    var internalModule: Module?
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    var cellClass: AnyClass? {
        return ToolTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        if let _cell = cell as? ToolTableViewCell {
            
            _cell.toolTitleLabel.text = internalModule?.moduleTitle
            
            if let _firstAttachment = internalModule?.attachments?.first {
                _cell.toolDescriptionLabel.text = _firstAttachment.description
                _cell.toolImageView.image = _firstAttachment.mimeImage()
            }
            
            _cell.toolCriticalToolButton.isHidden = true
            _cell.criticalToolStackView.isHidden = true
            
            if let _criticalTool = internalModule?.metadata?["critical_path"] as? Bool {
                if _criticalTool {
                   _cell.toolCriticalToolButton.isHidden = false
                
                    _cell.criticalToolStackView.isHidden = false
                }
            }
            
            _cell.toolCheckableButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.toolCheckableButton.addTarget(self, action: #selector(handleChecking(of:)), for: .primaryActionTriggered)
            
            if let _moduleIdentifier = internalModule?.identifier {
                _cell.toolCheckableButton.isSelected = ProgressManager().checkState(for: _moduleIdentifier)
            }
        }
    }
    
    @objc func handleChecking(of checkView: UIButton) {
        
        if let _moduleIdentifier = internalModule?.identifier {
            ProgressManager().toggle(moduleIdentifier: _moduleIdentifier)
            
            checkView.isSelected = !checkView.isSelected
        }
    }
}
