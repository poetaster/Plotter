/* This file implements a simple plotting library described in https://pavpanchekha.com/blog/plotting-d3.org */
/* Copyright (c) 2014 Pavel Panchekha. This code is under the MIT license.*/

/* HTML usage
var chart2 = new Chart(460, 250);
function sigmoid(t) { with (Math) { return 1 / (1 + exp(-t)); } }
chart2.cartesian(sigmoid, [-5, 5, 100]);
function trigsig(x) { with (Math) { return .5+.5*sin(atan(2*x)); } }
chart2.cartesian(trigsig, [-5, 5, 100]).style("stroke", "lightblue");
*/

.import "d3.js" as DS

function function_pts(x, y, pts, t0, t1, ds) {
    if (Math.abs(t0 - t1) < 1e-5) return;
    var x1 = x(t1), y1 = y(t1);
    var x0 = pts[pts.length - 1][0], y0 = pts[pts.length - 1][1];
    if ((x1 - x0)*(x1 - x0) + (y1 - y0)*(y1 - y0) > ds*ds) {
        function_pts(x, y, pts, t0, (t0 + t1)/2, ds);
        function_pts(x, y, pts, (t0 + t1)/2, t1, ds);
    } else {
        pts.push([x1, y1]);
        //console.debug("pts" + x1 + ' ' + y1)
    }
}

function Chart(width, height, margin) {
    this.width = width || svg.width;
    this.height = height || svg.height;
    this.margin = margin || 2;

    //var a = d3.selectAll("script");
    //var script = a[0][a[0].length - 1];
    //this.svg = d3.select(script.parentNode).append("svg");
    //this.svg.attr("width", width).attr("height", height);
    
    this.x = undefined;
    this.y = undefined;
    
    this.plots = [];
    this.fo = undefined;
    this.mode = "plot";
}

Chart.prototype._make_scale = function(pts) {
    if (this.x && this.y) return;
    
    this.x = d3.scaleLinear()
        .domain([d3.min(pts, Function.get(0)),
                 d3.max(pts, Function.get(0))])
        .range([this.margin, this.width - this.margin]);
    this.y = d3.scaleLinear()
        .domain([d3.min(pts, Function.get(1)),
                 d3.max(pts, Function.get(1))])
        .range([this.height - this.margin, this.margin]);
}

Function.prototype.to = function(i) {
    var f = this;
    return function (p) {return f(p[i])};
}

Function.get = function(i) {return (function(x) {return x[i]})};
Function.id = function(x) {return x};

Chart.prototype.plot = function(x, y, t) {
    var dt = (t[1] - t[0]) / t[2];
    var ts = d3.range(t[0], t[1] + dt, dt);
    var t0 = ts.shift();
    var t1;
    var pts = [[x(t0), y(t0)]];
    for (var i = 1; i < ts.length; i++) {
        t1 = ts[i];
        function_pts(x, y, pts, t0, t1, dt * Math.sqrt(2));
        t0 = t1;
    }

    //this._make_scale(pts);

    // line drawing in Plot.qml
    //var line = d3.svg.line().x(this.x.to(0)).y(this.y.to(1));
    return pts ;
    //;retrun this.svg.append("path").attr("d", line(pts));
}

Chart.prototype._make_button = function() {
    if (this.fo) {
        var fo = this.fo[0][0].parentNode;
        fo.parentNode.appendChild(fo);
    } else {
        var that = this;
        this.fo = this.svg.append("foreignObject")
            .attr("width", this.width).attr("height", this.height)
            .append("xhtml:div");
        this.fo.append("button").text("Show Source")
            .on("click", function(d, i) {that._toggle_mode()});
    }
}

Chart.prototype._toggle_mode = function() {
    if (this.mode == "plot") {
        this.mode = "source";
        this.fo.select("button").text("Show Plot");
        this.svg.selectAll("path").style("display", "none");
        this.fo.selectAll("table").style("display", "block");
    } else {
        this.mode = "plot";
        this.fo.select("button").text("Show Source");
        this.svg.selectAll("path").style("display", "inherit");
        this.fo.selectAll("table").style("display", "none");
    }
}

Chart.prototype._push_plot = function(vars, range) {
    /*
    this._make_button();

    var t = this.fo.append("table").attr("class", "plot");
    var a_fn = undefined;
    for (var name in vars) {
        var tr = t.append("tr");
        a_fn = (""+vars[name]).match(/^function ([\w_]+)\s*\(([\w_]*)\)\s\{\s*(?:with\s*\(Math\)\s*\{\s*)?((?:\n|.)*?)(?:\s*\}){1,2}$/);
        tr.append("th").text(name)
        tr.append("td").text(a_fn[3]);
    }
    var h = t.insert("thead", "*").append("td").attr("colspan", 2);
    h.append("em").text(a_fn[1] + "(" + a_fn[2] + ")")
    h.append("span").text(" from " + d3.round(range[0], 2)
                          + " to " + d3.round(range[1], 2));
   */
}

Chart.prototype.cartesian = function(y, t) {
    var line = this.plot(Function.id, y, t);
    this._push_plot({y: y}, t);
    return line;
}

Chart.prototype.polar = function(r, t) {
    var line = this.plot(function(o) {return r(o) * Math.cos(o)},
                         function(o) {return r(o) * Math.sin(o)}, t);
    this._push_plot({r: r}, t);
    return line;
}

Chart.prototype.parametric = function(x, y, t) {
    var line = this.plot(x, y, t);
    this._push_plot({x: x, y: y}, t);
    return line;
}
