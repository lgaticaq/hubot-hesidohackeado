// Description
//   Verifica si un email ha sido comprometido en alguna ruptura de seguridad
//
// Dependencies:
//   None
//
// Commands:
//   hubot hesidohackeado <email> -> Retorna listado de sitios comprometidos
//
// Author:
//   lgaticaq

'use strict'

module.exports = robot => {
  const emailPattern = '([\\w.-]+@[\\w.-]+\\.[a-zA-Z.]{2,6})'
  const regex = new RegExp(`hesidohackeado ${emailPattern}`, 'i')
  robot.respond(regex, res => {
    const q = res.match[1]
    robot
      .http('https://hesidohackeado.com/api')
      .query({ q })
      .header('Accept', 'application/json')
      .get()((err, response, body) => {
        if (err) {
          res.reply('ocurrio un error al consultar el email')
          robot.emit('error', err, response)
          return
        }
        const data = JSON.parse(body)
        if (data.status === 'notfound') {
          return res.send(
            `:tada: ¡Felicidades! No hay registros para ${q} :tada:`
          )
        } else if (data.status === 'found') {
          let text
          if (data.results === 1) {
            text = `Hay 1 registro para ${q}`
          } else {
            text = `Hay ${data.results} registros para ${q}`
          }
          const fields = data.data.map(x => ({
            title: x.title,
            value: `Fecha: ${x.date_leaked.substr(0, 10)}`,
            short: true
          }))
          const options = {
            as_user: true,
            link_names: 1,
            attachments: [
              {
                fallback: text,
                color: '#36a64f',
                text,
                fields
              }
            ]
          }
          robot.adapter.client.web.chat.postMessage(
            res.message.room,
            null,
            options
          )
        } else {
          res.reply('la respuesta no es la esperada')
        }
      })
  })
}
