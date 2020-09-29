-- Lightline stuff goes here
vim.g.lightline = {
    colorscheme = 'gruvbox',
    active = {
        left = {
            {'mode', 'paste'},
            {'gitstatus'},
            {'readonly', 'filename', 'modified'}
        },
        right = {
            {'linr'},
            {'fileencoding', 'filetype'}
        }
    },
    inactive = {
        left = {
            {'filepath'}
        },
        right = {}
    },
    component= {
        linr = 'Ln %l, Col %c',
        filepath = '%F'
    },
    component_function = {
        gitstatus = 'GitStatus',
    }
}

