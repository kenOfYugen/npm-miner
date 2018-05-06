regex = ///
  # Match header metadata
  [^]*?{"total_rows":(.*?),"offset":(.*?),"rows":\[
  # or match package's data
  |{"id":"(.*?)","key":"(.*?)","value":({[^]*?}+)}
///g

url = 'https://skimdb.npmjs.com/registry/_design/scratch/_view/byField'

module.exports = {regex, url}
