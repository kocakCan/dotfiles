local config = require("plugins.configs.lspconfig")
local base = require("plugins.configs.lspconfig")
local on_attach = config.on_attach
local capabilities = config.capabilities
local util = require "lspconfig/util"
local lspconfig = require("lspconfig")

local servers = {
  "pyright",
  "ruff_lsp",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {"python"},
  })
end

lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvier = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}
