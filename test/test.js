'use strict'

const path = require('path')
const Helper = require('hubot-test-helper')
const { describe, it, beforeEach, afterEach } = require('mocha')
const { expect } = require('chai')
const nock = require('nock')

const helper = new Helper('../src/index.js')

describe('hesidohackeado', function () {
  beforeEach(() => {
    this.room = helper.createRoom()
    this.room.robot.adapter.client = {
      web: {
        chat: {
          postMessage: (channel, text, options) => {
            this.postMessage = {
              channel,
              text,
              options
            }
          }
        }
      }
    }
  })

  afterEach(() => this.room.destroy())

  describe('email valido con registros', () => {
    const email = 'anon@ymo.us'

    beforeEach(done => {
      nock('https://hesidohackeado.com')
        .get('/api')
        .query({ q: email })
        .replyWithFile(200, path.join(__dirname, 'found.json'))
      this.room.user.say('pepito', `hubot hesidohackeado ${email}`)
      setTimeout(done, 100)
    })

    it('se espera que obtenga registros', () => {
      expect(this.room.messages).to.eql([
        ['pepito', `hubot hesidohackeado ${email}`]
      ])
      expect(this.postMessage.options.attachments[0].fields).to.eql([
        {
          title: 'Multiple Dating/Marriage Websites (9)',
          value: 'Fecha: 2015-09-04',
          short: true
        }
      ])
    })
  })

  describe('email valido con multiples registros', () => {
    const email = 'anon@ymo.us'

    beforeEach(done => {
      nock('https://hesidohackeado.com')
        .get('/api')
        .query({ q: email })
        .replyWithFile(200, path.join(__dirname, 'found2.json'))
      this.room.user.say('pepito', `hubot hesidohackeado ${email}`)
      setTimeout(done, 100)
    })

    it('se espera que obtenga registros', () => {
      expect(this.room.messages).to.eql([
        ['pepito', `hubot hesidohackeado ${email}`]
      ])
      expect(this.postMessage.options.attachments[0].fields).to.eql([
        {
          title: 'Multiple Dating/Marriage Websites (9)',
          value: 'Fecha: 2015-09-04',
          short: true
        },
        {
          title: 'Other',
          value: 'Fecha: 2015-09-04',
          short: true
        }
      ])
    })
  })

  describe('email valido sin registros', () => {
    const email = 'anon@ymo.us'

    beforeEach(done => {
      nock('https://hesidohackeado.com')
        .get('/api')
        .query({ q: email })
        .replyWithFile(200, path.join(__dirname, 'notfound.json'))
      this.room.user.say('pepito', `hubot hesidohackeado ${email}`)
      setTimeout(done, 100)
    })

    it('se espera que no obtenga registros', () => {
      expect(this.room.messages).to.eql([
        ['pepito', `hubot hesidohackeado ${email}`],
        ['hubot', `:tada: ¡Felicidades! No hay registros para ${email} :tada:`]
      ])
    })
  })

  describe('email invalido', () => {
    const email = 'anon@@@@ymous'

    beforeEach(done => {
      nock('https://hesidohackeado.com')
        .get('/api')
        .query({ q: email })
        .replyWithFile(200, path.join(__dirname, 'badsintax.json'))
      this.room.user.say('pepito', `hubot hesidohackeado ${email}`)
      setTimeout(done, 100)
    })

    it('se espera no obtener respuesta', () => {
      expect(this.room.messages).to.eql([
        ['pepito', `hubot hesidohackeado ${email}`]
      ])
    })
  })

  describe('error en el servidor', () => {
    const email = 'anon@ymo.us'

    beforeEach(done => {
      nock('https://hesidohackeado.com')
        .get('/api')
        .query({ q: email })
        .replyWithError('something awful happened')
      this.room.user.say('pepito', `hubot hesidohackeado ${email}`)
      setTimeout(done, 100)
    })

    it('se espera obtener error', () => {
      expect(this.room.messages).to.eql([
        ['pepito', `hubot hesidohackeado ${email}`],
        ['hubot', '@pepito ocurrio un error al consultar el email']
      ])
    })
  })

  describe('respuesta inesperada', () => {
    const email = 'anon@ymo.us'

    beforeEach(done => {
      nock('https://hesidohackeado.com')
        .get('/api')
        .query({ q: email })
        .reply(200, { status: 'asdasd' })
      this.room.user.say('pepito', `hubot hesidohackeado ${email}`)
      setTimeout(done, 100)
    })

    it('se espera obtener error', () => {
      expect(this.room.messages).to.eql([
        ['pepito', `hubot hesidohackeado ${email}`],
        ['hubot', '@pepito la respuesta no es la esperada']
      ])
    })
  })
})
