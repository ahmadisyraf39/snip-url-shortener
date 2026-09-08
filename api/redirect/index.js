module.exports = async function (context, req) {
    const linkDoc = context.bindings.linkDoc;

    if (!linkDoc) {
        context.res = {
            status: 404,
            headers: { "Content-Type": "application/json" },
            body: { error: "Short link not found." }
        };
        return;
    }

    context.res = {
        status: 302,
        headers: {
            Location: linkDoc.longUrl
        }
    };
};
