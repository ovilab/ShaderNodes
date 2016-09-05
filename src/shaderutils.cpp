#include "shaderutils.h"

#include "shadernode.h"

#include <QDebug>
#include <QJSEngine>
#include <Qt3DRender/QTexture>

using Qt3DRender::QTexture2D;

int ShaderUtils::m_nameCounter = 0;
QMutex ShaderUtils::m_nameMutex;

QString ShaderUtils::glslType(const QVariant &value)
{
    ShaderNode *node = qvariant_cast<ShaderNode*>(value);
    if(node) {
        return node->type();
    }
    QTexture2D *texture = qvariant_cast<QTexture2D*>(value);
    if(texture) {
        return "sampler2D";
    }
    switch(value.type()) {
    case QVariant::Bool:
        return QString("bool");
    case QVariant::Int:
        return QString("float");
    case QVariant::Double:
        return QString("float");
    case QVariant::Vector2D:
        return QString("vec2");
    case QVariant::Vector3D:
        return QString("vec3");
    case QVariant::Vector4D:
        return QString("vec4");
    case QVariant::Color:
        return QString("vec4");
    case QVariant::String:
        // assume strings to be colors because there are no strings in GLSL
        return QString("vec4");
    default:
        qWarning() << "ShaderUtils::glslType(): could not identify type of" << value;
        return QString("float");
        break;
    }
}

QString ShaderUtils::preferredType(const QVariant &value1, const QVariant &value2)
{
    QStringList preferenceOrder = {
        "bool",
        "float",
        "vec2",
        "vec3",
        "vec4"
    };

    QString type1 = glslType(value1);
    QString type2 = glslType(value2);

    int value1Preference = preferenceOrder.indexOf(type1);
    int value2Preference = preferenceOrder.indexOf(type2);

    if(value1Preference > value2Preference) {
        return type1;
    } else {
        return type2;
    }

}

QString ShaderUtils::convert(const QString &sourceType, const QString &targetType, const QString &identifier)
{
    const QString &v = identifier;
    if(targetType.isEmpty() || sourceType == targetType) {
        return v;
    }

    QVariantMap scalar{
        {"bool", "bool(" + v + ")"},
        {"int", "int(" + v + ")"},
        {"uint", "uint(" + v + ")"},
        {"float", "float(" + v + ")"},
        {"double", "double(" + v + ")"},
        {"vec3", "vec2(" + v + ", " + v + ")"},
        {"vec3", "vec3(" + v + ", " + v + ", " + v + ")"},
        {"vec4", "vec4(" + v + ", " + v + ", " + v + ", 1.0)"}
    };

    // conversions from->to->implementation
    QVariantMap conversions{
        {"bool", scalar},
        {"int", scalar},
        {"uint", scalar},
        {"float", scalar},
        {"double", scalar},
        {"vec2", QVariantMap{
                {"float", "0.5 * " + v + ".x + " + v + ".y)"},
                {"vec3", "vec3(" + v + ", 0.0)"},
                {"vec4", "vec4(" + v + ", 0.0, 1.0)"}
            }
        },
        {"vec3", QVariantMap{
                {"float", "1.0 / 3.0 * (" + v + ".x + " + v + ".y + " + v + ".z)"},
                {"vec2", v + ".xy"},
                {"vec4", "vec4(" + v + ", 1.0)"}
            }
        },
        {"vec4", QVariantMap{
                {"float", "0.25 * (" + v + ".x + " + v + ".y + " + v + ".z + " + v + ".w)"},
                {"vec2", v + ".xy"},
                {"vec3", v + ".xyz"}
            }
        },
        {"sampler2D", QVariantMap {
                {"float", "texture(" + v + ", vec2(0.0, 0.0)).r"},
                {"vec2", "texture(" + v + ", vec2(0.0, 0.0)).rg"},
                {"vec3", "texture(" + v + ", vec2(0.0, 0.0)).rgb"},
                {"vec4", "texture(" + v + ", vec2(0.0, 0.0)).rgba"}
            }
        }
        };
    if(conversions.contains(sourceType)) {
        QVariantMap typeConversions = conversions[sourceType].toMap();
        if(typeConversions.contains(targetType)) {
            return "(" + typeConversions[targetType].toString() + ")";
        }
    }
    qWarning() << "WARNING: ShaderUtils::convert(): No known conversion from "
               << sourceType << " to " << targetType << ". Will return value directly.";
    return v;
}

QString ShaderUtils::generateName()
{
    m_nameMutex.lock();
    QString name = QString::number(m_nameCounter);
    m_nameCounter += 1;
    m_nameMutex.unlock();
    return name;
}

QString ShaderUtils::precisionQualifier(QString type)
{
    Q_UNUSED(type);
    return "highp";
}
