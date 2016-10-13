#include "shadernodesplugin.h"

#include "parameterlistbinding.h"
#include "shaderbuilder.h"
#include "shaderbuilderbinding.h"
#include "shadernode.h"
#include "shaderoutput.h"
#include "shaderutils.h"

#include <qqml.h>
#include <QQmlEngine>
#include <Qt3DQuick/private/quick3dnode_p.h>

static const char* packageUri = "ShaderNodes";

void ShaderNodesPlugin::registerTypes(const char *uri)
{
    Q_INIT_RESOURCE(shadernodes_imports);
    Q_ASSERT(uri == QLatin1String(packageUri));
    qmlRegisterExtendedType<ShaderNode, Qt3DCore::Quick::Quick3DNode>(packageUri, 1, 0, "ShaderNode");
    qmlRegisterType<ShaderBuilder>(packageUri, 1, 0, "ShaderBuilder");
    qmlRegisterType<ShaderOutput>(packageUri, 1, 0, "ShaderOutput");
    qmlRegisterType<ShaderBuilderBinding>(packageUri, 1, 0, "ShaderBuilderBinding");
    qmlRegisterType<ParameterListBinding>(packageUri, 1, 0, "ParameterListBinding");

    qmlRegisterSingletonType<ShaderUtils>(packageUri, 1, 0, "ShaderUtils", &ShaderUtils::qmlInstance);
}

void ShaderNodesPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(engine);
    Q_UNUSED(uri);
}
