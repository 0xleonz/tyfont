local augroup = vim.api.nvim_create_augroup("Tyfont", { clear = true })

-- Función principal para ejecutar el comando con Telescope
local function main()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("Telescope no está instalado", vim.log.levels.ERROR)
    return
  end

  -- Usa el comando `typst fonts` para listar las fuentes
  local handle = io.popen("typst fonts")
  if not handle then
    vim.notify("Error ejecutando `typst fonts`", vim.log.levels.ERROR)
    return
  end
  local fonts = handle:read("*a")
  handle:close()

  -- Convierte la salida en una tabla
  local font_list = {}
  for line in fonts:gmatch("[^\r\n]+") do
    table.insert(font_list, line)
  end

  -- Verifica si `font_list` está vacío
  if #font_list == 0 then
    vim.notify("No se encontraron fuentes", vim.log.levels.WARN)
    return
  end

  -- Usa Telescope para seleccionar una fuente
  require("telescope.pickers").new({}, {
    prompt_title = "Select a Font",
    finder = require("telescope.finders").new_table({
      results = font_list, -- Ajuste correcto aquí
    }),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local actions = require("telescope.actions")
        local actions_state = require("telescope.actions.state")

        local selection = actions_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection then
          vim.api.nvim_put({ selection.value }, "", true, true) -- Selección corregida
        end
      end)
      return true
    end,
  }):find()
end

-- Configuración para agregar el mapeo
local function setup()
  -- Autocomando solo para mostrar un mensaje al iniciar (puedes eliminarlo si no es necesario)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    desc = "Mensaje de bienvenida del plugin Tyfont",
    once = true,
    callback = function()
      print("Tyfont plugin activo")
    end,
  })

  -- Asignar el mapeo a <leader>F
  vim.api.nvim_set_keymap("n", "<leader>F", "<cmd>lua require('tyfont').main()<CR>", { noremap = true, silent = true })
end

return { setup = setup, main = main }

