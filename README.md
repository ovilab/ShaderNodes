# ShaderNodes #

ShaderNodes is a shader generator for Qt3D inspired by material designers found
in 3D software like Blender.
It produces GLSL shaders based on an object graph built in QML or C++.

Currently, only graphs built in QML are supported.

The simplest way to use ShaderNodes is to use the ShaderBuilderMaterial.
This can be used directly in place of any Qt3D material:

```qml
Entity {
    components: [
        ShaderBuilderMaterial {
            id: material
            fragmentColor: StandardMaterial {
                color: "green"
                normal: Bump {
                    texture: Noise {
                        vector: material.fragment.position
                    }
                }
            }
        },
        SphereMesh {
            id: mesh
        }
    ]
}
```

You can also build your own materials by using a ShaderBuilderEffect
or by generating the shader code with ShaderBuilder directly.
