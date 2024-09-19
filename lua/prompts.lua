M = {}
local prompts = require('model.util.prompts')

function M.code_replace_fewshot(input, context)
  local surrounding_text = prompts.limit_before_after(context, 30)

  local content = 'The code:\n```\n'
    .. surrounding_text.before
    .. '<@@>'
    .. surrounding_text.after
    .. '\n```\n'

  if context.selection then -- we only use input if we have a visual selection
    content = content .. '\n\nExisting text at <@@>:\n```' .. input .. '```\n'
  end

  if #context.args > 0 then
    content = content .. '\nInstruction: ' .. context.args
  end

  local messages = {
    {
      role = 'user',
      content = content,
    },
  }

  return {
    instruction = 'You are an expert programmer. You are given a snippet of code which includes the symbol <@@>. Complete the correct code that should replace the <@@> symbol given the content. Only respond with the code that should replace the symbol <@@>. If you include any other code, the program will fail to compile and the user will be very sad.',
    fewshot = {
      {
        role = 'user',
        content = 'The code:\n```\nfunction greet(name) { console.log("Hello " <@@>) }\n```\n\nExisting text at <@@>: `+ nme`',
      },
      {
        role = 'assistant',
        content = '+ name',
      },
    },
    messages = messages,
  }
end

return M
