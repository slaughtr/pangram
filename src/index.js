exports.handler = async event => {
    const response = {
        body: {
            isPangram: false
        },
        statusCode: 503, // default to bad status code in case of unexpected errors
        headers: { 'Access-Control-Allow-Origin': '*' }, // with proxy integration, you need this for CORS
        isBase64Encoded: false
    };    
    
    try {
        // this goes inside the try until we have optional chaining
        const { queryStringParameters: { string } } = event;

        const checkPangram = string => {
            // if we get an array or an object or a boolean etc, we can safely assume it's not a pangram
            if (typeof string === 'string') {
                // toLowerCase the string to reduce complexity
                const cleanString = string.toLowerCase().trim();
        
                return cleanString.indexOf('a') !== -1 && cleanString.indexOf('b') !== -1 && cleanString.indexOf('c') !== -1 && cleanString.indexOf('d') !== -1 && cleanString.indexOf('e') !== -1 && cleanString.indexOf('f') !== -1 && cleanString.indexOf('g') !== -1 && cleanString.indexOf('h') !== -1 && cleanString.indexOf('i') !== -1 && cleanString.indexOf('j') !== -1 && cleanString.indexOf('k') !== -1 && cleanString.indexOf('l') !== -1 && cleanString.indexOf('m') !== -1 && cleanString.indexOf('n') !== -1 && cleanString.indexOf('o') !== -1 && cleanString.indexOf('p') !== -1 && cleanString.indexOf('q') !== -1 && cleanString.indexOf('r') !== -1 && cleanString.indexOf('s') !== -1 && cleanString.indexOf('t') !== -1 && cleanString.indexOf('u') !== -1 && cleanString.indexOf('v') !== -1 && cleanString.indexOf('w') !== -1 && cleanString.indexOf('x') !== -1 && cleanString.indexOf('y') !== -1 && cleanString.indexOf('z') !== -1;
            }
        
            return false;
        }

        
        response.body.isPangram = checkPangram(string);
        response.statusCode = 200; // don't forget!

    } catch (error) {
        console.error(error);
        // return a helpful error message
        response.body = {status: 'error', errorMessage: error.message};
        response.statusCode = 503;
    }

    // you MUST stringify your response body if it is JSON
    response.body = JSON.stringify(response.body);

    return response;
}