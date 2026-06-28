/* JavaScript to add the 'active' class after a delay */
document.addEventListener("DOMContentLoaded", function () {
	const pageTitle = document.querySelector(".page-title-container");

	/* Add the 'active' class after a delay (e.g., 0.15 seconds) */
	/* 100 = 0.1 seconds, 1000 = 1 sec */
	setTimeout(function () {
		pageTitle.classList.add("active");
		
	}, 500); // Adjust the delay as needed
});
