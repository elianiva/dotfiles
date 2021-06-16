(module mod._statusline
        {require {icons :nvim-web-devicons}})

(def- M {})
(def active-sep :blank)

;; separators
(tset M :separators
      {:arrow   [">" "<"]
       :rounded [")" "("]})

;; colours definition
(tset M :colors
      {:active       ""
       :active       "%#StatusLine#"
       :inactive     "%#StatuslineNC#"
       :mode         "%#Mode#"
       :mode-alt     "%#ModeAlt#"
       :git          "%#Git#"
       :git-alt      "%#GitAlt#"
       :filetype     "%#Filetype#"
       :filetype-alt "%#FiletypeAlt#"
       :line-col     "%#LineCol#"
       :line-col-alt "%#LineColAlt#"})

(tset M :trunc_width
      (setmetatable
        {:git_status 90
         :filename 140}
        {:__index (fn [] 80)}))

(tset M :is-truncated
      (fn [_ width]
        (let [current-width (vim.api.nvim_win_get_width 0)]
          ((< current-width width)))))

(tset M :modes
      (setmetatable
        {:n  "N"
         :no "N·P"
         :v  "V"
         :V  "V·L"
         "" "V·B" ;; this is not ^V, but it's , they're different
         :s  "S"
         :S  "S·L"
         "" "S·B" ;; same with this one, it's not ^S but it's 
         :i  "I"
         :ic "I"
         :R  "R"
         :Rv "V·R"
         :c  "C"
         :cv "V·E"
         :ce "E"
         :r  "P"
         :rm "M"
         "r?" "C"
         :!  "S"
         :t  "T"}
        {:__index (fn [] "U")})) ;; edge cases

(tset M :get-current-mode
      (fn [self]
        (let [current-mode (. (vim.api.nvim_get_mode) :mode)]
          (string.format " %s " (. self.modes current-mode)))))

(tset M :get-git-status
      (fn [self]
        (let [signs (or (vim.b.gitsigns_status_dict) {:head ""
                                                      :added 0
                                                      :changed 0
                                                      :removed 0})
              is-head-empty (~= signs.head "")]
          (if (: self :is-truncated self.trunc-width.git-status)
            (and is-head-empty
                 (or (string.format "  %s " (or signs.head "")) ""))
            (and is-head-empty
                 (string.format " +%s ~%s -%s |  %s "
                                (. signs :added)
                                (. signs :changed)
                                (. signs :removed)
                                (. signs :head)))))))

(tset M :get-filename
      (fn [self]
        (if (: self :is-truncated self.trunc-width.filename)
          " %<%f "
          " %<%F ")))

(tset M :get-filetype
      (fn []
        (let [file-name (vim.fn.expand "%:t")
              file-ext (vim.fn.expand "%:e")
              icon (icons.get_icon file-name file-ext {:default true})
              filetype vim.bo.filetype]
          (if (= filetype "")
            " No FT "
            (string.lower (string.format " %s %s " icon filetype))))))

(tset M :get-line-col
      (fn [] " %l:%c "))

(tset M :set-active
      (fn [self]
        (let [colors        self.colors
              mode          (.. colors.mode (: self :get-current-mode))
              mode-alt      (.. colors.mode-alt (. self.separator active-sep 1))
              git           (.. colors.git (: self :get-git-status))
              git-alt       (.. colors.git-alt (. self.separators active-sep 1))
              filename      (.. colors.inactive (: self :get-filename))
              filetype-alt  (.. colors.filetype-alt (. self.separator active-sep 2))
              line-col      (.. colors.line-col (: self :get-line-col))
              line-col-alt  (.. colors.line-col-alt (. self.separators active-sep 2))]
          (table.concat [colors.active
                         mode mode-alt
                         line-col line-colt-alt
                         "%=" filename "%="
                         filetype-alt filetype
                         git git-alt]))))

(tset M :set-inactive
      (fn [self]
        (.. self.colors.inactive "%= %F %=")))

(tset M :set-explorer
      (fn [self]
        (let [title (.. self.colors.mode "  ")
              title-alt (.. self.colors.mode-alt (. (. self.separators active-sep) 2))]
          (table.concat [self.colors.active
                         title
                         title-alt]))))

(def Statusline
  (setmetatable
    M
    {:__call (fn [statusline mode]
               (when (= mode :active)
                 (: statusline :set-active))
               (when (= mode :inactive)
                 (: statusline :set-inactive))
               (when (=mode :explorer)
                 (: statusline :set-explorer)))}))

(vim.api.nvim_exec
  "
  augroup Statusline \
  au! \
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active') \
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive') \
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline('explorer') \
  augroup END \
  " false)

