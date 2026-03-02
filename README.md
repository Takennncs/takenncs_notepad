# Takenncs notepad

A modern, feature-rich notepad system for FiveM (QBCore) with ox_inventory, ox_lib support. Create, edit, lock, and duplicate notes with a beautiful UI.

## ✨ Features

- 📝 **Rich Text Editing** - Full formatting support (bold, italic, lists, headers, colors)
- 🔒 **Lock System** - Lock notes to prevent editing (perfect for official documents)
- 📋 **Duplicate Notes** - Create copies of existing notes
- 🖼️ **Image Support** - Insert images via URL
- 💾 **SQL Storage** - All notes are permanently saved in database
- 🎨 **Modern UI** - Clean dark theme with smooth animations
- 🎯 **ox_target Support** - Use items directly from target system
- 📦 **ox_inventory Integration** - Full metadata support
- 🌐 **Multilingual UI** - Interface in Estonian (easily translatable)

## 📋 Dependencies

- [QBCore](https://github.com/qbcore-framework)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)

## 🚀 Installation

1. **Download the resource**
   - Place `takenncs_notepad` in your `resources` folder

2. **Configure ox_inventory**
   - Add the item to your `ox_inventory/data/items.lua`:

```
['takenncs_notepad'] = {
    label = 'Märkmik',
    weight = 100,
    stack = false,
    degrade = 0,
    description = 'Write down your thoughts',
    client = {
        export = 'takenncs_notepad.openEditor',
        image = 'notepad.png',
    }
}
````

## SQL

```
CREATE TABLE IF NOT EXISTS `sticky_notes` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(50) NOT NULL,
    `slot` int(11) NOT NULL,
    `title` varchar(255) DEFAULT 'Untitled note',
    `content` longtext,
    `locked` tinyint(1) DEFAULT 0,
    `last_edited` bigint(20) DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_slot` (`identifier`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
````


