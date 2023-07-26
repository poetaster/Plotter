/*
*  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>.
*  derived from https://openrepos.net/content/fruct/matrix-calculator
*/

import QtQuick 2.6
import Sailfish.Silica 1.0

Canvas {
    id:canvas
    width: parent.width
    height: parent.height
    property real minX: -width / 2
    property real maxX: width / 2
    property real minY: -height / 2
    property real maxY: height / 2
    property int leftMargin: 10
    property int bottomMargin: 10

    property var coordsOnPressed
    property var coordsOnReleased
    property var coordsOfMovement

    // obtained from plot.js
    // not currently used
    property var xScale
    property var yScale

    // used to redraw when app comes up again.
    property bool appActive: Qt.application.active

    onAppActiveChanged:{
        if (appActive === true ) {
            console.log("activated")
            canvas.requestPaint()
        }
    }
    Timer {
        id:snaptimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            canvas.save( StandardPaths.cache + "/graph.png")
        }

    }

    onPainted: {
         // we save the current plot to use as cover img.
         //console.log("painted")
        snaptimer.start()
    }

    onPaint: {
        var context = plot.getContext('2d');
        context.clearRect(0,0,canvas.width,canvas.height);
        var xOffset = (border[1][0] - border[0][0]) / 10;
        var yOffset = (border[1][1] - border[0][1]) / 10;
        minX = border[0][0] - xOffset;
        maxX = border[1][0] + xOffset;
        minY = border[0][1] - yOffset;
        maxY = border[1][1] + yOffset;

        //console.log('scale elems: ' + minX + ' ' + maxX + ' ' + minY + ' ' + maxY)
        //console.log('marginleft: ' + leftMargin + ' bottom: ' + bottomMargin )
        //console.log('marginleft: ' + leftMargin + ' bottom: ' + bottomMargin )

        // depends on _make_scale from plot.js
        if (canvas.xScale && canvas.yScale) {
            console.log('using plot.js scale')
                var xScale = canvas.xScale;
                var yScale = canvas.yScale;
        } else {
            console.log('using internal scale')
                var xScale = d3.scaleLinear()
                .range([leftMargin, width])
                .domain([minX, maxX]);
                var yScale = d3.scaleLinear()
                .range([height - bottomMargin, 0])
                .domain([minY, maxY]);
        }

        var line = lineFunction(xScale, yScale, context);

        context.beginPath();
        context.lineWidth = 1.5;
        context.strokeStyle = "lightblue";
        context.fillStyle = "white";

        drawXAxis(context, 5);
        drawYAxis(context, 10);

        // This is from Plot.js
        //var line = d3.svg.line().x(this.x.to(0)).y(this.y.to(1));

        line([[minX, rootLine], [maxX, rootLine]]);
        line([[rootLine, minY], [rootLine, maxY]]);
        drawPlot(line);

        context.stroke();
    }

    function lineFunction(xScale, yScale, context) {
        return d3.line().x(function (d) {
            return xScale(d[0]);
        }).y(function (d) {
            return yScale(d[1]);
        }).curve(d3.curveNatural)
        .context(context);
    }


    /* 
    * adapted from plot.js for exracting min max from pts 
    */

    function getBorder(pts){

            Function.get = function(i) {return (function(x) {return x[i]})};

            var thisBorder = [
                    [
                        d3.min(pts, Function.get(0)),
                        d3.min(pts, Function.get(1))
                    ],
                    [
                        d3.max(pts, Function.get(0)),
                        d3.max(pts, Function.get(1))
                    ]
            ]
        // console.log(thisBorder)
        return thisBorder
    }

    function drawXAxis(context, steps) {
        var yScale = d3.scaleLinear().range([0, height]).domain([height, 0]);
        var line = lineFunction(d3.scaleLinear().range([0, width]).domain([0, width]), yScale, context);
        line([[leftMargin, bottomMargin], [width, bottomMargin]]);
        context.font = '20px sans-serif';
        var stepSize = (width - leftMargin) / steps;
        var plotStepSize = (maxX - minX) / steps;
        for (var i = 1; i < steps; i++) {
            line([[stepSize * i + leftMargin, bottomMargin],
                  [stepSize * i + leftMargin, bottomMargin + 20]])
            // Decimal points should be configured with dependency on max - min interval length
            var text = (minX + plotStepSize * i).toFixed(1).toString();
            context.fillText(text, stepSize * i + leftMargin -
                             context.measureText(text).width / 2, yScale(25 + bottomMargin));
        }
    }

    function drawYAxis(context, steps) {
        var yScale = d3.scaleLinear().range([0, height]).domain([height, 0]);
        var line = lineFunction(d3.scaleLinear().range([0, width]).domain([0, width]), yScale, context)
        line([[leftMargin, bottomMargin], [leftMargin, height - bottomMargin]]);
        context.font = '20px sans-serif';
        var stepSize = (height - bottomMargin) / steps;
        var plotStepSize = (maxY - minY) / steps;
        for (var i = 1; i < steps; i++) {
            line([[leftMargin, stepSize * i + bottomMargin],
                  [leftMargin + 20, stepSize * i + bottomMargin]])
            // Decimal points should be configured with dependency on max - min interval length
            var text = (minY + plotStepSize * i).toFixed(1).toString();
            context.fillText(text, leftMargin + 25, yScale(stepSize * i + bottomMargin - 10));
        }
    }

    function changeZoomPlus(levelZoom){
        if( border[1][1] - levelZoom > 0 && border[1][0] - levelZoom  > 0 ){
            border[0][0]+=levelZoom;
            border[0][1]+=levelZoom;
            border[1][0]-=levelZoom;
            border[1][1]-=levelZoom;
        }
        plot.requestPaint();
    }

    function changeZoomMinus(levelZoom){
        border[0][0]-=levelZoom;
        border[0][1]-=levelZoom;
        border[1][0]+=levelZoom;
        border[1][1]+=levelZoom;
        plot.requestPaint();
    }

    function roundOfNum(num){
        return Math.round(num * 100) / 100;
    }

    Item{
        id:zoom
        anchors.fill: canvas
        PinchArea {
            id: pinchArea
            property real minScale: 0.5
            property real maxScale: 1.0
            anchors.fill: parent
            pinch.target: zoom
            pinch.minimumScale: minScale * 0.5
            pinch.maximumScale: maxScale * 1.5
            //The commented code below - fire exit
            onPinchFinished: {
                ////                console.log(zoom.scale)
                ////                if (zoom.scale <= 1)
                ////                    plot.changeZoomPlus(Math.round(zoom.scale));
                ////                else
                ////                    plot.changeZoomMinus(Math.round(zoom.scale*10));
                zoom.scale = 1;
            }
            onPinchUpdated: {
                if (zoom.scale >= 1)
                    plot.changeZoomPlus(roundOfNum(zoom.scale));
                else
                    plot.changeZoomMinus(roundOfNum(zoom.scale));
            }

            Rectangle {
                opacity: 0.0
                anchors.fill: parent
            }
        }
        MouseArea{
            id: inputArea
            anchors.fill: parent
            onPressed: {
                coordsOnPressed = [mouse.x,mouse.y];
            }
            onPositionChanged: {
                coordsOnReleased = [mouse.x,mouse.y];
                coordsOfMovement = [Math.round((coordsOnPressed[0]-coordsOnReleased[0])/100),Math.round((coordsOnReleased[1]-coordsOnPressed[1])/100)];
                border[0][0]+=coordsOfMovement[0];
                border[0][1]+=coordsOfMovement[1];
                border[1][0]+=coordsOfMovement[0];
                border[1][1]+=coordsOfMovement[1];
                coordsOnPressed =  coordsOnReleased
                plot.requestPaint();
            }
        }
    }
}
