local M = {}

function M.verbose()
   local base = MiniTest.gen_reporter.stdout()
   local cases

   return {
      start = function(all_cases)
         cases = all_cases
         base.start(all_cases)
         io.stdout:write("\n")
      end,
      update = function(case_num)
         local case = cases[case_num]
         local state = type(case.exec) == "table" and case.exec.state or nil
         if not state or not (state:find("^Pass") or state:find("^Fail")) then
            return
         end
         io.stdout:write(("%-16s %s\n"):format(state, table.concat(case.desc, " > ")))
      end,
      finish = base.finish,
   }
end

return M
