/*
*  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>.
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
//import io.thp.pyotherside 1.5

import "../components"
import "../js/d3.js" as D3
import "../js/plot.js" as Plot
import "../js/localdb.js" as DB

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    property bool debug: false

    property var elem
    property var border

    // this is a hack
    property var rootLine: 0
    property string func1
    property string func2
    property var tAreaH
    property string cName
    property int upper
    property int lower
    property int mode: 0


    property bool appActive: Qt.application.active

    onOrientationChanged:  {
        if ( orientation === Orientation.Portrait ) {
            drawer.open = true
            drawer.dock = Dock.Bottom

            //drawer.height = 1/3 * _screenHeight //page.height //+ Theme.paddingLarge  // * _screenHeight //- Theme.paddingLarge
            if (debug) console.debug("port")
            tAreaH = _screenHeight * 3/5 //derivative_Column.childrenRect.height * .6
        } else {
            if (debug) console.debug("land")
            drawer.dock = Dock.Right
            tAreaH = _screenHeight * 2/5
            //drawer.height = 1/4 * _screenHeight //page.height //+ Theme.paddingLarge  // * _screenHeight //- Theme.paddingLarge
            drawer.open = false
        }
        if (debug) console.debug(Orientation.Portrait)
    }

    Component.onCompleted: {
        //plot.save( StandardPaths.documents + "/" + func1 + func2 + ".png")
    }

    onAppActiveChanged:{
        if (appActive === false ) {
            //plot.save( StandardPaths.cache + "/graph.png")
            // canvas.requestPaint()
        }
    }
    property alias notification: popup
    Popup {
        id: popup
        z: 10
        timeout: 3000
        padding: Theme.paddingSmall
        defaultColor: Theme.highlightColor
        labelMargin: Theme.paddingSmall
    }

    PageHeader {
        id: pageHeader
        title: qsTr("Plotter")
    }
    Timer {
        id:updateTimer
        interval: 300
        repeat: false
        running: false
        onTriggered: {
            plot.updatePlot()
        }

    }
    SilicaFlickable {
        id: container
        anchors.fill: parent
        height: childrenRect.height
        width: parent.width

        Component.onCompleted: {
            cName = "Plotter"
            console.log('silica init')
            if(debug) console.debug(childrenRect.height)
            if(debug) console.debug(solver_Column.childrenRect.height)
            if(debug) console.debug(input_Column.childrenRect.height)
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            /*
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
*/
        }

        //FontLoader { id: dejavusansmono; source: "file:DejaVuSansMono.ttf" }

        Column {
            id : plotterColum
            width: isPortrait ? parent.width : 1/2 * parent.width
            height: isPortrait ? 1/2 * parent.height : parent.height - Theme.paddingLarge
            spacing: Theme.paddingSmall
            topPadding: Theme.paddingLarge

            Plot {
                id: plot
                property var pts   // pts to plot, we need to init with to
                // calculate the scaleing
                property var chart // instance of Plot.chart object

                // using Plot initialize otherwise border calcs will be off
                Component.onCompleted: {
                    console.log('plot init')
                    // instantiat plot.js
                    chart = new Plot.Chart(width, height, 10);
                    // set bounds
                    upper = Math.abs(upperBound.sliderValue)
                    lower = Math.abs(lowerBound.sliderValue)

                    // use plot.js _make_scale  sadly, not
                    // using cause, context

                    //plot.xScale = chart.x
                    //plot.yScale = chart.y

                    /*
                    * the sequence as an example
                    * declare a function to plot

                    func1 = 'sin(2*t) + 3*sin(t)'
                    func2 = '2*sin(3*t)'

                    simple cartesian
                    function cart(t) { with (Math) { return eval(func1); } }

                    two for parametric
                    function crc(t) { with (Math) { return eval(func1);  } }
                    function crc2(t) { with (Math) { return eval(func2);  } }

                    simple polar
                    function polar(t) { with (Math) { return eval(func1); } }

                    obtain pts
                    pts = chart.cartesian(cart, [lower, upper, 100])

                    // generate the xSale/yScale for canvas
                    border = getBorder(pts)

                    */

                    updatePlot()

                }

                function drawPlot(line) {

                    // the matrix app was setting rootline via y
                    // need to add a setting
                    //var y = 0;
                    // border was something like
                    //border = [[-2 * Math.PI, -5], [2 * Math.PI, 5]];

                    line(plot.pts)

                    // the original mechanism from matrix app
                    //line(getPoints());

                }

                /* here as an example only, see the plotType methods below */
                function getPoints() {
                    var points = [];
                    var dx = (maxX - minX) / 100;
                    for(var x = minX; x <= maxX; x += dx) {
                        points.push([x, elem[4] * Math.sin(elem[3] *x) + elem[2] * Math.cos(elem[1] *x)]);
                    }
                    return points;
                }

                function updatePlot(){

                    upper = Math.abs(upperBound.sliderValue)
                    lower = - Math.abs(lowerBound.sliderValue)

                    func1 = expressionLeft.text
                    func2 = expressionRight.text

                    if (mode === 0 ){
                        pts = plotCartesian(func1)
                    } else if (mode === 1 ){
                        pts = plotParametric(func1,func2)
                    } else if (mode === 2 ){
                        pts = plotPolar(func1)
                    }

                    border = getBorder(pts)
                    plot.requestPaint()

                }

                function plotParametric(func1,func2) {
                    // functions to plot
                    function crc(t) { with (Math) { return eval(func1);  } }
                    function crc2(t) { with (Math) { return eval(func2);  } }
                    //function crc3(t) { return crc(t), crc2(t) ; }
                    return chart.parametric(crc, crc2, [lower, upper, 100])
                }

                function plotCartesian(func) {
                    // function to plot
                    function cart(t) { with (Math) { return eval(func); } }
                    return chart.cartesian(cart, [lower, upper, 100])

                    // you can add them, too
                    //function trigsig(x) { with (Math) { return sin(2*x) + 3*cos(x); } }
                    //var pts = chart.cartesian(trigsig, [-6.3, 6.3, 100])
                    // line(pts)
                }

                function plotPolar(func) {
                    function cart(t) { with (Math) { return eval(func); } }
                    return chart.polar(cart, [lower, upper, 100])
                }
            }

        }

        // this is needed to keep menu updates from chocking on canvas redraw
        DockedPanel{
            id: drawer
            height: isPortrait ? 1/3 * parent.height : parent.height
            width: isPortrait ? parent.width : 1/2 * parent.width
            dock: isPortrait ? Dock.bottom : Dock.Right

            Grid {
                id : input_Column
                width: parent.width
                height: isPortrait ? parent.height : parent.height / 2
                leftPadding: Theme.paddingMedium
                columns: isPortrait ? 2 : 2
                rows: isPortrait ? 4 : 4
                // anchors.bottom: parent.bottom
                // Grid row 1
                TextField {
                    id: expressionLeft
                    width: parent.width / 2 - Theme.paddingLarge
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    label: qsTr("Exp. Left")
                    placeholderText: "6/(5-sqrt(x))"
                    text: "sin(2*t) + 3*sin(t)"
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: expressionRight.focus = true
                }
                TextField {
                    id: expressionRight
                    width: parent.width  / 2 - Theme.paddingLarge
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    label: qsTr("Exp. Right")
                    placeholderText: "sqrt(x)"
                    text: "2*sin(3*t)"
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: modeComboBox.focus = true
                }
                // Grid row 2
                Slider {
                    id: lowerBound
                    label: "Lower"
                    width: parent.width / 2
                    minimumValue: 1
                    maximumValue: 10
                    value: 5
                    stepSize: 1
                    valueText: sliderValue
                    onReleased: {
                        lower = lowerBound.sliderValue
                        plot.updatePlot()
                        //Database.setProp('saveFps',String(sliderValue))
                        //saveFps = sFps.sliderValue
                    }
                    Component.onCompleted: {
                        lower = lowerBound.sliderValue
                        //value = Database.getProp('saveFps')
                        //if (value < 1 )
                        //    value = 5
                        //saveFps = value
                    }
                }
                Slider {
                    id: upperBound
                    label: "Upper"
                    width: parent.width / 2
                    minimumValue: 1
                    maximumValue: 10
                    value: 5
                    stepSize: 1
                    valueText: sliderValue
                    onReleased: {
                        upper = upperBound.sliderValue
                        plot.updatePlot()
                        //Database.setProp('saveFps',String(sliderValue))
                        //saveFps = sFps.sliderValue
                    }
                    Component.onCompleted: {
                        upper = upperBound.sliderValue
                        //value = Database.getProp('saveFps')
                        //if (value < 1 )
                        //    value = 5
                        //saveFps = value
                    }
                }
                // Grid row 3
                ComboBox {
                    id: modeComboBox
                    width: parent.width / 2 - Theme.paddingLarge
                    currentIndex: mode
                    menu: ContextMenu {
                        MenuItem { text: qsTr("Cartesian") }
                        MenuItem { text: qsTr("Parametric") }
                        MenuItem { text: qsTr("Polar") }
                        onActivated: {
                            mode = index
                        }
                    }
                    onCurrentIndexChanged:  {

                        console.log(currentIndex)
                        if (currentIndex === 0) {
                            //expressionRight.visible = false
                            pageHeader.title = "Cartesian"
                        }
                        if (currentIndex === 1) {
                            //expressionRight.visible = true
                            pageHeader.title = "Parametric"
                        }
                        if (currentIndex === 2) {
                            //expressionRight.visible = false
                            pageHeader.title = "Polar"
                        }

                        // directly doing a plot leads to hanging menu items
                        updateTimer.start()
                    }
                }
                Item {
                   id: r3Item
                   width: parent.width / 2 - Theme.paddingLarge
                   height: modeComboBox.height
                }
                // Grid row 4
                Button {
                    id: copy_Button
                    width: parent.width / 2 - Theme.paddingLarge
                    text: qsTr("Export")

                    onClicked: {
                        //Clipboard.text = result_TextArea.text
                        plot.save( StandardPaths.documents + "/" + func1 + func2 + ".png")
                        notificationObj.notify(qsTr("Exported to: ") + StandardPaths.documents + "/" + func1 + func2 + ".png" )
                    }
                }
                Button {
                    id: calculate_Button
                    width: parent.width / 2 - Theme.paddingLarge
                    anchors.leftMargin: Theme.paddingLarge
                    text: qsTr("Plot")
                    focus: true
                    onClicked: { plot.updatePlot() }
                }
            }
        }
    }
    VerticalScrollDecorator { flickable: container }

    IconButton{
        id: upB

        //height: isPortrait ? 1/3 * parent.height : 1/2 * parent.height
        x: isPortrait  ? 1/2 * parent.width - 1/2 * width : parent.width - width
        y: isPortrait ? parent.height - height : parent.height / 2
        rotation: isPortrait ? 0 : -90
        //anchors {
        //    horizontalCenter: page.horizontalCenter;
        //    bottom: page.bottom
        //}
        visible: ! drawer.open
        icon.source: "image://theme/icon-m-up"
        onClicked: drawer.open = true

    }

}
