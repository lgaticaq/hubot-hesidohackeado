path = require("path")
Helper = require("hubot-test-helper")
expect = require("chai").expect
nock = require("nock")
filesize = require("filesize")
moment = require("moment")

helper = new Helper("./../src/index.coffee")

describe "hesidohackeado", ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    nock.disableNetConnect()

  afterEach ->
    room.destroy()
    nock.cleanAll()

  context "email valido con registros", ->
    email = "anon@ymo.us"
    format = "YYYY-MM-DD HH:mm:ss"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithFile(200, path.join(__dirname, "found.json"))
      room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera que obtenga registros", ->
      expect(room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"],
        [
          "hubot",
          ">Hay *1* registro para #{email}\n" +
          ">*Fecha*: #{moment("2015-09-04T00:00:00+02:00").format(format)}\n" +
          ">*Título*: Multiple Dating/Marriage Websites (9)\n" +
          ">*Autor*: smitz\n" +
          ">*Sitio*: siph0n\n" +
          ">*Red*: clearnet\n" +
          ">*Emails*: 7744\n" +
          ">*Tamaño*: #{filesize(2721878)}\n" +
          ">*Enlace*: https://hesidohackeado.com/leak/siph0n-4033\n\n"
        ]
      ])

  context "email valido sin registros", ->
    email = "anon@ymo.us"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithFile(200, path.join(__dirname, "notfound.json"))
      room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera que no obtenga registros", ->
      expect(room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"],
        ["hubot", ":tada: ¡Felicidades! No hay registros para #{email} :tada:"]
      ])

  context "email invalido", ->
    email = "anon@@@@ymous"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithFile(200, path.join(__dirname, "badsintax.json"))
      room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera no obtener respuesta", ->
      expect(room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
      ])

  context "error en el servidor", ->
    email = "anon@ymo.us"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithError("something awful happened")
      room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera obtener error", ->
      expect(room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
        ["hubot", "@pepito ocurrio un error al consultar el email"]
      ])
