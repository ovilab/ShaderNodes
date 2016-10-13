#include "shaderparameter.h"

ShaderParameter::ShaderParameter(ShaderNode *parent) : ShaderNode(parent)
{

}

QString ShaderParameter::generateHeader() const
{
    QString header;
    header += QString("uniform ") + type() + " " + identifier() + ";\n";
    return header;
}

QString ShaderParameter::generateBody() const
{
    return QString();
}

bool ShaderParameter::setup(ShaderBuilder *shaderBuilder, QString tempIdentifier)
{
    Q_UNUSED(shaderBuilder)
    Q_UNUSED(tempIdentifier)
    return true;
}
