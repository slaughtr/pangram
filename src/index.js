exports.handler = event => {
    const response = {
        body: {
            isPangram: false
        },
        statusCode: 503,
        headers: { 'Access-Control-Allow-Origin': '*' }
    };

    const { queryStringParameters: { string } } = event;


    try {
        const checkPangram = string => {
            if (typeof string === 'string') {
                const cleanString = string.toLowerCase().trim();
        
                return cleanString.indexOf('a') !== -1 && cleanString.indexOf('b') !== -1 && cleanString.indexOf('c') !== -1 && cleanString.indexOf('d') !== -1 && cleanString.indexOf('e') !== -1 && cleanString.indexOf('f') !== -1 && cleanString.indexOf('g') !== -1 && cleanString.indexOf('h') !== -1 && cleanString.indexOf('i') !== -1 && cleanString.indexOf('j') !== -1 && cleanString.indexOf('k') !== -1 && cleanString.indexOf('l') !== -1 && cleanString.indexOf('m') !== -1 && cleanString.indexOf('n') !== -1 && cleanString.indexOf('o') !== -1 && cleanString.indexOf('p') !== -1 && cleanString.indexOf('q') !== -1 && cleanString.indexOf('r') !== -1 && cleanString.indexOf('s') !== -1 && cleanString.indexOf('t') !== -1 && cleanString.indexOf('u') !== -1 && cleanString.indexOf('v') !== -1 && cleanString.indexOf('w') !== -1 && cleanString.indexOf('x') !== -1 && cleanString.indexOf('y') !== -1 && cleanString.indexOf('z') !== -1;
            }
        
            return false;
        }       

        response.body.isPangram = checkPangram(string);
        response.statusCode = 200;
    } catch (error) {
        console.error(error)
        response.body = {status: 'error', errorMessage: error.message}
        response.statusCode = 503;
    }

    response.body = JSON.stringify(response.body);

    return response;
}