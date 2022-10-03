1. git clone https://github.com/ubolonton/emacs-module-rs
2. cargo build
3. ln -svf target/debug/libemacs_rs_module.so rs-module.so
4. (add-to-list 'load-path "path-to rs-module.so")
5. (require 'rs-module)
6. (rs-module/load "full/path/to/rust-lib/module.so")
