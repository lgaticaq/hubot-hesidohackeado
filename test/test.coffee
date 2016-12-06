path = require("path")
Helper = require("hubot-test-helper")
expect = require("chai").expect
nock = require("nock")

helper = new Helper("./../src/index.coffee")

describe "hesidohackeado", ->
  beforeEach ->
    @room = helper.createRoom()
    @room.robot.adapter.client =
      web:
        chat:
          postMessage: (channel, text, options) =>
            @postMessage =
              channel: channel
              text: text
              options: options

  afterEach ->
    @room.destroy()

  context "email valido con registros", ->
    email = "anon@ymo.us"
    format = "YYYY-MM-DD HH:mm:ss"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithFile(200, path.join(__dirname, "found.json"))
      @room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera que obtenga registros", ->
      expect(@room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
      ])
      expect(@postMessage.options.attachments[0].fields).to.eql([
        title: "Multiple Dating/Marriage Websites (9)"
        value: "Fecha: 2015-09-04"
        short: true
      ])

  context "email valido con multiples registros", ->
    email = "anon@ymo.us"
    format = "YYYY-MM-DD HH:mm:ss"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithFile(200, path.join(__dirname, "found2.json"))
      @room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera que obtenga registros", ->
      expect(@room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
      ])
      expect(@postMessage.options.attachments[0].fields).to.eql([
        title: "Multiple Dating/Marriage Websites (9)"
        value: "Fecha: 2015-09-04"
        short: true
      ,
        title: "Other"
        value: "Fecha: 2015-09-04"
        short: true
      ])

  context "email valido sin registros", ->
    email = "anon@ymo.us"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithFile(200, path.join(__dirname, "notfound.json"))
      @room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera que no obtenga registros", ->
      expect(@room.messages).to.eql([
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
      @room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera no obtener respuesta", ->
      expect(@room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
      ])

  context "error en el servidor", ->
    email = "anon@ymo.us"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .replyWithError("something awful happened")
      @room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera obtener error", ->
      expect(@room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
        ["hubot", "@pepito ocurrio un error al consultar el email"]
      ])

  context "respuesta inesperada", ->
    email = "anon@ymo.us"

    beforeEach (done) ->
      nock("https://hesidohackeado.com")
        .get("/api")
        .query({q: email})
        .reply(200, {status: "asdasd"})
      @room.user.say("pepito", "hubot hesidohackeado #{email}")
      setTimeout(done, 100)

    it "se espera obtener error", ->
      expect(@room.messages).to.eql([
        ["pepito", "hubot hesidohackeado #{email}"]
        ["hubot", "@pepito la respuesta no es la esperada"]
      ])
