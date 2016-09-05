#ifndef SHADERBUILDER_H
#define SHADERBUILDER_H

#include "shadernode.h"
#include "shaderoutput.h"

#include <QOpenGLShader>
#include <QObject>
#include <QQmlListProperty>
#include <QUrl>
#include <QVariantList>

#include <Qt3DCore/QNode>
#include <Qt3DRender/QMaterial>

using namespace Qt3DRender;

class VariantShaderNode;

struct UniformValue
{
    ShaderNode *node;
    QString propertyName;
    QString identifier;
    QVariant value;
    QString type;
    QParameter *parameter;
};

class ShaderBuilder : public Qt3DCore::QNode
{
    Q_OBJECT
    Q_ENUMS(ShaderType)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QUrl sourceFile READ sourceFile WRITE setSourceFile NOTIFY sourceFileChanged)
    Q_PROPERTY(QString finalShader READ finalShader NOTIFY finalShaderChanged)
    Q_PROPERTY(QQmlListProperty<ShaderOutput> outputs READ outputs CONSTANT)
    Q_PROPERTY(ShaderType shaderType READ shaderType WRITE setShaderType NOTIFY shaderTypeChanged)
    Q_PROPERTY(QMaterial* material READ material WRITE setMaterial NOTIFY materialChanged)

public:
    explicit ShaderBuilder(QNode *parent = 0);
    virtual ~ShaderBuilder();

    QString source() const;
    QString finalShader();

    QQmlListProperty<ShaderOutput> outputs();

    QVariantMap uniforms() const;
    void addUniform(ShaderNode *node, const QString &propertyName, const QString &identifier,
                    const QVariant &value, QMetaProperty metaProperty);

    QUrl sourceFile() const;

    enum class ShaderType {
        Vertex,
        Fragment,
        Geometry,
        Compute,
        TessellationControl,
        TessellationEvaluation
    };

    ShaderType shaderType() const;
    QMaterial *material() const;

signals:
    void sourceChanged(QString source);
    void finalShaderChanged();
    void uniformsChanged();

    void sourceFileChanged(QUrl sourceFile);
    void shaderTypeChanged(ShaderType shaderType);
    void materialChanged(QMaterial* material);

public slots:
    void rebuildShader();
    void setSource(QString source);
    void markDirty();
    void updateUniform(int i);

    void setSourceFile(QUrl sourceFile);
    void setShaderType(ShaderType shaderType);
    void setMaterial(QMaterial* material);

private:
    static void appendOutput(QQmlListProperty<ShaderOutput> *list, ShaderOutput *output);
    static int outputCount(QQmlListProperty<ShaderOutput> *list);
    static ShaderOutput *outputAt(QQmlListProperty<ShaderOutput> *list, int index);
    static void clearOutputs(QQmlListProperty<ShaderOutput> *list);

    QString glslType(QVariant value) const;
    void clear();

    QString m_source;
    QList<ShaderOutput*> m_outputs;
    QList<UniformValue> m_uniforms;
    QList<QSignalMapper*> m_signalMappers;
    QUrl m_sourceFile;
    ShaderType m_shaderType = ShaderType::Vertex;
    QMaterial* m_material = nullptr;
    QList<QParameter*> m_parameters;
    QString m_finalShader;
    bool m_dirty = true;
};

#endif // SHADERBUILDER_H
