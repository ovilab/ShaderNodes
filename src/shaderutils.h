#ifndef SHADERUTILS_H
#define SHADERUTILS_H

#include <QString>
#include <QVariant>

#include <QMutex>

class ShaderUtils
{
public:
    static QString glslType(const QVariant &value);
    static QString convert(const QString &sourceType, const QString &targetType, const QString &identifier);
    static QString generateName();
    static QString precisionQualifier(QString type);
    static QString preferredType(const QVariant &value1, const QVariant &value2);
private:
    static QMutex m_nameMutex;
    static int m_nameCounter;
};

#endif // SHADERUTILS_H
