# TableView

**TableView** is a declarative and extensible wrapper around `UITableView` that simplifies building complex table-based UIs.

It provides:
- section-based data modeling
- strongly-typed cell configuration
- built-in diffing & smart reloads
- batch updates API
- callbacks instead of delegate boilerplate

---

## ✨ Features

- Declarative sections & items
- Automatic cell and header/footer registration
- Smart reload (minimal updates without full reload)
- Built-in debounce for reload operations
- Batch updates (insert/delete/move/reload)
- Swipe actions support
- Scroll callbacks
- Keyboard-aware layout handling
- No need to implement `UITableViewDelegate` / `UITableViewDataSource`

---

## 🚀 Quick Start

### 1. Create items

```swift
let item = TableViewCellItem(
    reuseIdentifier: "Cell",
    cellType: MyCell.self
)
```

---

### 2. Create section

```swift
let section = TableViewSection(
    number: 0,
    items: [item]
)
```

---

### 3. Setup TableView

```swift
let tableView = TableView()
tableView.set(sections: [section])
```

---

### 4. Configure cells

```swift
tableView.configCellCallback = { cell in
    guard let cell = cell as? MyCell else { return }
    // configure UI
}
```

---

### 5. Handle selection

```swift
tableView.selectItemCallback = { item in
    print("Selected:", item)
}
```

---

## 🧱 Core Concepts

### TableViewSection

Represents a section:

```swift
TableViewSection(
    number: Int,
    items: [TableViewCellItem],
    headerItem: TableSupplementaryItem?,
    footerItem: TableSupplementaryItem?
)
```

---

### TableViewCellItem

Represents a row:

```swift
TableViewCellItem(
    reuseIdentifier: String,
    cellType: AnyClass
)
```

---

### TableViewCell

Base class for cells:

```swift
class MyCell: TableViewCell {
    override func setup() {}
    override func setupSizes() {}
}
```

---

### Headers / Footers

```swift
let header = TableSupplementaryItem(
    reuseIdentifier: "Header",
    viewType: MyHeaderView.self,
    height: 44
)
```

---

## 🔄 Updating Data

### Set sections

```swift
tableView.set(sections: newSections)
```

---

### Force reload

```swift
tableView.reload(with: newSections)
```

---

## ⚡ Smart Reload

- Automatically detects:
  - section changes
  - row count changes
  - header/footer changes
- Updates only visible cells when possible
- Falls back to full reload when needed

---

## 🧪 Batch Updates API

### Delete rows

```swift
tableView.deleteRows(indexPaths: [indexPath]) { success in }
```

---

### Insert rows

```swift
tableView.insert(items: [
    TableRawEditEntity(indexPath: indexPath, item: item)
]) { success in }
```

---

### Reload rows

```swift
tableView.reload(items: [
    TableRawEditEntity(indexPath: indexPath, item: newItem)
], with: .automatic) { success in }
```

---

### Move row

```swift
tableView.moveRow(at: from, to: to) { success in }
```

---

### Sections

```swift
tableView.insertSections([
    TableSectionEditEntity(index: 0, section: section)
]) { success in }
```

---

## ✋ Swipe Actions

```swift
item.leadingActions = [
    UIContextualAction(style: .normal, title: "Edit") { _, _, _ in }
]

item.trailingingActions = [
    UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in }
]
```

---

## 🧠 Callbacks

```swift
tableView.selectItemCallback
tableView.configCellCallback
tableView.startScrollCallback
tableView.scrollCallback
tableView.dragFinishCallback
tableView.reloadCallback
tableView.editCallback
```

---

## 📜 Scrolling

```swift
tableView.scrollAnimatedToRow(
    at: indexPath,
    at: .top
) {
    print("Finished scrolling")
}
```

---

## ⌨️ Keyboard Handling

Automatically adjusts:
- `contentInset`
- scroll indicators

Disable if needed:

```swift
tableView.isKeyboardSizeSensitive = false
```

---

## 🔊 Interaction Sound

```swift
tableView.selectionSound = UISoundDefault.tap
```

---

## ⚙️ Advanced

### Debounced reload

```swift
let tableView = TableView(debounceDelay: 0.3)
```

---

### Auto layout header/footer

```swift
tableView.layoutTableHeaderView()
tableView.layoutTableFooterView()
```

---

## ⚠️ Important Notes

- Do NOT call:
```swift
reloadData()
insertRows()
deleteRows()
```
directly — use provided API instead

- All updates go through internal queue for consistency

---

## 💡 Use Cases

- Complex feeds
- Chat UIs
- Settings screens
- Dashboards
- Any dynamic table-based UI

---

## 📱 Platform

- iOS (UIKit)

---

## 📄 License

MIT
