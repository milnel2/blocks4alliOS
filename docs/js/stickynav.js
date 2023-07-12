
window.onscroll = function() {myFunction()};
window.onscroll2 = function() {myFunction2()};

var appmenu = document.getElementById("appmenu");
var mobileNavbar = document.getElementById("mobileNavbar");
var sticky = appmenu.offsetTop;
var sticky2 = mobileNavbar.offsetTop;

function myFunction() {
  if (window.pageYOffset >= sticky) {
    appmenu.classList.add("sticky")
  } else {
    appmenu.classList.remove("sticky");
  }
}

function myFunction2() {
    if (window.pageYOffset >= sticky2) {
      mobileNavbar.classList.add("sticky")
    } else {
      mobileNavbar.classList.remove("sticky");
    }
  }
