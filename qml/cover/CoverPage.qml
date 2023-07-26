import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        id: graph
        opacity: .50
        fillMode: Image.PreserveAspectFit

        anchors {
            left: parent.left
            right: parent.right
           // margins: Theme.paddingLarge
        }
        source: cover.status == Cover.Active ? "" : StandardPaths.cache + "/graph.png"
    }
    Label {
        id: label
        color: Theme.highlightColor
        anchors {
            top: graph.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }

        //text: cover.status === Cover.Active ? "I'm active!" : "I'm sleeping"
        text: qsTr("Plotter")
    }
    /*
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }
    */
}
