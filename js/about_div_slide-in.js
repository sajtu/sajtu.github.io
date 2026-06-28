/* JavaScript to add the 'active' class after a delay */
document.addEventListener("DOMContentLoaded", function () {
	const aboutAvatar = document.querySelector(".about_avatar");

	/* Add the 'active' class after a delay (e.g., 0.15 seconds) */
	/* 100 = 0.1 seconds, 1000 = 1 sec */
	setTimeout(function () {
		aboutAvatar.classList.add("active");
	}, 150); // Adjust the delay as needed
});
