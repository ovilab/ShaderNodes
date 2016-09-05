#ifndef SHADERNODE_H
#define SHADERNODE_H

#include <QString>
#include <QVariant>
#include <QList>
#include <QQmlListProperty>
#include <QJSValue>
#include <QSignalMapper>
#include <QUrl>

#include <Qt3DCore/QNode>

class ShaderBuilder;

class ShaderNode : public Qt3DCore::QNode
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString result READ result WRITE setResult NOTIFY resultChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString header READ header WRITE setHeader NOTIFY headerChanged)
    Q_PROPERTY(QString identifier READ identifier NOTIFY identifierChanged)
    Q_PROPERTY(QUrl headerFile READ headerFile WRITE setHeaderFile NOTIFY headerFileChanged)
    Q_PROPERTY(bool requirement READ requirement WRITE setRequirement NOTIFY requirementChanged)
    Q_PROPERTY(QQmlListProperty<ShaderNode> dependencies READ dependencies)

public:
    explicit ShaderNode(Qt3DCore::QNode *parent = 0);

    Q_INVOKABLE virtual QString generateHeader() const;
    Q_INVOKABLE virtual QString generateBody() const;
    Q_INVOKABLE QString convert(const QString &targetType, const QString &identifier = QString()) const;
    Q_INVOKABLE QString glslType(QVariant value) const;
    Q_INVOKABLE QString preferredType(QVariant value1, QVariant value2) const;

    QString name() const;
    QString type() const;
    QString result() const;
    QString header() const;
    QString identifier() const;
    void reset() const;
    virtual bool setup(ShaderBuilder* shaderBuilder, QString tempIdentifier = QString());
    ShaderBuilder *shaderBuilder() const;
    void setShaderBuilder(ShaderBuilder *shaderBuilder);
    QString source() const;
    bool requirement() const;
    QQmlListProperty<ShaderNode> dependencies();
    QUrl headerFile() const;
    void addMapping(QString propertyName, const QVariant &value);
    void removeMapping(QString propertyName);
    void addDependency(ShaderNode *dependency);
    void removeDependency(ShaderNode *dependency);
    void clearDependencies();

signals:
    void nameChanged(QString name);
    void typeChanged(QString type);
    void resultChanged(QString result);
    void headerChanged(QString header);
    void identifierChanged(QString identifier);
    void sourceChanged(QString source);
    void requirementChanged(bool requirement);
    void headerFileChanged(QUrl headerFile);
    void propertyTypeChanged();

public slots:
    void setName(QString name);
    void setType(QString type);
    void setResult(QString result);
    void setHeader(QString header);
    void setSource(QString source);
    void setRequirement(bool requirement);
    void setHeaderFile(QUrl headerFile);

protected:
    mutable bool m_hasGeneratedHeader = false;
    mutable bool m_hasGeneratedBody = false;
    mutable bool m_hasSetup = false;
    QString m_name;
    QString m_type;
    QString m_result;
    QString m_header;
    QString m_identifier;
    ShaderBuilder *m_shaderBuilder = nullptr;
    QSignalMapper mapper;
    bool m_requirement = true;
    QUrl m_headerFile;
    QVariantMap m_mappings;

    QString m_resolvedSource;
    QList<ShaderNode*> m_resolvedDependencies;
    QList<ShaderNode*> m_declaredDependencies;
    QMap<int, QString> m_propertyTypeNames;
    QString m_source;

    QList<QSignalMapper*> m_signalMappers;
private slots:
    void handlePropertyChange(int index);
};

#endif // SHADERNODE_H
