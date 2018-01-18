function deleteFilm(id) {
  $.ajax({
      type: 'DELETE',
      url: '/delete_film/' + id.toString(),
      // contentType: "application/json; charset=utf-8",
      // dataType: "json",
      // headers: { "X-CSRFToken": csrftoken},
      // data: JSON.stringify({filmId: id.toString(), filmRating: val.toString()}),
  }).done(function(resp) {
    // TODO refirect
    console.log('ok');
    window.location.href = '/';
    // var el = document.getElementById("dr_" + id);
    // el.innerHTML = resp['filmAvgRating'];
  }).fail(function(err) {
    // TODO delete button and set text
      var el = document.getElementById("rate" + id);
      console.log(el);
      el.innerHTML = "<div style=\"color: red;\"> Sorry: Error on Service, try set rating later </div>" ;
      console.log(err);
 });
};
