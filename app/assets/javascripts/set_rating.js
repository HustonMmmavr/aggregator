function setRating(id, val) {
    console.log(id);
    console.log('1');
    console.log(val);

    //var csrftoken = jQuery("[name=csrfmiddlewaretoken]").val();
    //if (csrftoken == null)
    //   csrftoken = Cookies.get('csrftoken'); // read from input csrftoken
    // var value =$(this).prop("value").toString();
    //var id = $(this).data('film_id').toString();
    $.ajax({
        type: 'POST',
        url: '/set_rating',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        // headers: { "X-CSRFToken": csrftoken},
        data: JSON.stringify({filmId: id, filmRating: val}),
    }).done(function(resp) {
      var el = document.getElementById("dr_" + id);
      el.innerHTML = resp['filmAvgRating'];
    }).fail(function(err) {
        var el = document.getElementById("rate" + id);
        console.log(el);
        el.innerHTML = "<div style=\"color: red;\"> Sorry: Error on Service, try set rating later </div>" ;
        console.log(err);
   });
};
