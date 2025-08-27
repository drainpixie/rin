(local {: g : opt : colorscheme} (require :core))
(local indent-width 2)

(g :mapleader " ")
(opt :bg :light)
(colorscheme :default)

;; indentation
(opt :expandtab)
(opt :smartindent)
(opt :tabstop indent-width)
(opt :shiftwidth indent-width)
(opt :softtabstop indent-width)

;; line number
(opt :number)
(opt :relativenumber)

;; whitespace
(opt :list)
(opt :listchars
          "eol:↴,tab:→→,trail:↴,extends:↴,precedes:↴,nbsp:·")
