fs = require "fs"
path = require "path"
less = require "less"

regex = 
	lessFile: /^(.*?)\.less$/

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		@files = files
		cb()
	processFile: (file, cb) ->
		self = @
		if @annex.config.files 
			return cb() unless (@annex.config.files.indexOf file) > -1
			self._parseAndWrite file, cb
		else if matches = regex.lessFile.exec file
			self._parseAndWrite file, cb
		else
			cb()
	_parseAndWrite: (file, cb) ->
		self = @
		dir = path.dirname file
		outName = path.join dir, (path.basename file, ".less") + ".css"
		parser = new less.Parser
			paths: [@annex.pathTo "."]
			filename: file
		fs.readFile (@annex.pathTo file), "utf8", (err, data) ->
			return cb err if err?
			parser.parse data, (err, tree) ->
				return cb err if err?
				self.annex.writeFile outName, tree.toCSS(compress: true), cb
module.exports = (annex) ->
	return (new AnnexHandler annex)
