Finder = require 'fs-finder'
fs = require 'fs'
path = require 'path'
yaml = require 'yamljs'
Datastore = require 'nedb'
md5 = require 'md5'
touch = require 'touch'
filewalker = require 'filewalker'
Storage = require './storage'
{Emitter} = require 'event-kit'

DrupalService =
  ds: {}
  running: false
  rerun: false
  emitter: new Emitter
  options : {
    maxPending: 3,
    maxAttempts: 4,
    attemptTimeout: 3000,
  }

  onDidIndexed: (callback) ->
    @emitter.on 'did-indexed', callback

  getDataStore:(projectPath,cb) ->
    _this = @

    packagePath = atom.packages.resolvePackagePath("atom-drupal-bench")
    id = md5(projectPath)
    indexPath = path.join(packagePath,id) + '.index'

    if !_this.ds[projectPath]
      touch.sync(indexPath)
      ds = new Datastore({
        filename: indexPath , autoload: true
      })
      _this.ds[projectPath] = ds
      cb ds
    else
      cb(_this.ds[projectPath])

  index:(path) ->

    if @running == true
      return

    @running = true
    _this = @
    emitter = @emitter

    options = @options
    options.matchRegExp= /\.(module)$/

    console.time('atom_drupal_bench_index')

    for i,project of atom.project.getDirectories()
      _this.getDataStore(project.path,(ds) ->
        filewalker(project.path,options)
          .on('file', (file,stats) ->
            _this.indexModule(project.path,file,ds)
          )
          .on('done', () ->
            console.timeEnd('atom_drupal_bench_index')
            _this.running = false
            emitter.emit('did-indexed', { project : project })
          )
          .walk()
      )

  indexPath:(path) ->

  destroy: ->
    @emitter.dispose() # remove subscribers on destruction

  indexModule: (projectPath,moduleFile,ds) ->
    modulePath = path.dirname moduleFile
    moduleName = path.basename moduleFile,'.module'
    fullModulePath = path.join projectPath, modulePath

    options = @options
    options.matchRegExp= /\.(yml)$/

    filewalker(fullModulePath,options)
      .on('stream', (rs, p, s, fullPath) ->
        type = path.basename(fullPath,'.yml').split('.').slice(1).join('.')
        fileData = []
        rs.on('data', (data) ->
          fileData.push(data)
        )
        rs.on('end',() ->
          try
            #console.time('atom_drupal_bench_index_' + fullPath)
            result = yaml.parse(fileData.toString())
            if result
              result.index_file_path = modulePath
              result.index_module_name = moduleName
              result.index_doc_type = (type) ? type : '_global'

              ds.update({ index_file_path: modulePath },
                        result,
                        { upsert: true }
              )
              typeDescriptor = {
                index_doc_type: 'types',
                title : result.index_doc_type
              }
              ds.update(typeDescriptor,
                        typeDescriptor,
                        { upsert: true }
              )
          finally
            result = null
        )
      )
      .on('done', () ->
      )
      .walk()

module.exports = DrupalService
