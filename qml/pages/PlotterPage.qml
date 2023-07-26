/*
  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>.
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5

import "../components"
import "../js/d3.js" as D3
import "../js/plot.js" as Plot

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    property bool debug: false
    property string showEquator: 'true'

    property var elem
    property var border
    property var rootLine: 0
    property var func1
    property var func2
    property var tAreaH
    property var cName
    property var upper
    property var lower

    onOrientationChanged:  {
        if ( orientation === Orientation.Portrait ) {
            drawer.open = true
            if (debug) console.debug("port")
            tAreaH = _screenHeight * 3/5 //derivative_Column.childrenRect.height * .6
        } else {
            if (debug) console.debug("land")
            tAreaH = _screenHeight * 2/5
            drawer.height = 1/3 * page.height //+ Theme.paddingLarge  // * _screenHeight //- Theme.paddingLarge
            drawer.open = false
        }
        if (debug) console.debug(Orientation.Portrait)
        //console.debug(numColumns)
        //calculateResultSolver()
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
        title: qsTr("Plotter")
    }
    SilicaFlickable {
        id: container
        anchors.fill: parent
        height: childrenRect.height
        width: parent.width

        Component.onCompleted: {
            cName = "Plotter"
            if(debug) console.debug(childrenRect.height)
            if(debug) console.debug(solver_Column.childrenRect.height)
            if(debug) console.debug(input_Column.childrenRect.height)
        }
        PullDownMenu {
            MenuItem {
                text: "Settings"
                //onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: "Integral"
                onClicked: pageStack.replace(Qt.resolvedUrl("Integral.qml"))
            }
            MenuItem {
                text: "Limit"
                onClicked: pageStack.replace(Qt.resolvedUrl("Limit.qml"))
            }
        }

        //FontLoader { id: dejavusansmono; source: "file:DejaVuSansMono.ttf" }

        Column {
            id : plotterColum
            width: parent.width
            height: parent.height * 1/2 - Theme.paddingLarge // childrenRect.height
            spacing: Theme.paddingSmall
            topPadding: Theme.paddingLarge

            Plot {
                id: plot
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width //- (2 * Theme.paddingLarge)
                height: parent.height ///2 - (2 * Theme.paddingLarge)

                property var pts   // pts to plot, we need to init with to
                // calculate the scaleing
                property var chart // instance of Plot.chart object

                // using Plot initialize otherwise border calcs will be off
                Component.onCompleted: {

                    // instantiat plot.js
                    chart = new Plot.Chart(width, height, 10);
                    // set bounds
                    upper = Math.abs(upperBound.sliderValue)
                    lower = Math.abs(lowerBound.sliderValue)

                    // use plot.js _make_scale  sadly, not
                    // using cause, context

                    //plot.xScale = chart.x
                    //plot.yScale = chart.y

                    //declare a function to plot

                    func1 = 'sin(2*t) + 3*sin(t)'
                    func2 = '2*sin(3*t)'
                    // example of parametric
                    function crc(t) { with (Math) { return eval(func1);  } }
                    function crc2(t) { with (Math) { return eval(func2);  } }
                    pts = chart.parametric(crc, crc2, [-lower, upper, 100])

                    // user border values, not scale from plot
                    border = getBorder(pts)

                }

                function drawPlot(line) {
                    // passed in from GrafixTrig
                    //var y = 0;
                    //border = [[-2 * Math.PI, -5], [2 * Math.PI, 5]];
                    //console.log(border)

                    line(plot.pts)

                    // for some reason, we get fugged offsets
                    // no longer using border
                    //console.log(border)
                    //line(getPoints());
                }


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
                    console.log(lower)
                    func1 = expressionLeft.text
                    func2 = expressionRight.text
                    //pts = plotParametric(func1,func2)
                    pts = plotPolar(func1)
                    //pts = plotPolar(func1)
                    border = getBorder(pts)
                    plot.requestPaint()
                }

                function plotParametric(func1,func2) {
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
                }

                function plotPolar(func) {
                    function cart(t) { with (Math) { return eval(func); } }
                    return chart.polar(cart, [lower, upper, 100])
                }
            }

        }
        DockedPanel{
            id: drawer
            width: parent.width
            height: 1/3 * parent.height
            dock: Dock.bottom
            Column {
                id : input_Column
                width: page.width
                spacing: Theme.paddingSmall
                //anchors.bottom: parent.bottom
                Row{
                    //anchors.leftMargin: Theme.paddingLarge
                    anchors {
                        left: parent.left
                        right: parent.right
                        //top: parent.top
                    }
                    spacing: Theme.paddingLarge
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
                        EnterKey.onClicked: variableX.focus = true
                    }
                }
                Row {
                    id: xRow
                    //spacing: Theme.paddingSmall
                    width: parent.width
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
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
                            //value = Database.getProp('saveFps')
                            //if (value < 1 )
                            //    value = 5
                            //saveFps = value
                        }
                    }
                }
                Row {
                    id: buttonRow
                    spacing: Theme.paddingLarge
                    anchors.leftMargin: Theme.paddingLarge
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    Button {
                        id: copy_Button
                        width: parent.width * 1/3 - Theme.paddingLarge
                        text: qsTr("Copy")
                        onClicked: {
                            Clipboard.text = result_TextArea.text
                            notificationObj.notify("Copied!")
                        }
                    }
                    Button {
                        id: calculate_Button
                        width: parent.width * 2/3 - Theme.paddingLarge
                        text: qsTr("Plot")
                        focus: true
                        onClicked: { plot.updatePlot() }
                    }

                }
            }
        }
    }
    VerticalScrollDecorator { flickable: container }
    IconButton{
        id: upB
        anchors {
            horizontalCenter: page.horizontalCenter;
            bottom: page.bottom
        }
        visible: ! drawer.open
        icon.source: "image://theme/icon-m-up"
        onClicked: drawer.open = true

    }
}
