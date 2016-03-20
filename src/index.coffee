# Description
#   Verifica si un email ha sido comprometido en alguna ruptura de seguridad
#
# Dependencies:
#   None
#
# Commands:
#   hubot hesidohackeado <email> -> Retorna listado de sitios comprometidos con el email registrado
#
# Author:
#   lgaticaq

module.exports = (robot) ->
  sendAttachment = (attachments, res) ->
    data =
      attachments: attachments
      channel: res.message.room
    robot.emit "slack.attachment", data

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
          robot.emit "error", err, response
          return
        data = JSON.parse body
        if data.status is "badsintax"
          res.reply "Email mal ingresado"
        else if data.status is "notfound"
          res.send ":tada: ¡Felicidades! No hay registros para #{email} :tada:"
        else if data.status is "found"
          if data.results is 1
            text = "Hay 1 registro para #{email}"
          else
            text = "Hay #{data.results} registros para #{email}"
          format = "YYYY-MM-DD HH:mm:ss"
          fields = data.data.map (x) ->
            title: x.title
            value: "Fecha: #{x.date_leaked.substr(0, 10)}"
            short: true
          attachments =
            fallback: text
            text: text
            fields: fields
          sendAttachment attachments, res
        else
          res.reply "La respuesta no es la esperada"
