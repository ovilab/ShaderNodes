#include "parameterlistbinding.h"

#include <Qt3DRender/QParameter>

ParameterListBinding::ParameterListBinding(Qt3DCore::QNode *parent) : Qt3DCore::QNode(parent)
{

}

QMaterial *ParameterListBinding::material() const
{
    return m_material;
}

ShaderBuilder *ParameterListBinding::shaderBuilder() const
{
    return m_shaderBuilder;
}

void ParameterListBinding::setMaterial(QMaterial *material)
{
    if (m_material == material)
        return;
    if(m_material) {
        clear();
    }
    m_material = material;
    if(m_material) {
        apply();
    }
    emit materialChanged(material);
}

void ParameterListBinding::setShaderBuilder(ShaderBuilder *shaderBuilder)
{
    if (m_shaderBuilder == shaderBuilder)
        return;
    if(m_shaderBuilder) {
        clear();
        disconnect(shaderBuilder, &ShaderBuilder::clearBegin, this, &ParameterListBinding::clear);
        disconnect(shaderBuilder, &ShaderBuilder::buildFinished, this, &ParameterListBinding::apply);
    }
    m_shaderBuilder = shaderBuilder;
    if(m_shaderBuilder) {
        connect(shaderBuilder, &ShaderBuilder::clearBegin, this, &ParameterListBinding::clear);
        connect(shaderBuilder, &ShaderBuilder::buildFinished, this, &ParameterListBinding::apply);
        apply();
    }
    emit shaderBuilderChanged(shaderBuilder);
}

void ParameterListBinding::clear()
{
    if(m_material && m_shaderBuilder) {
        for(UniformValue &uniformValue : m_shaderBuilder->m_uniforms) {
            m_material->removeParameter(uniformValue.parameter);
        }
    }
}

void ParameterListBinding::apply()
{
    if(m_material && m_shaderBuilder) {
        for(UniformValue &uniformValue : m_shaderBuilder->m_uniforms) {
            m_material->addParameter(uniformValue.parameter);
        }
    }
}
