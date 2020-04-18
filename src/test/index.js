const chai = require('chai');
const { expect } = chai;

const { handler } = require('../index');
const { pangrams, notPangrams } = require('./pangrams');

describe('handler', () => {
    it('Should return true for all items in pangrams array', async () => {
        for (const string of pangrams) {
            const { body } = await handler({queryStringParameters: {string}});
            expect(JSON.parse(body)).to.have.property('isPangram').to.equal(true);
        }
    })

    it('Should return false for all items in notPangrams array', async () => {
        for (const string of notPangrams) {
            const { body } = await handler({queryStringParameters: {string}});
            expect(JSON.parse(body)).to.have.property('isPangram').to.equal(false);
        }
    })

    it('Should return a 200 status code for all items in both arrays', async () => {
        for (const string of [...pangrams, ...notPangrams]) {
            const { statusCode } = await handler({queryStringParameters: {string}});
            expect(statusCode).to.equal(200);
        }
    })

    it('Should return 503 on a naked call', async () => {
            const { statusCode } = await handler();
            expect(statusCode).to.equal(503);
    })
})