import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.0 as QtControls

import ShaderNodes 1.0

import "widgets"

Pane {
    id: root

    property Editor editor
    
    Column {
        anchors {
            left: parent.left
            right: parent.right
        }
        
        Label {
            text: editor.activeNode ? editor.activeNode.title : ""
        }
        
        Repeater {
            model: editor.activeNode ? editor.activeNode.inputHandles : undefined
            
            Item {
                property Handle handle: modelData
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: loader.height

                Component {
                    id: floatEditComponent
                    FloatEditor {
                        handle: modelData
                    }
                }

                Component {
                    id: vector3DComponent
                    Vector3DEditor {
                        handle: modelData
                    }
                }
                
                Component {
                    id: occupiedComponent
                    Label {
                        text: handle.name + ": node"
                    }
                }

                Component {
                    id: unknownComponent
                    Label {
                        text: handle.name + ": default"
                    }
                }

                Component {
                    id: colorComponent
                    ColorEditor {
                        id: colorPicker
                        handle: modelData
                    }
                }
                
                Loader {
                    id: loader
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    
                    sourceComponent: {
                        if(handle.occupied) {
                            return occupiedComponent
                        }
                        switch(ShaderUtils.variantType(handle.defaultValue)) {
                        case ShaderUtils.Int:
                        case ShaderUtils.Float:
                            return floatEditComponent
                        case ShaderUtils.Color:
                        case ShaderUtils.String:
                            return colorComponent
                        case ShaderUtils.Vector3D:
                            return vector3DComponent
                        default:
                            return unknownComponent
                        }
                    }
                }
            }
        }
    }
}
