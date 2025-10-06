# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the Lazycat Emacs configuration by AndyStewart - a comprehensive Emacs setup with extensive customizations, extensions, and key bindings. The configuration is designed for advanced Emacs users with deep customizations for productivity.

## Repository Structure

- **`site-lisp/`** - Main configuration directory
  - **`config/`** - All configuration files (init-*.el files)
  - **`extensions/`** - Third-party Emacs packages and extensions (git submodules)
  - **`snippets/`** - YASnippet templates organized by mode
  - **`template/`** - File templates
  - **`rs-module/`** - Rust modules for Emacs integration
- **`site-start.el`** - Entry point that sets up load paths and loads the main configuration
- **`update_submodule.py`** - Python script to update git submodules

## Setup and Installation

### Initial Setup
```bash
# Clone repository
git clone https://github.com/manateelazycat/lazycat-emacs.git

# Update all submodules
python update_submodule.py

# Create symlink (adjust path as needed)
sudo ln -s /home/username/lazycat-emacs/site-lisp /usr/share/emacs/lazycat

# Copy site-start.el to emacs directory
sudo cp /home/username/lazycat-emacs/site-start.el /usr/share/emacs/site-lisp/
```

### Updating Extensions
```bash
# Update all git submodules to latest versions
git submodule foreach git pull --rebase
```

## Key Configuration Files

### Core Configuration
- **`site-lisp/config/init.el`** - Main configuration loader with performance optimizations
- **`site-lisp/config/init-key.el`** - All key bindings (study this file to understand the setup)
- **`site-lisp/config/init-font.el`** - Font configuration
- **`site-lisp/config/init-mode.el`** - Mode configurations
- **`site-lisp/config/init-lsp-bridge.el`** - LSP Bridge setup for language support

### Important Extensions
- **LSP Bridge** (`site-lisp/extensions/lspbridge/`) - Language server integration
- **EAF** (`site-lisp/extensions/emacs-application-framework/`) - Application framework
- **Holo Layer** (`site-lisp/extensions/holo-layer/`) - Desktop integration layer
- **Awesome Tray** (`site-lisp/extensions/awesome-tray/`) - Modeline replacement
- **Rime** (`site-lisp/extensions/emacs-rime/`) - Chinese input method

## Architecture

### Loading Strategy
The configuration uses a sophisticated loading strategy:
1. **Performance optimizations** - Temporarily increases GC threshold during startup
2. **Lazy loading** - Many extensions are loaded with idle timers to speed startup
3. **Conditional loading** - Platform-specific configurations (cocoa/linux)
4. **Recursive load path setup** - `site-start.el` recursively adds subdirectories to load-path

### Key Binding System
- Uses `lazy-load-global-keys` and `lazy-load-set-keys` for efficient key binding
- Prefix key `C-z` for many custom functions
- Super key (`s-`) extensively used for shortcuts
- Mac-specific Option/Command key swapping when on Cocoa

### Extension Management
- Most extensions are git submodules in `site-lisp/extensions/`
- Extensions organized by category (languages/, etc.)
- Custom configurations in `site-lisp/config/init-*.el` files

## Development Commands

### Core Development
```bash
# Start Emacs with this configuration
emacs

# Check for missing treesitter grammars
# In Emacs: M-x treesit-install-language-grammar
```

### Submodule Management
```bash
# Update all submodules to latest
python update_submodule.py

# Manual submodule update
git submodule foreach git pull --rebase

# Initialize new submodules
git submodule update --init --recursive
```

## Dependencies

### Required System Packages (Arch Linux)
```bash
# Core Emacs with tree-sitter
sudo pacman -S emacs-git tree-sitter

# Fonts
sudo pacman -S wqy-microhei
# Also need TsangerJinKai03-6763 font for Rime

# Additional dependencies for EAF, holo-layer, deno, key-echo
```

### Python Dependencies
- Some extensions require Python packages (check individual extension requirements)

## Key Features to Understand

### Input Methods
- **Rime integration** for Chinese input (`init-rime.el`)
- **Insert translated name** - Converts Chinese to English variable names (`C-z ,` and `C-z .`)

### Web Integration
- **Popweb** for web translation and dictionary (`C-z ;` and `C-z y`)
- **EAF** for web browsing and applications within Emacs

### Navigation and Search
- **Avy** for quick navigation
- **Custom grep integration** with beagrep
- **One-key menus** for organized shortcuts

### Development Tools
- **LSP Bridge** for modern language server support
- **Tree-sitter** for syntax highlighting
- **YASnippet** with extensive template library

## Configuration Patterns

When modifying this configuration:
1. **Follow the modular pattern** - Create `init-*.el` files in `site-lisp/config/`
2. **Use lazy loading** - Wrap expensive operations in idle timers or lazy-load functions
3. **Respect the key binding hierarchy** - Check `init-key.el` before adding new bindings
4. **Test performance impact** - The configuration is optimized for fast startup

## Troubleshooting

### Common Issues
- **"No available parser for this buffer"** - Run `M-x treesit-install-language-grammar`
- **Slow startup** - Check if new configurations are properly lazy-loaded
- **Missing dependencies** - Ensure all submodules are updated and system dependencies installed

### Debug Configuration
- Uncomment benchmark-init lines in `init.el` to profile startup time
- Check `*Messages*` buffer for loading errors