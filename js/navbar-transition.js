// Define the starting position for the fade-in effect
const startPosition = 10; // Adjust as needed

const navbar = document.querySelector(".navbar");

const imageToChangeDesk = document.getElementById("LogoToChange-Desktop");
const imageToChangeTablet = document.getElementById("LogoToChange-Tablet");
const imageToChangeMobile = document.getElementById("LogoToChange-Mobile");



const LogoTXTToChangeDesk = document.getElementById("LogoText-Desktop");
const LogoTXTToChangeTablet = document.getElementById("LogoText-Tablet");

// Listen for the scroll event
window.addEventListener("scroll", () => {
	// Calculate the scroll position
	const scrollPosition = window.scrollY;

	// Calculate the opacity based on scroll position
	const opacity = Math.min(1, scrollPosition / startPosition);

	// Apply the opacity to the navbar
	navbar.style.opacity = opacity;

	if (window.scrollY >= startPosition) {
		// Change the image source to the new image when scrolling down
		imageToChangeDesk.src = "assets/images/logo-256-lightBG.png";
		imageToChangeTablet.src = "assets/images/logo-256-lightBG.png";
		imageToChangeMobile.src = "assets/images/logo-256-lightBG.png";
		

		// Change the Text color when scrolling down
		LogoTXTToChangeDesk.style.color = "#041bfe";
		LogoTXTToChangeTablet.style.color = "#041bfe";
		
	} else {
		// Revert to the original image source when scrolling back to the top
		imageToChangeDesk.src = "assets/images/logo-256-darkBG.png";
		imageToChangeTablet.src = "assets/images/logo-256-darkBG.png";
		imageToChangeMobile.src = "assets/images/logo-256-Mobile.png";

		// Revert to the original Text color when scrolling back to the top
		LogoTXTToChangeDesk.style.color = "#FFFFFF";
		LogoTXTToChangeTablet.style.color = "#FFFFFF";

	}

});
