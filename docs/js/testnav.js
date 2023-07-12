let myHamburger = document.getElementById('hamburger'),
    myNavMenu = document.getElementById('navMenu'),
    closeNavMenu = document.getElementById('closeNavMenu'),
    main = document.querySelector('main'),
    myMenuLinks = document.querySelectorAll('nav button, nav a'),
    transitionTime = 400, // This matches what's in the CSS for the transition
    overlay = document.createElement('div');

document.body.appendChild(overlay);

function doMenuOpen () {
  myHamburger.setAttribute('aria-expanded', true);
  myNavMenu.classList.remove('vh');
  myNavMenu.classList.remove('hidden');
  main.classList.add('menuOpen');
  myHamburger.classList.add('menuOpen');
  myHamburger.classList.add('hamburger-z');
  window.setTimeout(function () {
    closeNavMenu.focus();
    overlay.classList.add('overlay');
    overlay.addEventListener('click', function () {
      doMenuClose();
    }, false);

    document.addEventListener('keyup', function (e) {
      if (e.key === "esc") {
        doMenuClose();
      }
    }, false);
  }, transitionTime);
}

function doMenuClose () {
  myHamburger.setAttribute('aria-expanded', false);
  myNavMenu.classList.add('hidden');
  main.classList.remove('menuOpen');
  myHamburger.classList.remove('menuOpen');
  overlay.classList.remove('overlay');
  window.setTimeout(function () {
    myNavMenu.classList.add('vh');
    myHamburger.focus();
    overlay.classList.remove('overlay');
    myHamburger.classList.remove('hamburger-z');
  }, transitionTime);
}

myHamburger.addEventListener('click', function () {
  if (myNavMenu.classList.contains('hidden')) {
    doMenuOpen();
  } else {
    doMenuClose();
  }
}, false);

closeNavMenu.addEventListener('click', function () {
  doMenuClose();
}, false);







var appsMenuItems = document.querySelectorAll('#appmenu > li');
var subMenuItems = document.querySelectorAll('#appmenu > li li');
var keys = {
	tab:    9,
	enter:  13,
	esc:    27,
	space:  32,
	left:   37,
	up:     38,
	right:  39,
	down:   40
};
var currentIndex, subIndex;

var gotoIndex = function(idx) {
	if (idx == appsMenuItems.length) {
		idx = 0;
	} else if (idx < 0) {
		idx = appsMenuItems.length - 1;
	}
	appsMenuItems[idx].focus();
	currentIndex = idx;
};

var gotoSubIndex = function (menu, idx) {
	var items = menu.querySelectorAll('li');
	if (idx == items.length) {
		idx = 0;
	} else if (idx < 0) {
		idx = items.length - 1;
	}
	items[idx].focus();
	subIndex = idx;
}

Array.prototype.forEach.call(appsMenuItems, function(el, i){
		if (0 == i) {
			el.setAttribute('tabindex', '0');
			el.addEventListener("focus", function() {
				currentIndex = 0;
			});
		} else {
			el.setAttribute('tabindex', '-1');
		}
		el.addEventListener("focus", function() {
			subIndex = 0;
			Array.prototype.forEach.call(appsMenuItems, function(el, i){
				el.setAttribute('aria-expanded', "false");
			});
		});
		el.addEventListener("click",  function(event){
			if (this.getAttribute('aria-expanded') == 'false' || this.getAttribute('aria-expanded') ==  null) {
				this.setAttribute('aria-expanded', "true");
			} else {
				this.setAttribute('aria-expanded', "false");
			}
			// event.preventDefault();
			return false;
		});
		el.addEventListener("keydown", function(event) {
			var prevdef = false;
			switch (event.keyCode) {
				case keys.right:
					gotoIndex(currentIndex + 1);
					prevdef = true;
					break;
				case keys.left:
					gotoIndex(currentIndex - 1);
					prevdef = true;
					break;
				case keys.tab:
					if (event.shiftKey) {
						gotoIndex(currentIndex - 1);
					} else {
						gotoIndex(currentIndex + 1);
					}
					prevdef = true;
					break;
				case keys.enter:
					
				case keys.down:
					this.click();
					subindex = 0;
					gotoSubIndex(this.querySelector('ul'), 0);
					prevdef = true;
					break;
				case keys.up:
					this.click();
					var submenu = this.querySelector('ul');
					subindex = submenu.querySelectorAll('li').length - 1;
					gotoSubIndex(submenu, subindex);
					prevdef = true;
					break;
				case keys.esc:
					document.querySelector('#escape').setAttribute('tabindex', '-1');
					document.querySelector('#escape').focus();
					prevdef = true;
			}
			if (prevdef) {
				event.preventDefault();
			}
		});
});

Array.prototype.forEach.call(subMenuItems, function(el, i){
	el.setAttribute('tabindex', '-1');
	el.addEventListener("keydown", function(event) {
			switch (event.keyCode) {
				case keys.tab:
					if (event.shiftKey) {
						gotoIndex(currentIndex - 1);
					} else {
						gotoIndex(currentIndex + 1);
					}
					prevdef = true;
					break;
				case keys.right:
					gotoIndex(currentIndex + 1);
					prevdef = true;
					break;
				case keys.left:
					gotoIndex(currentIndex - 1);
					prevdef = true;
					break;
				case keys.esc:
					gotoIndex(currentIndex);
					prevdef = true;
					break;
				case keys.down:
					gotoSubIndex(this.parentNode, subIndex + 1);
					prevdef = true;
					break;
				case keys.up:
					gotoSubIndex(this.parentNode, subIndex - 1);
					prevdef = true;
					break;
				case keys.enter:
				case keys.space:
					alert(this.innerText);
					prevdef = true;
					break;
			}
			if (prevdef) {
				event.preventDefault();
				event.stopPropagation();
			}
			return false;
		});
	// el.addEventListener("click", function(event) {
	// 		alert(this.innerHTML);
	// 		event.preventDefault();
	// 		event.stopPropagation();
	// 		return false;
	// 	});
});