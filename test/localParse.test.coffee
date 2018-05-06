test = require 'tape'

test "Local file stream parsing", (assert) ->
  {createReadStream} = require 'fs'
  streamingParser = require '../src/streamingParser'
  {regex} = require '../src/config'
  {total_rows, offset, rows} = require "#{__dirname}/npm.json"

  ids = (row.id for row in rows)

  highWaterMark = 2 * 203 * 8 #estimate of two rows in bytes
  stream = createReadStream "#{__dirname}/npm.json", {highWaterMark}

  parser = streamingParser {
    stream
    regex
    handleData: ([match, totalRows, offs, id, key, value]) ->
      if totalRows? then assert.equal "#{total_rows}", totalRows, "Total rows parsed"
      if offs? then assert.equal "#{offset}", offs, "Offset parsed"
      if id?
        assert.true id in ids, "Parsed #{id}"
        ids[ids.indexOf id] = undefined
    cb: (err) ->
      assert.error err, "Parsing didn't error"
      assert.true (ids.every (v) -> v is undefined), "All modules parsed"
  }

  parser.parse()

  assert.end()
