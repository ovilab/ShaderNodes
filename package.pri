QT *= 3dquick 3drender 3dcore 3dinput 3dlogic qml-private 3dcore-private 3dquick-private

INCLUDEPATH += $$PWD/src

HEADERS += \
    $$PWD/src/shaderbuilder.h \
    $$PWD/src/shaderbuilderbinding.h \
    $$PWD/src/shadernode.h \
    $$PWD/src/shaderoutput.h \
    $$PWD/src/shaderutils.h \
    $$PWD/src/shadernodesplugin.h

SOURCES += \
    $$PWD/src/shaderbuilder.cpp \
    $$PWD/src/shaderbuilderbinding.cpp \
    $$PWD/src/shadernode.cpp \
    $$PWD/src/shaderoutput.cpp \
    $$PWD/src/shaderutils.cpp \
    $$PWD/src/shadernodesplugin.cpp

RESOURCES += \
    $$PWD/src/imports/shadernodes_imports.qrc

DISTFILES += \
    $$PWD/src/HandleArray.qml
