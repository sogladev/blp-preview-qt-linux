#include "blpplugin.h"
#include "blphandler.h"

QImageIOPlugin::Capabilities BlpPlugin::capabilities(QIODevice *device, const QByteArray &format) const
{
    if (format == "blp") {
        return Capabilities(CanRead);
    }

    if (!format.isEmpty()) {
        return {};
    }

    if (!device || !device->isOpen()) {
        return {};
    }

    Capabilities cap;
    if (device->isReadable() && BlpHandler::canRead(device)) {
        cap |= CanRead;
    }

    return cap;
}

QImageIOHandler *BlpPlugin::create(QIODevice *device, const QByteArray &format) const
{
    QImageIOHandler *handler = new BlpHandler;
    handler->setDevice(device);
    handler->setFormat(format);
    return handler;
}
