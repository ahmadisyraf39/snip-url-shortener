module.exports = async function (context, req) {
    const longUrl = req.body && req.body.url;

    if (!longUrl) {
        context.res = {
            status: 400,
            body: { error: "Missing 'url' in request body." }
        };
        return;
    }

    const shortCode = generateShortCode(6);

    context.bindings.newLink = {
        id: shortCode,
        shortCode: shortCode,
        longUrl: longUrl,
        createdAt: new Date().toISOString()
    };

    context.res = {
        status: 200,
        headers: { "Content-Type": "application/json" },
        body: {
            shortCode: shortCode,
            shortUrl: `https://${req.headers.host}/api/${shortCode}`
        }
    };
};

function generateShortCode(length) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let result = "";
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}
