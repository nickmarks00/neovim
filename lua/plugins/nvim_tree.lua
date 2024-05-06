return {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeOpen",
    keys = {
        { "<leader>pv", ":NvimTreeFindFile<cr>", mode = "n", desc = "Explorer tree",          silent = true },
        { "<leader>pt", ":NvimTreeToggle<cr>",   mode = "n", desc = "Explorer tree toggle",   silent = true },
        { "<leader>pc", ":NvimTreeCollapse<cr>", mode = "n", desc = "Explorer tree collapse", silent = true },
    },
    init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.g.nvim_tree_follow = 1
        vim.cmd([[
            :hi! link NvimTreeExecFile NONE
        ]])

        function my_on_attach(bufnr)
            local api = require("nvim-tree.api")
            vim.keymap.set("n", "l", api.node.open.edit, { desc = "Open folder/file" })
            vim.keymap.set("n", "h", api.node.navigate.parent_close, { desc = "Close parent folder" })

            api.config.mappings.default_on_attach(bufnr)
        end
    end,
    opts = {
        on_attach = my_on_attach,
        hijack_cursor = true,
        sort_by = "case_sensitive",
        git = {
            enable = false,
            ignore = false,
        },
        diagnostics = {
            enable = true,
            show_on_dirs = true,
            show_on_open_dirs = true,
            icons =
            {
                hint = '',
                info = "",
                warning = "",
                error = ""
            }
        },
        view = {
            width = 35,
            relativenumber = true,
            signcolumn = "yes",
            cursorline = false,
        },
        renderer = {
            group_empty = true,
            root_folder_modifier = ":t",
            highlight_git = "all",
            highlight_diagnostics = "icon",
            highlight_opened_files = "all",
            highlight_modified = "name",
            indent_markers = {
                enable = true
            },
            icons = {
                modified_placement = "before",
                git_placement = "after",
                show = {
                    folder_arrow = false,
                    modified = true,
                },
                glyphs = {
                    default = "",
                },
            },
        },
        filters = {
            custom = { "^\\.git", "^\\node_modules" }
        },
        modified = {
            enable = true,
        },
        actions = {
            change_dir = {
                restrict_above_cwd = true,
            },
            open_file = {
                resize_window = true
            }
        },
    }
}
