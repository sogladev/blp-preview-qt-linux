#include "blphandler.h"
#include <QImage>
#include <QIODevice>
#include <QProcess>
#include <QTemporaryFile>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

BlpHandler::BlpHandler()
{
}

bool BlpHandler::canRead() const
{
    if (device()) {
        return canRead(device());
    }
    return false;
}

bool BlpHandler::canRead(QIODevice *device)
{
    if (!device) {
        return false;
    }

    // Check for BLP magic bytes
    QByteArray header = device->peek(4);
    return header == "BLP1" || header == "BLP2";
}

bool BlpHandler::read(QImage *image)
{
    if (!device()) {
        return false;
    }

    // Read all BLP data
    QByteArray blpData = device()->readAll();
    if (blpData.isEmpty()) {
        return false;
    }

    // Create temporary files for input and output
    QTemporaryFile inputFile;
    inputFile.setAutoRemove(false); // Don't delete until we're done
    if (!inputFile.open()) {
        qWarning() << "Failed to create temporary input file";
        return false;
    }
    inputFile.write(blpData);
    inputFile.flush();
    inputFile.close(); // Close but keep the file
    QString inputPath = inputFile.fileName();

    QTemporaryFile outputFile;
    outputFile.setAutoRemove(false); // Don't delete until we're done
    outputFile.setFileTemplate(QDir::tempPath() + "/blp_XXXXXX.png");
    if (!outputFile.open()) {
        qWarning() << "Failed to create temporary output file";
        QFile::remove(inputPath); // Clean up input file
        return false;
    }
    QString outputPath = outputFile.fileName();
    outputFile.close(); // Close so the converter can write to it

    // Locate the warcraft-rs executable, checking common locations explicitly
    // because GUI apps often don't have ~/.cargo/bin in PATH
    QString warcraftRs = QStandardPaths::findExecutable("warcraft-rs");

    // If not found via standard paths, check common Cargo install locations
    if (warcraftRs.isEmpty()) {
        QStringList candidatePaths = {
            QDir::homePath() + "/.cargo/bin/warcraft-rs",
            "/usr/local/bin/warcraft-rs",
            "/usr/bin/warcraft-rs"
        };

        for (const QString &path : candidatePaths) {
            if (QFile::exists(path) && QFileInfo(path).isExecutable()) {
                warcraftRs = path;
                qDebug() << "Found warcraft-rs at:" << path;
                break;
            }
        }
    }

    if (warcraftRs.isEmpty()) {
        qWarning() << "warcraft-rs executable not found. Checked locations:";
        qWarning() << "  - System PATH";
        qWarning() << "  -" << QDir::homePath() + "/.cargo/bin/warcraft-rs";
        qWarning() << "  - /usr/local/bin/warcraft-rs";
        qWarning() << "  - /usr/bin/warcraft-rs";
        qWarning() << "Install with: cargo install warcraft-rs";
        qWarning() << "Or create symlink: sudo ln -s ~/.cargo/bin/warcraft-rs /usr/local/bin/";
        QFile::remove(inputPath);
        QFile::remove(outputPath);
        return false;
    }

    // Run warcraft-rs converter
    QProcess process;
    QStringList args;
    args << "blp" << "convert" << "--input-format" << "blp" << inputPath << outputPath;
    process.start(warcraftRs, args);

    // Allow a bit more time for conversion; thumbnails and KIO previews may be started
    // in environments with limited PATH and resources.
    const int timeoutMs = 15000;
    if (!process.waitForFinished(timeoutMs)) {
        qWarning() << "BLP converter timeout or failed to start. Error:" << process.errorString();
        qWarning() << "Process state:" << process.state();
        QFile::remove(inputPath);
        QFile::remove(outputPath);
        return false;
    }

    if (process.exitCode() != 0) {
        qWarning() << "BLP converter failed with exit code:" << process.exitCode();
        qWarning() << "stderr:" << process.readAllStandardError();
        qWarning() << "stdout:" << process.readAllStandardOutput();
        QFile::remove(inputPath);
        QFile::remove(outputPath);
        return false;
    }

    qDebug() << "BLP conversion successful:" << inputPath << "->" << outputPath;

    // Load the converted PNG
    QImage result(outputPath);

    // Clean up temporary files
    QFile::remove(inputPath);
    QFile::remove(outputPath);

    if (result.isNull()) {
        qWarning() << "Failed to load converted PNG";
        return false;
    }

    *image = result;
    return true;
}
