local uv = vim.uv or vim.loop

local M = {}

local function is_dir(path)
   local stat = uv.fs_stat(path)
   return stat ~= nil and stat.type == "directory"
end

local function is_file(path)
   local stat = uv.fs_stat(path)
   return stat ~= nil and stat.type == "file"
end

local function split_path(path)
   local parts = {}
   for part in path:gmatch("[^/]+") do
      parts[#parts + 1] = part
   end
   return parts
end

--- /a/b/c/file.cpp -> { "/a/b/c", "" }, { "/a/b", "" }, { "/a", "c" }, { "/", "b/c" }
---@param path string absolute path of a file
---@return { dir: string, sub: string }[]
function M.iterate_parents(path)
   local parts = split_path(vim.fs.dirname(path))
   local result = {}
   for k = #parts, 0, -1 do
      result[#result + 1] = {
         dir = "/" .. table.concat(parts, "/", 1, k),
         sub = table.concat(parts, "/", k + 2),
      }
   end
   return result
end

local function join(...)
   local items = vim.tbl_filter(function(item)
      return item ~= "" and item ~= "."
   end, { ... })
   return vim.fs.joinpath(unpack(items))
end

--- Find the file named "stem" (plus the mapping prefix and one of its
--- endings) in the mapping directories, searching from the file's own
--- directory and upwards.
---@param path string absolute path of the current file
---@param mapping table { dirs, endings, prefix? }
---@param stem string file name without extension
---@return string|nil
function M.find_file(path, mapping, stem)
   local folders = { "." }
   vim.list_extend(folders, mapping.dirs or {})
   local prefix = mapping.prefix or ""

   for _, parent in ipairs(M.iterate_parents(path)) do
      for _, folder in ipairs(folders) do
         local base = join(parent.dir, folder)
         if is_dir(base) then
            for _, ending in ipairs(mapping.endings or {}) do
               local candidate = join(base, parent.sub, prefix .. stem .. "." .. ending)
               if is_file(candidate) then
                  return candidate
               end
            end
         end
      end
   end
   return nil
end

--- Figure out which mapping "path" belongs to. A mapping with a prefix scores
--- higher if the file name has the prefix and lower if it does not, which makes
--- it possible to tell unit tests from other files with the same ending.
---@param path string
---@param mappings table<string, table>
---@return string|nil name
---@return table|nil mapping
function M.current_mapping(path, mappings)
   local filename = vim.fs.basename(path)
   local best_name, best_score
   for _, name in ipairs(vim.tbl_keys(mappings)) do
      local mapping = mappings[name]
      if vim.iter(mapping.endings or {}):any(function(ending)
         return vim.endswith(filename, ending)
      end) then
         local score = 1
         if mapping.prefix then
            score = score + (vim.startswith(filename, mapping.prefix) and 1 or -1)
         end
         if best_score == nil or score > best_score or (score == best_score and name < best_name) then
            best_name, best_score = name, score
         end
      end
   end
   return best_name, best_name and mappings[best_name] or nil
end

--- Find the counterpart of "path" in the mapping named "kind". If "kind" is
--- nil the counterpart is the "switch" target of the mapping "path" belongs to.
---@param path string
---@param mappings table<string, table>
---@param kind string|nil
---@return string|nil file
---@return string|nil err
function M.counterpart(path, mappings, kind)
   local _, current = M.current_mapping(path, mappings)
   if not kind then
      if not current then
         return nil, "Could not find mapping for current file"
      end
      kind = current.switch
   end

   local target = mappings[kind]
   if not target then
      return nil, ("Unknown mapping: %s"):format(tostring(kind))
   end

   local stem = vim.fn.fnamemodify(path, ":t:r")
   local file = M.find_file(path, target, stem)
   if not file then
      return nil, "Could not find a file to switch to"
   end
   return file
end

return M
