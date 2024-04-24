return {

    -- EDITING AND KEYBINDINGS
    "jiangmiao/auto-pairs",
    "windwp/nvim-ts-autotag",
    "tpope/vim-sleuth",

    -- APPEARANCE
    "folke/tokyonight.nvim",
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require("colorizer").setup()
        end,
    },
    "onsails/lspkind.nvim",

    { "nvim-treesitter/nvim-treesitter", build = ':TSUpdate' },

    -- GIT PLUGINS
    "tpope/vim-rhubarb",

    -- LATEX
    {
        'lervag/vimtex',
        ft = "tex"
    },

    -- Go
    -- use {
    --     'olexsmir/gopher.nvim',
    --     ft = 'go',
    --     config = function() require("gopher").setup() end,
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "nvim-treesitter/nvim-treesitter"
    --     },
    --     build = function() vim.cmd [[silent! GoInstallDeps]] end
    -- }
    {
        'ray-x/go.nvim',
        ft = "go"

    },

    -- Rust
    {
        "rust-lang/rust.vim",
        ft = "rust",
        config = function()
            vim.g.rustfmt_autosave = 1
        end
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = { 'rust' },
    },
    {
        'saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        ft = "rust",
        config = function()
            require('crates').setup()
        end,
    },

    { "mfussenegger/nvim-jdtls",         ft = "java" },

    -- DEBUGGER
    { "rcarriga/cmp-dap",                ft = { "python", "cpp", "javascript" } },
    {
        "rcarriga/nvim-dap-ui",
        ft = { "python", "cpp", "javascript" },
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
    },

    'folke/neovim',

    -- Beancount
    { "crispgm/cmp-beancount",     ft = "beancount" },
    { "nathangrigg/vim-beancount", ft = "beancount" },

}
