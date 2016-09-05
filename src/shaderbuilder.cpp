#include "shaderbuilder.h"

#include "shaderutils.h"

#include <QRegularExpression>
#include <QDebug>
#include <QMetaProperty>
#include <QQmlEngine>
#include <QQmlFile>
#include <QFile>
#include <QColor>

#include <Qt3DRender/QParameter>
#include <Qt3DRender/QTexture>

using Qt3DRender::QTexture2D;

ShaderBuilder::ShaderBuilder(QNode *parent)
    : QNode(parent)
{
}

ShaderBuilder::~ShaderBuilder()
{
    clear();
}

void ShaderBuilder::clear()
{
    for(QSignalMapper *mapper : m_signalMappers) {
        disconnect(this, 0, mapper, SLOT(map()));
        disconnect(mapper, SIGNAL(mapped(int)), this, SLOT(updateUniform(int)));
        delete mapper;
    }
    m_signalMappers.clear();
    if(m_material) {
        for(UniformValue &uniformValue : m_uniforms) {
            m_material->removeParameter(uniformValue.parameter);
            delete uniformValue.parameter;
        }
    }
    m_uniforms.clear();
    m_finalShader = "";
}

QString ShaderBuilder::source() const
{
    return m_source;
}

QString ShaderBuilder::finalShader()
{
    if(m_dirty) {
        rebuildShader();
    }
    return m_finalShader;
}

QQmlListProperty<ShaderOutput> ShaderBuilder::outputs()
{
    return QQmlListProperty<ShaderOutput>(this, 0,
                                          ShaderBuilder::appendOutput,
                                          ShaderBuilder::outputCount,
                                          ShaderBuilder::outputAt,
                                          ShaderBuilder::clearOutputs);
}

void ShaderBuilder::appendOutput(QQmlListProperty<ShaderOutput> *list, ShaderOutput *output)
{
    if(!output) {
        return;
    }

    ShaderBuilder *self = static_cast<ShaderBuilder*>(list->object);
    self->m_outputs.append(output);
    QObject::connect(output, &ShaderOutput::nameChanged, self, &ShaderBuilder::markDirty);
    QObject::connect(output, &ShaderOutput::typeChanged, self, &ShaderBuilder::markDirty);
    QObject::connect(output, &ShaderOutput::valueChanged, self, &ShaderBuilder::markDirty);
}

int ShaderBuilder::outputCount(QQmlListProperty<ShaderOutput> *list)
{
    ShaderBuilder *self = static_cast<ShaderBuilder*>(list->object);
    return self->m_outputs.count();
}

ShaderOutput *ShaderBuilder::outputAt(QQmlListProperty<ShaderOutput> *list, int index)
{
    ShaderBuilder *self = static_cast<ShaderBuilder*>(list->object);
    return self->m_outputs.at(index);
}

void ShaderBuilder::clearOutputs(QQmlListProperty<ShaderOutput> *list)
{
    ShaderBuilder *self = static_cast<ShaderBuilder*>(list->object);
    for(const ShaderOutput *output : self->m_outputs) {
        QObject::disconnect(output, &ShaderOutput::nameChanged, self, &ShaderBuilder::markDirty);
        QObject::disconnect(output, &ShaderOutput::typeChanged, self, &ShaderBuilder::markDirty);
        QObject::disconnect(output, &ShaderOutput::valueChanged, self, &ShaderBuilder::markDirty);
    }
    return self->m_outputs.clear();
}

QVariantMap ShaderBuilder::uniforms() const
{
    QVariantMap result;
    for(const UniformValue &uniform : m_uniforms) {
        result[uniform.identifier] = uniform.value;
    }
    return result;
}

void ShaderBuilder::addUniform(ShaderNode *node, const QString &propertyName, const QString &identifier,
                               const QVariant &value, QMetaProperty metaProperty)
{
    UniformValue uniform;
    uniform.node = node;
    uniform.propertyName = propertyName;
    uniform.identifier = identifier;
    uniform.value = value;
    uniform.type = glslType(value);
    QParameter* param = new QParameter();
    param->setName(identifier);
    if(value.type() == QVariant::String) {
        param->setValue(QColor(value.toString()));
    } else {
        param->setValue(value);
    }
    uniform.parameter = param;
    m_uniforms.append(uniform);

    if(!metaProperty.hasNotifySignal()) {
        qWarning() << "WARNING: ShaderBuilder::addUniform(): Property" << propertyName << "on" << node->name()
                   << "has no notification signal.";
    } else {
        QSignalMapper *mapper = new QSignalMapper;
        mapper->setMapping(node, m_uniforms.length() - 1);
        const QByteArray signal = '2' + metaProperty.notifySignal().methodSignature();
        connect(node, signal, mapper, SLOT(map()));
        connect(mapper, SIGNAL(mapped(int)), this, SLOT(updateUniform(int)));
        m_signalMappers.append(mapper);
    }
}

