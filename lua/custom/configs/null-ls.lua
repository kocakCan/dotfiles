local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require('null-ls')
local lsp = vim.lsp

-- Create capabilities without modifying immutable fields
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Optional: capabilities.offsetEncoding can be omitted to avoid warnings
-- capabilities.offsetEncoding = { "utf-8" }

local opts = {
  capabilities = capabilities,
  sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.mypy.with({
      extra_args = function()
        local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
        return { "--python-executable", virtual .. "/bin/python3" }
      end,
    }),
  },
  on_attach = function(client, bufnr)
    -- Log the supported capabilities of the attached client
    print(vim.inspect(client.server_capabilities))

    -- Check for multiple clients attached to the same buffer
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients > 1 then
      print("Warning: Multiple LSP clients attached, stopping others.")
      for _, c in ipairs(clients) do
        if c.name ~= "null-ls" then
          vim.lsp.stop_client(c.id)
          print("Stopped client: " .. c.name)
        end
      end
    end

    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.lsp.buf.format({ bufnr = bufnr })
          end
        end,
      })
    end
  end,
}

return opts
