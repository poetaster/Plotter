import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Label {
        id: label
        color: Theme.highlightColor
        anchors {
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge * 4
        }
        text: qsTr("Plotter")
    }
    Image {
        id: graph
        opacity: .90
        fillMode: Image.PreserveAspectFit
        width: parent.width - Theme.paddingLarge
        anchors {
            horizontalCenter: parent.horizontalCenter
            top:label.bottom
            //left: parent.left
            //right: parent.right
            margins: Theme.paddingLarge
        }
        source: cover.status == Cover.Active ? "" : StandardPaths.cache + "/graph.png"
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