QUrl ShaderBuilder::sourceFile() const
{
    return m_sourceFile;
}

ShaderBuilder::ShaderType ShaderBuilder::shaderType() const
{
    return m_shaderType;
}

QMaterial *ShaderBuilder::material() const
{
    return m_material;
}

void ShaderBuilder::rebuildShader()
{
    clear();
    m_dirty = false;

    // Verify all that all outputs have values
    for(ShaderOutput *output : m_outputs) {
        bool success = output->node()->setup(this);
        if(!success) {
            qWarning() << "ERROR: ShaderBuilder::rebuildShader(): One of the shader nodes failed during setup.";
            return;
        }
    }

    QString header = "";
    header += "\n// ------  begin generated header  ------\n\n";
    for(ShaderOutput *output : m_outputs) {
        header += output->node()->generateHeader();
    }
    header += "\n// ------          uniforms        ------\n\n";
    for(const UniformValue &uniform : m_uniforms) {
        header += "uniform highp " + uniform.type + " " + uniform.identifier + ";\n";
    }
    header += "\n// ------   end generated header   ------\n\n";

    QString body = "";
    body += "\n// ------   begin generated body   ------\n\n";
    for(ShaderOutput *output : m_outputs) {
        body += output->node()->generateBody();
    }
    body += "\n// ------    output assignments    ------\n\n";
    for(ShaderOutput *output : m_outputs) {
        body += output->name()
                + " = "
                + ShaderUtils::convert(output->node()->type(),
                                       output->type(),
                                       output->node()->identifier())
                + ";\n";
    }
    body += "\n// ------    end generated body    ------\n\n";
    body.replace(QRegularExpression("\n"), "\n    ");

    QString contents = m_source;
    contents.replace(QRegularExpression("^#pragma shadernodes header",
                                        QRegularExpression::MultilineOption),
                     header);
    contents.replace(QRegularExpression("^#pragma shadernodes body",
                                        QRegularExpression::MultilineOption),
                     body);

    for(ShaderOutput *output : m_outputs) {
        ShaderNode *value = output->node();
        if(!value) {
            continue;
        }
        value->reset();
    }

    if(m_material) {
        for(UniformValue &uniformValue : m_uniforms) {
            m_material->addParameter(uniformValue.parameter);
        }
    }

    m_finalShader = contents;
}

void ShaderBuilder::updateUniform(int i)
{
    UniformValue &uniform = m_uniforms[i];
    QByteArray propertyNameArray = uniform.propertyName.toUtf8();
    QVariant value = uniform.node->property(propertyNameArray.constData());;
    uniform.value = value;
    if(value.type() == QVariant::String) {
        uniform.parameter->setValue(QColor(value.toString()));
    } else {
        uniform.parameter->setValue(value);
    }
    QString type = glslType(value);
    if(type != uniform.type) {
        uniform.type = type;
        markDirty();
    }
    emit uniformsChanged();
}

void ShaderBuilder::setSourceFile(QUrl sourceFile)
{
    if (m_sourceFile == sourceFile)
        return;

    m_sourceFile = sourceFile;

    QString fileName = QQmlFile::urlToLocalFileOrQrc(sourceFile);
    QFile file(fileName);
    file.open(QFile::ReadOnly);
    setSource(file.readAll());
    markDirty();
    emit sourceFileChanged(sourceFile);
}

void ShaderBuilder::setShaderType(ShaderBuilder::ShaderType shaderType)
{
    if (m_shaderType == shaderType)
        return;

    m_shaderType = shaderType;
    markDirty();
    emit shaderTypeChanged(shaderType);
}

void ShaderBuilder::setMaterial(QMaterial *material)
{
    if (m_material == material)
        return;

    m_material = material;
    markDirty();
    emit materialChanged(material);
}

void ShaderBuilder::setSource(QString source)
{
    if (m_source == source)
        return;
    m_source = source;
    markDirty();
    emit sourceChanged(source);
}

void ShaderBuilder::markDirty()
{
    m_dirty = true;
    emit finalShaderChanged();
}

QString ShaderBuilder::glslType(QVariant value) const
{
    return ShaderUtils::glslType(value);
}
