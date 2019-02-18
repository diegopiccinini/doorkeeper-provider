
function onSuccess(googleUser) {
  console.log('Name: ' + profile.getName());
}

function onFailure(error) {
  console.log(error);
}

function renderButton() {
  gapi.signin2.render('my-signin2', {
    'scope': 'profile email',
    'width': 240,
    'height': 50,
    'longtitle': true,
    'theme': 'dark',
    'onsuccess': onSuccess,
    'onfailure': onFailure
  });
}

function onSignIn(googleUser) {
  // The ID token you need to pass to your backend:
  var id_token = googleUser.getAuthResponse().id_token;
  login(id_token);
}

function login(id_token) {
  var xhr = new XMLHttpRequest();
  var host = window.location.origin;
  var url = host + '/tokensignin';
  xhr.open('POST', url);

  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

  xhr.send('idtoken=' + id_token);
  xhr.onload = function() {
    var jsonResponse = JSON.parse(xhr.responseText);
    if ( xhr.status == 200) window.location.replace(host + jsonResponse.redirect_uri);
    if ( xhr.status == 422) document.getElementById('error').innerHTML= "<p>" + jsonResponse.error + "</p>";

  }
}
function signOut() {
  var auth2 = gapi.auth2.getAuthInstance();
  auth2.signOut().then(function () {
    console.log('User signed out.');
  });
}

