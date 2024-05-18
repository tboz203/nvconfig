-- more filetype detection

-- vim.cmd.echom("'added the requirements filetype crap'")

vim.filetype.add({
  filename = {
    ["requirements.in"] = "requirements",
    ["requirements-dev.in"] = "requirements",
    ["requirements-dev.txt"] = "requirements",
  },
  -- pattern = {
  --   ["requirements.*%.in"] = "requirements",
  -- },
})
