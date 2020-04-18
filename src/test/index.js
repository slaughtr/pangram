const chai = require('chai');
const { expect } = chai;

const { handler } = require('../index');
const { pangrams, notPangrams } = require('./pangrams');

describe('handler', () => {
    it('Should return true for all items in pangrams array', () => {
        for (const string of pangrams) {
            const { body } = handler(string);
            expect(JSON.parse(body)).to.have.property('isPangram').to.equal(true);
        }
    })

    it('Should return false for all items in notPangrams array', () => {
        for (const string of notPangrams) {
            const { body } = handler(string);
            expect(JSON.parse(body)).to.have.property('isPangram').to.equal(false);
        }
    })

    it('Should return a 200 status code for all items in both arrays', () => {
        for (const string of [...pangrams, ...notPangrams]) {
            const { statusCode } = handler(string);
            expect(statusCode).to.equal(200);
        }
    })
})