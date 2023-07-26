import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: aboutPage

    allowedOrientations: defaultAllowedOrientations

     Item {
        id: aboutInfos
        property string version:'0.1.0'
        property string text:  if(true) {
                '<style>a:link { color: ' + Theme.primaryColor  + '; }</style>' +
                        '<p>Plotter creates graphical plots of mathematical functions ' +
                        'using the <a href="https://d3js.org/">D3js library </a> and  ' +
                        '<br>a helper library from <a href="https://pavpanchekha.com/blog/plotting-d3.html">Pavel Panchekha</a></p>' +
                        '<br><p>It is intended more as a small showcase while integrating ' +
                        'plotting in Solver and Fibonacci</p> ' +
                        '<br>Free & Open Source :' +
                        '<br><a href="http://www.gnu.org/licenses/gpl-3.0.html"><b>License GPLv3</b></a>' +
                        '<br><br>Source :' +
                        '<br><a href="https://github.com/poetaster/Plotter"><b>Plotter on github</b></a>'
            }
     }

    SilicaFlickable {
        id: aboutFlick
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        contentWidth: aboutFlick.width

        VerticalScrollDecorator { flickable: aboutFlick }

        Column {
            id: aboutColumn
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr('About Plotter')
            }
            Label {
                id:title
                text: 'Plotter  v' + aboutInfos.version
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.paddingMedium
            }
            Label {
                id: slogan
                text: qsTr('for Sailfish OS')
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Item {
                width: 1
                height: Theme.paddingMedium
            }
            Label {
                id: content
                text: aboutInfos.text
                width: aboutFlick.width - Theme.paddingLarge
                wrapMode: TextEdit.WordWrap
                horizontalAlignment: Text.AlignHCenter;
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.RichText
                color: Theme.highlightColor
                anchors {
                    margins: Theme.paddingMedium
                }
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }
        }
    }
}
