
// For use with scroller_template2.html and mfreeman_scroller.js.

// function to move a selection to the front/top, from
// https://gist.github.com/trtg/3922684
d3.selection.prototype.moveToFront = function () {
    return this.each(function () {
        this.parentNode.appendChild(this);
    });
};

// Settings object

var settings = {
    // could be used to save settings for styling things.
};

var data = []; // make this global

var vis = d3.select("#vis");


var update = function (value) {
    var localdata = data;
    var show_vis = true;
    var year = null;
    switch (value) {
        case 0:
            console.log("in case", value);
            show_vis = false;
            localdata = data.filter(function (d, i) { return i === 0 });
            break;
        case 1:
            console.log("in case", value);
            localdata = data.filter(function (d, i) { return i === 0 });
            var year = "y2005";
            break;
        case 2:
            console.log("in case", value);
            localdata = data.filter(function (d, i) { return i === 0 || i === 1  || i === 2 || i === 3 || i === 4 || i === 5});
            break;
        case 3:
            console.log("in case", value);
            //yScale = d3.scale.sqrt().range([margin.top, height - margin.bottom]);
            localdata = data;
            break;
        default:
            show_vis = true;
            draw_lines(localdata);
            break;
    }
    console.log("show viz", show_vis);
    //console.log(localdata);
    if (show_vis) {
        vis.style("display", "inline-block");
    } else {
        vis.style("display", "none");
    }
    draw_lines(localdata);

}
// setup scroll functionality

function display(error, mydata) {
    if (error) {
        console.log(error);
    } else {
        console.log(data);

        var vis = d3.select("#vis");

        data = make_data(mydata); // assign to global; call func main.js

        //console.log("after makedata", data);

        var scroll = scroller()
            .container(d3.select('#graphic'));

        // pass in .step selection as the steps
        scroll(d3.selectAll('.step'));

        // Pass the update function to the scroll object
        scroll.update(update);

        // This code hides the vis when you get past it.
        // You need to check what scroll value is a good cutoff.

        var oldScroll = 0;
        $(window).scroll(function (event) {
            var scroll = $(window).scrollTop();
            //console.log("scroll", scroll);
            if (scroll >= 2650 && scroll > oldScroll) {
                vis.style("display", "none");
            } else if (scroll >= 2650 && scroll < oldScroll) {
                vis.style("display", "inline-block"); // going backwards, turn it on.
            }
            oldScroll = scroll;
        });

    }

} // end display

queue()
    .defer(d3.csv, "data/hicover.csv")
    .await(display);

