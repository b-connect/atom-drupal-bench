class Storage
  ds : null
  constructor:(@ds) ->
    @ds.onDidIndexed(()->
      console.log 'Event emitteded'
    )

  getTypes:(cb) ->
    @ds.find({ index_doc_type: 'types' },(err, docs) ->
      cb(err,docs)
    )

module.exports = Storage
