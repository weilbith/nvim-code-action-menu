local settings = {
  source = 'nvim_lsp', -- nvim_lsp | coc
  window_options = {}, -- additional options for code-aciton-menu windows
  window_focusable = true,
}

local function setup(opts)
  settings = vim.tbl_extend('force', settings, opts or {})

  if vim.g.coc_service_initialized == 1 and settings.source ~= 'coc' then
    vim.notify(
      ('Detected that you are using COC, but the source is %s'):format(
        settings.source
      ),
      vim.log.levels.WARN
    )
  end
end

return setmetatable({ setup = setup }, {
  __index = function(_, key)
    return settings[key]
  end,
})
