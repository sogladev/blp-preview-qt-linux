#ifndef BLPHANDLER_H
#define BLPHANDLER_H

#include <QImageIOHandler>

class BlpHandler : public QImageIOHandler
{
public:
    BlpHandler();

    bool canRead() const override;
    bool read(QImage *image) override;

    static bool canRead(QIODevice *device);
};

#endif // BLPHANDLER_H
