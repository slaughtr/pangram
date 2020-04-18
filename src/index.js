exports.handler = event => {
    const response = {
        body: {
            isPangram: false
        },
        statusCode: 503,
        headers: { 'Access-Control-Allow-Origin': '*' }
    };

    try {
        
    } catch (error) {
        console.error(error)
        response.body = {status: 'error', errorMessage: error.message}
        response.statusCode = 503;
    }

    response.body = JSON.stringify(response.body);

    return response;
}