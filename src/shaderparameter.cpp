#include "shaderparameter.h"

ShaderParameter::ShaderParameter(Qt3DCore::QNode *parent) : Qt3DCore::QNode(parent)
{

}

QVariant ShaderParameter::value() const
{
    return m_value;
}

QString ShaderParameter::identifier() const
{
    return m_identifier;
}

void ShaderParameter::setValue(QVariant value)
{
    if (m_value == value)
        return;

    m_value = value;
    emit valueChanged(value);
}

void ShaderParameter::setIdentifier(QString identifier)
{
    if (m_identifier == identifier)
        return;

    m_identifier = identifier;
    emit identifierChanged(identifier);
}
