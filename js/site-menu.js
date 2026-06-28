const menuModal = document.getElementById("menu-modal");
const SiteMenu = document.getElementById("site-map-menu");
const menuContent = document.querySelector(".site-map-menu-content");

var spinner = document.querySelector("#site-icon");

function SiteIconHover(img) {
	img.src = "assets/images/microsite-matrix-icon-solid.png"
}

function SiteIconHoverOut(img) {
	img.src = "assets/images/microsite-matrix-icon-outline.png"
}


document.querySelector("#site-icon").onmouseover = function() {
	spinner.style.animationName = "spin-site-icon";
	setTimeout(function() {
		spinner.style.animationName = "";
	}, 4000);
};


function displaySiteMap() {

	menuModal.style.opacity = "1";
	SiteMenu.style.opacity = "1";

	document.getElementById("menu-modal").classList.toggle("show");
	document.getElementById("site-map-menu").classList.toggle("show");

	document.body.style.overflow = "hidden";


}


window.onclick = function(event) {
	if (!event.target.matches('.site-icon-img')) {
		var dropdowns = document.getElementsByClassName("site-map-menu-content");
		var i;
		for (i = 0; i < dropdowns.length; i++) {
			var openDropdown = dropdowns[i];
			if (openDropdown.classList.contains('show')) {

				menuModal.style.opacity = "0";
				SiteMenu.style.opacity = "0";
				document.body.style.overflowY = "auto";
				document.body.style.overflowX = "hidden";

				setTimeout(() => {
					menuModal.classList.remove('show');
					openDropdown.classList.remove('show');
					}, 300); // Wait for the fade-out transition to complete

				
				
			}
		}
	}
}
