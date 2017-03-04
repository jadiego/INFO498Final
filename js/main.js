// Main JavaScript File

var fullwidth = 650;
var fullheight = 550;

var margin = {
    top: 50,
    right: 20,
    bottom: 70,
    left: 70
};
var width = fullwidth - margin.left - margin.right;
var height = fullheight - margin.top - margin.bottom;

var years = ["2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015"];
//Set up scales
var xScale = d3.scale.ordinal().domain(years).rangeBands([0, width], .5)


var yScale = d3.scale.linear()
    .range([height, 0]);

//Configure axis generators
var xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left");

// Circle positioning function
var circleFunc = function (circle) {
    circle.attr('r', 15)
        .attr('fill', 'blue')
        .attr('cx', function (d) { return xScale(d.year) })
        .attr('cy', function (d) { return yScale(+0) })
        .attr("opacity", 0)
        .attr("id", function (d) {
            return "y" + d.year;
        })
}

// Error bar position fucntion
var errorbarFunc = function (line) {
    line
        .attr('x1', function (d) { return xScale(d.year) })
        .attr('x2', function (d) { return xScale(d.year) })
        .attr('y1', function (d) { return yScale(0) })
        .attr('y2', function (d) { return yScale(0) })
        .attr("stroke", "gray")
        .attr("opacity", 0)
        .attr("id", function (d) {
            return "error-y" + d.year;
        })
}

//Create the empty SVG image
var svg = d3.select("#vis")
    .append("svg")
    .attr("width", fullwidth)
    .attr("height", fullheight)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


// Add axes
svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
    .append("text")
    .attr("x", width)
    .attr("y", margin.bottom / 3)
    .attr("dy", "1em")
    .style("text-anchor", "end")
    .attr("class", "label")
    .text("Year");

svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("x", -margin.top)
    .attr("y", -2 * margin.left / 3)
    .attr("dy", "0.3em")
    .style("text-anchor", "end")
    .attr("class", "label")
    .text("No Health Insurance (%)");

function make_data(rawdata) {
    //console.log(rawdata)


    keys = d3.keys(rawdata[0])
    //console.log(keys);

    return rawdata;
}

function draw_lines(dataset) {

    console.log("case data", dataset);


    var ymin = d3.min(data, function (d) { return d["yes.cil"] });
    var ymax = d3.max(data, function (d) { return d["yes.ciu"] });
    //console.log("min",ymin, "max", ymax)
    // max of rates to 0 (reversed, remember)
    yScale.domain([ymin, ymax]);

    // draw each circle
    var circle = svg.selectAll("circle")
        .data(dataset, function (d) { // because there's a group with data already...
            return d.yes;
        });

    circle
        .enter()
        .append("circle")
        .call(circleFunc)

    circle
        .transition()
        .duration(500)
        .attr("opacity", 0.5)
        .attr("cy", function (d) { return yScale(+d.yes) })
        .attr("r", 3)

    circle.exit().transition().duration(500).attr("opacity", 0).remove()


    //draw errorbars
    var errorbar = svg.selectAll("line")
        .data(dataset, function (d) { 
            return d.yes
        })

    errorbar
        .enter()
        .append("line")
        .call(errorbarFunc)

    errorbar
        .transition()
        .duration(500)
        .attr("opacity", 0.5)
        .attr("y1", function (d) { return yScale(+d["yes.cil"]) })
        .attr("y2", function (d) { return yScale(+d["yes.ciu"]) })
    
    errorbar.exit().transition().duration(500).attr("opacity", 0).remove()


    svg.select(".y.axis").transition().duration(300).call(yAxis);
}
