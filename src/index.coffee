# Description
#   Verifica si un email ha sido comprometido en alguna ruptura de seguridad
#
# Dependencies:
#   "filesize": "^3.1.3",
#   "moment": "^2.10.6"
#
# Commands:
#   hubot hesidohackeado <email> -> Hay 1 registro para <email> ...
#
# Author:
#   lgaticaq

filesize = require("filesize")
moment = require("moment")

module.exports = (robot) ->
  emailPattern = "([\\w.-]+@[\\w.-]+\\.[a-zA-Z.]{2,6})"
  regex = new RegExp("hesidohackeado #{emailPattern}", "i")
  robot.respond regex, (res) ->
    email = res.match[1]
    url = "https://hesidohackeado.com/api"
    query = {q: email}
    robot.http(url).query(query)
      .header("Accept", "application/json")
      .get() (err, response, body) ->
        if err
          res.reply "ocurrio un error al consultar el email"
          robot.emit "error", err, res
          return
        data = JSON.parse body
        if data.status is "badsintax"
          res.reply "Email mal ingresado"
        else if data.status is "notfound"
          res.send ":tada: Felicidades no hay registros para #{email} :tada:"
        else if data.status is "found"
          text = ""
          if data.results is 1
            text += ">Hay *1* registro para #{email}"
          else
            text += ">Hay *#{data.results}* registros para #{email}"
          format = "YYYY-MM-DD HH:mm:ss"
          for d in data.data
            text += ">*Fecha*: #{moment(d.date_leaked).format(format)}\n"
            text += ">*Título*: #{d.title}\n"
            text += ">*Autor*: #{d.author}\n"
            text += ">*Sitio*: #{d.source_provider}\n"
            text += ">*Red*: #{d.source_network}\n"
            text += ">*Emails*: #{d.emails_count}\n"
            text += ">*Tamaño*: #{filesize(d.source_size)}\n"
            text += ">*Enlace*: #{d.details}\n\n"
          res.send text
        else
          res.reply "La respuesta no es la esperada"
