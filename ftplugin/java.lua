local home = os.getenv('HOME')
local jdtls = require('jdtls')


-- Helper function for creating keymaps
local function nnoremap(rhs, lhs, bufopts, desc)
    bufopts.desc = desc
    vim.keymap.set("n", rhs, lhs, bufopts)
end

local function get_hostname()
    local f = io.popen("/bin/hostname")
    local hostname = f:read("*a") or ""
    f:close()
    hostname = string.gsub(hostname, "\n$", "")
    return hostname
end


local root_markers
local root_dir
local Java_debug_plugin
local Java_path
local Jdtls_config

if get_hostname() == "7cf34dd2a0d5" then -- settings for local Amazon machine
    -- File types that signify a Java project's root directory. This will be
    -- used by eclipse to determine what constitutes a workspace
    root_markers = { "packageInfo" }
    root_dir = require('jdtls.setup').find_root(root_markers, "Config")

    Java_debug_plugin =
    "/.m2/repository/com/microsoft/java/com.microsoft.java.debug.plugin/0.53.1/com.microsoft.java.debug.plugin-0.53.1.jar"
    Java_version = "JavaSE-21"
    Java_path = "/Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home"
    Jdtls_config = "config_mac_arm"
elseif get_hostname() == "dev-dsk-nickmarx-2c-e551df06.us-west-2.amazon.com" then -- settings for cloud desktop
    root_markers = { "packageInfo" }
    root_dir = require('jdtls.setup').find_root(root_markers, "Config")

    Java_debug_plugin =
    "/.m2/repository/com/microsoft/java/com.microsoft.java.debug.plugin/0.53.1/com.microsoft.java.debug.plugin-0.53.1.jar"
    Java_version = "JavaSE-21"
    Java_path = "/usr/lib/jvm/java-21-amazon-corretto"
    Jdtls_config = "config_linux"
else -- settings for personal PC
    root_markers = { 'gradlew', 'mvnw', '.git' }
    root_dir = require('jdtls.setup').find_root(root_markers)

    Java_debug_plugin =
    "/.m2/repository/com/microsoft/java/com.microsoft.java.debug.plugin/0.50.0/com.microsoft.java.debug.plugin-0.5.0.jar"
    Java_version = "JavaSE-19"
    Java_path = home .. "/.asdf/installs/java/temurin-19.0.2+7"
    Jdtls_config = "config_linux"
end


-- eclipse.jdt.ls stores project specific data within a folder. If you are working
-- with multiple different projects, each project must use a dedicated data directory.
-- This variable is used to configure eclipse to use the directory name of the
-- current project found using the root_marker as the folder for project specific data.
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local bundles = {
    vim.fn.glob(
        home ..
        Java_debug_plugin)
}

-- add Brazil workspace folders
local ws_folders_jdtls = {}
if root_dir and get_hostname() == "7cf34dd2a0d5" then
    local file = io.open(root_dir .. "/.bemol/ws_root_folders")
    if file then
        for line in file:lines() do
            table.insert(ws_folders_jdtls, "file://" .. line)
        end
        file:close()
    end
end

vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/.m2/vscode-java-test/server/*.jar", 1), "\n"))

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- The on_attach function is used to set key maps after the language server
-- attaches to the current buffer
local on_attach = function(_, bufnr)
    -- Regular Neovim LSP client keymappings
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    ---- Java extensions provided by jdtls
    --nnoremap("<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
    --nnoremap("<space>ev", jdtls.extract_variable, bufopts, "Extract variable")
    --nnoremap("<space>ec", jdtls.extract_constant, bufopts, "Extract constant")
    --vim.keymap.set('v', "<space>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
    --   { noremap = true, silent = true, buffer = bufnr, desc = "Extract method" })
    vim.keymap.set("n", "<A-o>", jdtls.organize_imports, { desc = "Organize imports" })
    vim.keymap.set("n", "<leader>crv", jdtls.extract_variable, { desc = "Extract variable" })
    vim.keymap.set("v", "<leader>crv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
        { desc = "Extract variable" })
    vim.keymap.set("n", "<leader>crc", jdtls.extract_constant, { desc = "Extract constant" })
    vim.keymap.set("v", "<leader>crc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
        { desc = "Extract constant" })
    vim.keymap.set("v", "<leader>crm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
        { desc = "Extract method" })

    -- Extensions for vscode-java-test
    nnoremap("<leader>vc", jdtls.test_class, bufopts, "Test class (DAP)")
    nnoremap("<leader>vm", jdtls.test_nearest_method, bufopts, "Test method (DAP)")

    -- For DAP config
    require("jdtls").setup_dap()
end

local config = {
    flags = {
        debounce_text_changes = 80,
    },
    on_attach = on_attach, -- We pass our on_attach keybindings to the configuration map
    capabilities = capabilities,
    init_options = {
        bundles = bundles,
        workspaceFolders = ws_folders_jdtls
    },
    root_dir = root_dir, -- Set the root directory to our found root_marker
    -- Here you can configure eclipse.jdt.ls specific settings
    -- These are defined by the eclipse.jdt.ls project and will be passed to eclipse when starting.
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
        java = {
            format = {
                enabled = false,
                insertSpaces = true,
                tabSize = 4,
                comments = {
                    enabled = true
                },
                -- settings = {
                --     -- Use Google Java style guidelines for formatting
                --     -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
                --     -- and place it in the ~/.local/share/eclipse directory
                --     url = home .. "/.local/share/eclipse/eclipse-java-google-style.xml",
                --     profile = "GoogleStyle",
                -- },
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' }, -- Use fernflower to decompile library code
            -- Specify any completion options
            completion = {
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*"
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*", "sun.*",
                },
            },
            -- Specify any options for organizing imports
            -- sources = {
            --     organizeImports = {
            --         starThreshold = 9999,
            --         staticStarThreshold = 9999,
            --     },
            -- },
            -- How code generation should act
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                },
                hashCodeEquals = {
                    useJava7Objects = true,
                },
                useBlocks = true,
            },
            -- If you are developing in projects with different Java versions, you need
            -- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
            -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
            -- And search for `interface RuntimeOption`
            -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
            configuration = {
                runtimes = {
                    {
                        name = Java_version,
                        path = Java_path
                    },
                }
            }
        }
    },
    -- cmd is the command that starts the language server. Whatever is placed
    -- here is what is passed to the command line to execute jdtls.
    -- Note that eclipse.jdt.ls must be started with a Java version of 17 or higher
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    -- for the full list of options
    cmd = {
        Java_path .. "/bin/java",
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx4g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        -- If you use lombok, download the lombok jar and place it in ~/.local/share/eclipse
        '-javaagent:' .. home .. '/.local/share/eclipse/lombok.jar',

        -- The jar file is located where jdtls was installed. This will need to be updated
        -- to the location where you installed jdtls
        '-jar',
        vim.fn.glob(
            "/opt/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.equinox.launcher_*.jar"),

        -- The configuration for jdtls is also placed where jdtls was installed. This will
        -- need to be updated depending on your environment
        '-configuration', "/opt/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/" .. Jdtls_config,

        -- Use the workspace_folder defined above to store data for this project
        '-data', workspace_folder,
    },
}

-- Finally, start jdtls. This will run the language server using the configuration we specified,
-- setup the keymappings, and attach the LSP client to the current buffer
jdtls.start_or_attach(config)
