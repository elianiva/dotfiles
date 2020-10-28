local fn = vim.fn

local function get_buffers()
  local buffers = fn.getbufinfo({ bufloaded = 1, buflisted = 1 })
  local buffer_names = {}

  for _, v in pairs(buffers) do
    table.insert(buffer_names, v.name)
  end

  return buffer_names
end

local function delete_empty_buffers()
  local buffers = fn.filter(fn.range(1, fn.bufnr('$')), [[buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])]])
  if not fn.empty(buffers) then
    vim.cmd(string.format('bd %s', fn.join(buffers, ' ')))
  end

  return buffers
end

function delete_buffers()
  for _, v in pairs(get_buffers()) do
    if (string.match(v, fn.bufname("%"))) then
      -- do nothing
    else
      delete_empty_buffers()
      vim.cmd(string.format('bd %s', v))
    end
  end
end
