express = require 'express'
phantom = require 'phantom'

app = express()

app.get '/render', (req, res) ->
  renderPage req.query.u, (error, filename) =>
    if error
      res.send "Cant render page to PDF error:#{error}"
    else
      res.send "Download PDF at <a href='/#{filename}'>here</a>"

app.get '/:filename.pdf', (req, res) ->
  res.sendfile "./output/#{req.params.filename}.pdf"

app.listen 3000
console.log "Server is running on 3000"

renderPage = (url, callback) ->
  console.log "Try to render page at #{url}"
  phantom.create (ph) ->
    ph.createPage (page) ->

      page.viewportSize =
        width: 1024
        height: 768

      page.paperSize =
        format: 'A4'
        orientation: 'portrait'
        margin: '1cm'

      # page.zoomFactor = 100

      page.open url, (status) ->
        if status isnt 'success'
          console.log "Error rendering page"
          callback 'Unable to load the address!'
        else
          render = =>
            filename = "output-#{Date.now()}.pdf"
            page.render "output/#{filename}", ->
              console.log "Render is done"
              callback null, filename
              ph.exit()

          setTimeout render, 200

