#ifndef SHADERPARAMETER_H
#define SHADERPARAMETER_H

#include <Qt3DCore/QNode>

class ShaderParameter : public Qt3DCore::QNode
{
    Q_OBJECT
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString identifier READ identifier NOTIFY identifierChanged)
public:
    explicit ShaderParameter(Qt3DCore::QNode *parent = 0);

    QVariant value() const;
    QString identifier() const;

signals:
    void valueChanged(QVariant value);
    void identifierChanged(QString identifier);

public slots:
    void setValue(QVariant value);
    void setIdentifier(QString identifier);

private:
    QVariant m_value;
    QString m_identifier;
};

#endif // SHADERPARAMETER_H
