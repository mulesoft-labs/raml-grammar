repl = require('repl')
{suggestionTree} = require('./main')

stack = []

stateAsString = (state) ->
  if typeof state == 'object'
    (key for key, value of state).join(' ')
  else
    state

repl.start
  prompt: '>',
  input: process.stdin,
  output: process.stdout,
  eval: (cmd, ctx, filename, callback) ->
    cmd = cmd.replace(/\n|\(|\)/g, '')

    if cmd == 'up'
      if stack.length == 0
        console.log 'Top level reached'
        return
      suggestionTree = stack.pop()
      callback(stateAsString(suggestionTree))
      return

    stack.push(suggestionTree)
    suggestionTree = (suggestionTree[cmd] or suggestionTree['StringNode'])()
    callback(stateAsString(suggestionTree))


