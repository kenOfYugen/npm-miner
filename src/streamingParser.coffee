streamingParser = (spec) ->
  {stream, regex, handleData, cb} = spec

  lastIndex = undefined
  buffer = undefined

  processChunk = (chunk) ->
    stream.pause()

    string = chunk.toString()
    if buffer? then string = buffer + string
    buffer = undefined

    match = undefined
    while (match = regex.exec(string))?
      regex.lastIndex += 1 if match.index is regex.lastIndex
      handleData match
      lastIndex = match.index # store index externally

    # Store the remaining part of the chunk by removing the
    # first '{' so that the same package will not be matched
    # again by the regular expression
    buffer = string[lastIndex + 1..]

    lastIndex = undefined

    stream.resume()

  cleanup = ->
    stream.removeListener 'data', processChunk
    stream.removeListener 'close', cleanup
    cb null

  handleError = (err) -> cleanup(); cb Error err

  parse = ->
    stream
    .on 'error', handleError
    .on 'data', processChunk
    .on 'close', cleanup

  {parse}

module.exports = streamingParser
