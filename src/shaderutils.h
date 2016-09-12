#ifndef SHADERUTILS_H
#define SHADERUTILS_H

#include <QString>
#include <QVariant>

#include <QMutex>

class QQmlEngine;
class QJSEngine;

class ShaderUtils : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ShaderUtils)
public:
    ShaderUtils();

    Q_INVOKABLE static QString glslType(const QVariant &value);
    Q_INVOKABLE static QString convert(const QString &sourceType, const QString &targetType, const QString &identifier);
    Q_INVOKABLE static QString generateName();
    Q_INVOKABLE static QString precisionQualifier(QString type);
    Q_INVOKABLE static QString preferredType(const QVariant &value1, const QVariant &value2);
    Q_INVOKABLE static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *jsEngine);
    Q_INVOKABLE static int componentCount(const QVariant &value);
    Q_INVOKABLE static bool isList(const QVariant &value);
    Q_INVOKABLE static QString serialize(const QVariant &value);
private:
    static QMutex m_nameMutex;
    static int m_nameCounter;
};

#endif // SHADERUTILS_H
