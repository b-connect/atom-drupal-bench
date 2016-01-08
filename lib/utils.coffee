fs = require 'fs'
{join} = require 'path'
async = require 'async'

readSubdirs = (rootDir, cb)->
  fs.readdir(rootDir, (err, files) ->
    dirs = []
    for index in [0..files.length]
      file = files[index]
      if file[0] != '.'
        filePath = rootDir + '/' + file
        fs.stat(filePath, (err, stat) ->
          if stat.isDirectory()
            dirs.push(file)
          if files.length == (index + 1)
            return cb(dirs)
        )
  )

exports.findDrupal = (cb) ->
  paths = atom.project.getPaths()
  drupals = []

  paths.forEach((v)->
    if fs.existsSync(v + '/core/misc/drupal.js') &&
       fs.existsSync(v + '/composer.json')
      drupals.push(v)
  )

  cb drupals
