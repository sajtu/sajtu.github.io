window.onload = function () {
  document.body.classList.add("fade-in");
};


const transitionButton = document.getElementById("transition-button");

transitionButton.addEventListener("click", function (event) {
	event.preventDefault(); // Prevent the default link behavior
	document.body.classList.add("fade-out");
	setTimeout(function () {
		window.location.href = transitionButton.getAttribute("href");
	}, 400); // Adjust this delay to match the animation duration
});
