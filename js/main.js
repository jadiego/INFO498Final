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

    // var groups = svg.selectAll("g.circle")
    //     .data(dataset, function (d) { return d })

    // groups
    //     .enter()
    //     .append("g")
    //     .attr("class", "lines")

    // groups.exit().transition().duration(1000).attr("opacity", 0).remove();

    var circle = svg.selectAll("g.circle")
        .data(dataset, function (d) { // because there's a group with data already...
            return d; // it has to be an array for the line function
        });

    circle
        .enter()
        .append("circle")
        .attr("cx", function(d) { return xScale(d.year)})
        .attr("cy", function(d) { return yScale(+d.yes)})
        .attr("r", 3)

    circle.exit().remove()

    circle.exit().transition().duration(1000).attr("opacity", 0)

    svg.select(".y.axis").transition().duration(300).call(yAxis);
}
