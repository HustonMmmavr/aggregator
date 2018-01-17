$(document).ready(function() {
   $('.film_rating').click(function() {
       var aid = $(this).data('aid');
       // var csrftoken = jQuery("[name=csrfmiddlewaretoken]").val();
       // if (csrftoken == null)
           // csrftoken = Cookies.get('csrftoken'); // read from input csrftoken
       var value =$(this).prop("value").toString();
       var id = $(this).data('film_id').toString();
       $.ajax({
           type: 'POST',
           url: '/set_rating',
           contentType: "application/json; charset=utf-8",
           dataType: "json",
           // headers: { "X-CSRFToken": csrftoken},
           data: JSON.stringify({filmId: id, filmRating: value}),
       }).done(function(resp)
       {
         var el = document.getElementById("dr_" + id);
         el.innerHTML = resp['filmAvgRating'];
       }).fail(function(err) {
           console.log(err);
       });
   });
});
