test = require 'tape'

test.skip "Remote stream parsing", (assert) ->
  {get} = require 'https'

  {url, regex} = require '../src/config'
  limited = "#{url}?limit=10"

  {total_rows, offset, rows} = require "#{__dirname}/npm.json"
  ids = (row.id for row in rows)

  streamingParser = require '../src/streamingParser'

  request = get limited, (res) ->
    assert.fail "#{res.statusCode}" if res?.statusCode isnt 200
    parser = streamingParser {
      stream: res
      regex
      handleData: ([match, totalRows, offs, id, key, value]) ->
        if totalRows?
          assert.true ((Number totalRows) > total_rows) , "Live total rows parsed"
        if offs?
          assert.true ((Number offs) is offset), "Live offset parsed"
        if id?
          assert.true id in ids, "Live parsed #{id}"
          ids[ids.indexOf id] = undefined
      cb: (err) ->
        assert.error err, "Parsing didn't error"
        assert.true (ids.every (v) -> v is undefined), "All modules parsed live"
    }

    parser.parse()

  request.on 'error', (err) -> assert.fail err.message
  request.on 'close', -> assert.end()
