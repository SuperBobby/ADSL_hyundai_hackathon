
$(document).ready(function(){
  	console.log('hi');
    driver_id = $("#data_holder").attr("driver_id");
    console.log(driver_id);

    
    $.ajax({
            url: '/handle_match_request',
            type:'POST',
            data: {"driver_id" : Number(driver_id)},
            success:function(response){
              resp = JSON.parse(response);
              my_vec = resp.my_vec;
              norm_my_vec = resp.norm_my_vec
              your_vec = resp.your_vec;
              norm_your_vec = resp.norm_your_vec;
              cos_sim = resp.cos_sim;

              draw_chart(my_vec, your_vec);

              your_med = your_vec[3];
              my_med = my_vec[3];
              your_peak = your_vec[4];
              my_peak = my_vec[4];
              your_angle = your_vec[22];
              my_angle = my_vec[22];
              your_energy = your_vec[20];
              my_energy = my_vec[20];
              your_idle = your_vec[1]*100;
              my_idle = my_vec[1]*100;
              your_aircon = your_vec[21]*100;
              my_aircon = my_vec[21]*100;


              set_values(cos_sim, your_med, my_med, your_peak, my_peak, your_angle, my_angle, your_energy, my_energy, your_idle, my_idle, your_aircon, my_aircon );

              console.log("success");
            },
            error: function(){
              console.log("error");
            },
            complete:function(){
              console.log('complete');
            }

          });

});

function set_values(cos_sim, your_med, my_med, your_peak, my_peak, your_angle, my_angle, your_energy, my_energy, your_idle, my_idle, your_aircon, my_aircon ) {
  $("#cos_sim").text(cos_sim);
  $("#your_med").text(your_med);
  $("#my_med").text(my_med);
  $("#your_peak").text(your_peak);
  $("#my_peak").text(my_peak);
  $("#your_angle").text(your_angle.toFixed(2));
  $("#my_angle").text(my_angle.toFixed(2));
  $("#your_energy").text(your_energy.toFixed(2));
  $("#my_energy").text(my_energy.toFixed(2));
  $("#your_idle").text(your_idle.toFixed(2));
  $("#my_idle").text(my_idle.toFixed(2));
  $("#your_aircon").text(your_aircon.toFixed(2));
  $("#my_aircon").text(my_aircon.toFixed(2));
}

function draw_chart(my_vec, your_vec) {

  var w = 300,
  h = 300;

  var colorscale = d3.scale.category10();
  var LegendOptions = ['나의 운전습관','상대의 운전습관'];
  var my_vec;



  var mycfg = {
    w: w,
    h: h,
    maxValue: 0.6,
    levels: 6,
    //ExtraWidthX: 300
  }


  var d1 = [
      [{axis:"급가속 7 ~ 10 kph/s",value:my_vec[10]},
      {axis:"급가속 11 ~ 13 kph/s",value:my_vec[11]},
      {axis:"급가속 14 ~ 17 kph/s",value:my_vec[12]},
      {axis:"급가속 18 kph/s 이상",value:my_vec[13]}],
      [{axis:"급가속 7 ~ 10 kph/s",value:your_vec[10]},
      {axis:"급가속 11 ~ 13 kph/s",value:your_vec[11]},
      {axis:"급가속 14 ~ 17 kph/s",value:your_vec[12]},
      {axis:"급가속 18 kph/s 이상",value:your_vec[13]}]
    ];


  var d2 = [
        [{axis:"급감속 -21 kph/s 이하",value:my_vec[14]},
        {axis:"급감속 -18 ~ -20 kph/s",value:my_vec[15]},
        {axis:"급감속 -14 ~ -17 kph/s",value:my_vec[16]},
        {axis:"급감속 -11 ~ -13 kph/s",value:my_vec[17]},
        {axis:"급감속 -7 ~ -10 kph/s",value:my_vec[18]}],
        [{axis:"급감속 -21 kph/s 이하",value:your_vec[14]},
        {axis:"급감속 -18 ~ -20 kph/s",value:your_vec[15]},
        {axis:"급감속 -14 ~ -17 kph/s",value:your_vec[16]},
        {axis:"급감속 -11 ~ -13 kph/s",value:your_vec[17]},
        {axis:"급감속 -7 ~ -10 kph/s",value:your_vec[18]}]
      ];

  RadarChart.draw("#chart1", d1, mycfg);
  RadarChart.draw("#chart2", d2, mycfg);


  var svg = d3.select('#body')
  .selectAll('svg')
  .append('svg')
  .attr("width", w+200)
  .attr("height", h);

  //Create the title for the legend
  var text = svg.append("text")
  .attr("class", "title")
  .attr('transform', 'translate(90,0)')
  .attr("x", w - 70)
  .attr("y", 10)
  .attr("font-size", "12px")
  .attr("fill", "#404040")
  .text("");

  //Initiate Legend
  var legend = svg.append("g")
  .attr("class", "legend")
  .attr("height", 100)
  .attr("width", 200)
  .attr('transform', 'translate(90,20)');
  //Create colour squares
  legend.selectAll('rect')
  .data(LegendOptions)
  .enter()
  .append("rect")
  .attr("x", w - 65)
  .attr("y", function(d, i){ return i * 20;})
  .attr("width", 10)
  .attr("height", 10)
  .style("fill", function(d, i){ return colorscale(i);});
  //Create text next to squares
  legend.selectAll('text')
  .data(LegendOptions)
  .enter()
  .append("text")
  .attr("x", w - 52)
  .attr("y", function(d, i){ return i * 20 + 9;})
  .attr("font-size", "11px")
  .attr("fill", "#737373")
  .text(function(d) { return d; });

}

